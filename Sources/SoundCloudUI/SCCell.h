//
//  SCCell.h
//  Soundcloud
//
//  Created by Ullrich Schäfer on 12.04.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol SCCellDelegate;

/*
 * Superclass for all cells in SCTableViewControllers
 */

@interface SCCell : UITableViewCell {
	// outlets retained
	UIView *menuView;
	UIView *mainView;
	UIImageView	*itemImageView;
	
	id<SCCellDelegate>	delegate;	// assigned
	
	BOOL swipeActive;
	
	UITouch *touchDown;
	CGPoint touchDownPoint;	// beginning of swipe
}
@property (nonatomic, assign) id<SCCellDelegate> delegate;

@property (nonatomic,readonly, getter=isMenuVisible) BOOL menuVisible;
- (IBAction)hideMenu;
- (IBAction)showMenu;

@property (nonatomic,assign,getter=isSwipeActive) BOOL swipeActive;	// used in UITableViewDelegate to determine if cell will be selected

// Outlets
@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIImageView *itemImageView;

@end


@protocol SCCellDelegate <NSObject>
@optional
- (void)cellWasSwiped:(SCCell *)cell;
- (UIView *)menuViewForCell:(SCCell *)cell withFrame:(CGRect)frame;
@end


@interface SCCellBackgroundView : UIView {
    UIColor *separatorColor;
}
@property (nonatomic, retain) UIColor *separatorColor;
@end