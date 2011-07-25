//
//  SCCell.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 12.04.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "UIView_GPKit.h"
#import "SCAppIsRunningOnIPad.h"

#import "SCCell.h"

@interface SCCell ()
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@implementation SCCell

#pragma mark Lifecycle

- (void)awakeFromNib;
{
	[super awakeFromNib];
	
	swipeActive = NO;
	touchDownPoint = CGPointZero;
	
    self.backgroundView = [[[SCCellBackgroundView alloc] initWithFrame:self.bounds] autorelease];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
	self.selectedBackgroundView = [[[SCCellBackgroundView alloc] initWithFrame:self.bounds] autorelease];
	self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.946 alpha:1.000]; //background color from default artwork
}

- (void)dealloc;
{
	[mainView release];
	[menuView release];
	[itemImageView release];
	[touchDown release];
	[super dealloc];
}

- (void)prepareForReuse;
{
	self.editing = NO;
	[self hideMenu];
}


#pragma mark Accessors

@synthesize mainView, menuView, itemImageView;

@synthesize delegate;
@synthesize swipeActive;

- (BOOL)isMenuVisible;
{
	return (self.menuView != nil);
}

- (void)setHighlighted:(BOOL)value animated:(BOOL)animated;
{
	// only highlight when menu is not visible
	[super setHighlighted:(value && !self.menuVisible) animated:animated];
	
	if (self.highlighted) {
		self.mainView.backgroundColor = self.selectedBackgroundView.backgroundColor;
	}
}

- (void)setSelected:(BOOL)value animated:(BOOL)animated;
{
	[super setSelected:value animated:animated];
	
	if (self.selected) {
	 	self.mainView.backgroundColor = self.selectedBackgroundView.backgroundColor;
	}
}


#pragma mark Swiping
// TODO: Replace with gesture recognizers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (touches.count == 1) {
		touchDown = [[touches anyObject] retain];
		touchDownPoint = [touchDown locationInView:self];
	} else {
		self.swipeActive = NO;
		[touchDown release]; touchDown = nil;
		touchDownPoint = CGPointZero;
	}
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[super touchesMoved:touches withEvent:event];
	if (touchDown && !self.swipeActive) {
		NSAssert([touches containsObject:touchDown], @"did loose touch");
		UITouch *touchUp = [touches anyObject];
		CGPoint touchUpPoint = [touchUp locationInView:self];
		CGFloat diffX = touchUpPoint.x - touchDownPoint.x;
		if (fabs(diffX) > 50.0) {
			self.swipeActive = YES;
			[self enclosingScrollView].scrollEnabled = NO;
			if ([delegate respondsToSelector:@selector(cellWasSwiped:)]) {
				[delegate cellWasSwiped:self];
			}
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[touchDown release]; touchDown = nil;
	touchDownPoint = CGPointZero;
	[self enclosingScrollView].scrollEnabled = YES;

	[super touchesEnded:touches withEvent:event];
	[super performSelector:@selector(setSwipeActiveNO) withObject:nil afterDelay:0.0]; // important to call after super
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[touchDown release]; touchDown = nil;
	touchDownPoint = CGPointZero;
	[self enclosingScrollView].scrollEnabled = YES;
	
	[super touchesCancelled:touches withEvent:event];
	[super performSelector:@selector(setSwipeActiveNO) withObject:nil afterDelay:0.0]; // important to call after super
}

- (void)setSwipeActiveNO;
{
	self.swipeActive = NO;
}

- (IBAction)showMenu;
{
	if (self.menuVisible) return;
	
	[self.menuView removeFromSuperview]; self.menuView = nil;
	if ([delegate respondsToSelector:@selector(menuViewForCell:withFrame:)]) {
		self.menuView = [delegate menuViewForCell:self withFrame:self.mainView.frame];
	}
	
	if (!self.menuView) return;
	 
	[self.contentView insertSubview:self.menuView belowSubview:self.mainView];
	
	[UIView beginAnimations:@"SCCellShowMenu" context:nil];
	
	self.mainView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.mainView.frame), 0);

	[UIView commitAnimations];
}

- (IBAction)hideMenu;
{
	if (!self.menuVisible) return;
	
	[UIView beginAnimations:@"SCCellHideMenu" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	
	self.mainView.transform = CGAffineTransformIdentity;

	[UIView commitAnimations];
}

- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
	[self.menuView removeFromSuperview]; self.menuView = nil;
}


#pragma mark Layouting

- (void)layoutSubviews;
{
	[super layoutSubviews];
	
	// resize main & menu for horizontal orientation
	CGRect contentRect;
	CGRect trashRect;
	
	if ( !SCAppIsRunningOnIPad() ) {
		CGRectDivide(self.contentView.bounds, &trashRect, &contentRect, CGRectGetWidth(self.itemImageView.frame), CGRectMinXEdge);		
	} 
	
	// apply new frame with identity transformation & reapply transformation if menu is visible
	self.mainView.transform = CGAffineTransformIdentity;
	self.mainView.frame = self.contentView.bounds;
	self.menuView.frame = self.contentView.bounds;
	if (self.menuVisible) {
		self.mainView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.mainView.frame), 0);	
	}
}

@end


@implementation SCCellBackgroundView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        separatorColor = [[UIColor alloc] initWithWhite:0.88 alpha:1.0];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc;
{
    [separatorColor release];
    [super dealloc];
}

@synthesize separatorColor;

- (void)drawRect:(CGRect)rect;
{
    [super drawRect:rect];
    CGRect lineRect = self.bounds;
    lineRect.origin.y = lineRect.origin.y + lineRect.size.height - 1.0;
    lineRect.size.height = 1.0;
    [separatorColor setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, lineRect);
}

@end
