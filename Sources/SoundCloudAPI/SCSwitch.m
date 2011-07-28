//
//  SCSwitch.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 24.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "UIImage_GPKit.h"
#import "SCBundle.h"
#import "SCSwitch.h"

@implementation SCSwitch

#pragma mark GPSwitch

- (void)commonAwake;
{
	[super commonAwake];
	self.onBackgroundImage = [[SCBundle imageFromPNGWithName:@"switch_blue"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	self.offBackgroundImage = [[SCBundle imageFromPNGWithName:@"switch_orange"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	self.handleImage = [[SCBundle imageFromPNGWithName:@"switch_slider"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	self.handleHighlightImage = [[SCBundle imageFromPNGWithName:@"switch_slider-down"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	self.overlayImage = [[SCBundle imageFromPNGWithName:@"switch_filter"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	self.maskImage = [[SCBundle imageFromPNGWithName:@"switch_mask"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
}

@end
