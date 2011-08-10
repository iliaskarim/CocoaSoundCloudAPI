//
//  UIImage+SoundCloudAPI.h
//  YouAreHere
//
//  Created by Gernot Poetsch on 12.03.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (SoundCloudAPI)

+ (UIImage *)imageNamed:(NSString *)name leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)imageByResizingTo:(CGSize)newSize;
- (UIImage *)imageByResizingTo:(CGSize)newSize forRetinaDisplay:(BOOL)forRetinaDisplay;

@end
