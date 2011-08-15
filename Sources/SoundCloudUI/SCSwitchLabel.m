//
//  SCSwitchLabel.m
//  SCSwitch
//
//  Created by Ullrich Schäfer on 22.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "SCSwitchLabel.h"


@implementation SCSwitchLabel

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame;
{
	if ((self = [super initWithFrame:frame])) {
		label = [[UILabel alloc] initWithFrame:self.bounds];
		label.backgroundColor = [UIColor clearColor];
		label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		label.font = [UIFont systemFontOfSize:15];
		label.textColor = [UIColor whiteColor];
		label.shadowColor = [UIColor colorWithWhite:0.2 alpha:0.3];
		label.shadowOffset = CGSizeMake(0, -1);
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
	}
	return self;
}

- (void)dealloc;
{
	[background release];
	[label release];
	[super dealloc];
}


#pragma mark Accessors

@dynamic text;
@synthesize background;

- (NSString *)text;
{
	return label.text;
}

- (void)setText:(NSString *)value;
{
	label.text = value;
}

- (void)setBackground:(UIImage *)value;
{
	[value retain]; [background release]; background = value;
	[self setNeedsDisplay];
}


#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
	[super drawRect:rect];
	if (background) {
		[background drawInRect:self.bounds];
	} else {
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
		CGContextFillRect(context, self.bounds);
	}
}

@end
