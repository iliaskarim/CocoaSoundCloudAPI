//
//  SCHorizontalLineView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 28.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCHorizontalLineView.h"

@implementation SCHorizontalLineView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    [[UIColor blackColor] set];
    
    CGPoint blackLine[] = {
        CGPointMake(0, 1),
        CGPointMake(self.bounds.size.width, 1)
    };
    CGContextStrokeLineSegments(context, blackLine, 2);
    
    [[UIColor colorWithWhite:1 alpha:0.05] set];
    CGPoint shadowLine[] = {
        CGPointMake(0, 2),
        CGPointMake(self.bounds.size.width, 2)
    };
    CGContextStrokeLineSegments(context, shadowLine, 2);
}

@end
