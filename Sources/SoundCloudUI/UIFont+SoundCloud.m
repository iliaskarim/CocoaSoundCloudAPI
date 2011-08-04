//
//  UIFont+SoundCloud.m
//  SoundCloud
//
//  Created by Thomas Kollbach on 11.05.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "UIFont+SoundCloud.h"


@implementation UIFont (SoundCloud)

+ (UIFont *)soundCloudRegularFontOfSize:(CGFloat)size;
{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return [UIFont fontWithName:@"Interstate-Regular" size:size];        
//    }
    
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)soundCloudLightFontOfSize:(CGFloat)size;
{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return [UIFont fontWithName:@"Interstate-Light" size:size];        
//    }
    
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)soundCloudRegularTextFont;
{
	return [UIFont fontWithName:@"Interstate-Regular" size:18.0];
}

+ (UIFont *)soundCloudDetailTextFont;
{
	return [UIFont fontWithName:@"Interstate-Light" size:16.0];
}

@end
