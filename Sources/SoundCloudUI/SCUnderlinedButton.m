//
//  SCUnderlinedButton.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 28.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCUnderlinedButton.h"

@implementation SCUnderlinedButton

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [self.titleLabel.textColor set];
    CGPoint line[] = {
        CGPointMake(0, CGRectGetMaxY(self.bounds) - 1),
        CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - 1)
    };
    CGContextStrokeLineSegments(context, line, 2);
}

@end
