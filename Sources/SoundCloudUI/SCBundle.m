//
//  SCBundle.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 27.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCBundle.h"

@implementation SCBundle

+ (NSBundle *)bundle;
{
    static NSBundle *resourceBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resourceBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"SoundCloud" ofType:@"bundle"]];
        NSAssert(resourceBundle, @"Please move the SoundCloud.bundle into the Resource Directory of your Application!"); 
    });
    return resourceBundle;
}

+ (UIImage *)imageFromPNGWithName:(NSString *)aName;
{
    NSBundle *bundle = [self bundle];
    NSString *path = [bundle pathForResource:aName ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}


@end
