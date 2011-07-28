//
//  SCHorizontalSeparatorView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 28.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCHorizontalSeparatorView.h"

@implementation SCHorizontalSeparatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    [[UIColor blackColor] set];
    
    CGPoint blackLine[] = {
        CGPointMake(1, 0),
        CGPointMake(1, self.bounds.size.height)
    };
    CGContextStrokeLineSegments(context, blackLine, 2);
}


@end
