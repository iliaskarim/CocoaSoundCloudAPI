//
//  SCSwitch.h
//  SCSwitch
//
//  Created by Ullrich Schäfer on 22.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class SCSwitchLabel;

@interface SCSwitch : UIControl {
	BOOL on;
	
	UIImageView		*handleView;
	SCSwitchLabel	*onLabel;
	SCSwitchLabel	*offLabel;
	UIImageView		*overlayView;
	
	UIImage			*maskImage;
	
	CGFloat	handleRatio;
	CGFloat handleOffset; // 0.0 to 1.0 relative to width of bounds
	BOOL	isDragging;
}
@property(nonatomic,getter=isOn) BOOL on;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@property (nonatomic,copy) NSString		*onText;
@property (nonatomic,copy) NSString		*offText;
@property (nonatomic,retain) UIImage	*handleImage;
@property (nonatomic,retain) UIImage	*handleHighlightImage;
@property (nonatomic,retain) UIImage	*onBackgroundImage;
@property (nonatomic,retain) UIImage	*offBackgroundImage;
@property (nonatomic,retain) UIImage	*overlayImage;
@property (nonatomic,retain) UIImage	*maskImage;

@property (nonatomic, assign) CGFloat	handleRatio;	// 0.0 .. 1.0 - as a percentage of the total width of thw switch


- (void)commonAwake;


@end
