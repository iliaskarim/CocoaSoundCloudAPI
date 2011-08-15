//
//  UIImage+SoundCloudAPI.m
//  YouAreHere
//
//  Created by Gernot Poetsch on 12.03.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

#import "UIImage+SoundCloudAPI.h"


@implementation UIImage (SoundCloudAPI)

+ (UIImage *)imageNamed:(NSString *)name leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;
{
	return [[UIImage imageNamed:name] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

+ (UIImage *)imageWithColor:(UIColor *)color;
{
    CGSize size = CGSizeMake(1.0f, 1.0f);
	return [[self class] imageWithColor:color size:size];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
{
	CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

- (UIImage *)imageByResizingTo:(CGSize)newSize;
{
	UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

- (UIImage *)imageByResizingTo:(CGSize)newSize forRetinaDisplay:(BOOL)forRetinaDisplay;
{
    if (forRetinaDisplay && [[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    [self drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

@end
