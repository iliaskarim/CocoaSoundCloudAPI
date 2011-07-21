//
//  SCSwitch.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 24.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "UIImage_GPKit.h"

#import "SCSwitch.h"

@implementation SCSwitch

#pragma mark GPSwitch

- (void)commonAwake;
{
	[super commonAwake];
	self.onBackgroundImage = [UIImage imageNamed:@"switch_blue.png" leftCapWidth:5 topCapHeight:5];
	self.offBackgroundImage = [UIImage imageNamed:@"switch_orange.png" leftCapWidth:5 topCapHeight:5];
	self.handleImage = [UIImage imageNamed:@"switch_slider.png" leftCapWidth:5 topCapHeight:5];
	self.handleHighlightImage = [UIImage imageNamed:@"switch_slider-down.png" leftCapWidth:5 topCapHeight:5];
	self.overlayImage = [UIImage imageNamed:@"switch_filter.png" leftCapWidth:5 topCapHeight:5];
	self.maskImage = [UIImage imageNamed:@"switch_mask.png" leftCapWidth:3 topCapHeight:3];
}

@end
