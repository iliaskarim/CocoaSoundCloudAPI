//
//  UIColor+SoundCloud.m
//  SoundCloud
//
//  Created by Thomas Kollbach on 21.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "UIColor+SoundCloud.h"

@implementation UIColor (SoundCloud)

+ (UIColor *)almostBlackColor;
{
    return [UIColor colorWithWhite:0.200 alpha:1.0];
}


+ (UIColor *)listSubtitleColor;
{
    return [UIColor colorWithWhite:0.510 alpha:1.000];
}

+ (UIColor *)soundCloudOrangeWithAlpha:(CGFloat)alpha;
{
   return [UIColor colorWithRed:0.984 green:0.388 blue:0.106 alpha:alpha]; 
}

+ (UIColor *)soundCloudOrange;
{
    return [UIColor soundCloudOrangeWithAlpha:1.0];
}

+ (UIColor *)soundCloudListShineThroughWhite;
{
    return [UIColor colorWithWhite:1.0 alpha:0.8];
}

@end
