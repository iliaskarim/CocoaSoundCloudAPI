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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect top, bottom;
    CGRectDivide(self.bounds, &top, &bottom, CGRectGetHeight(self.bounds) / 2, CGRectMinYEdge);
    
    [[UIColor blackColor] set];
    CGContextFillRect(context, top);
    
    [[UIColor colorWithWhite:1 alpha:0.05] set];
    CGContextFillRect(context, bottom);
}

@end
