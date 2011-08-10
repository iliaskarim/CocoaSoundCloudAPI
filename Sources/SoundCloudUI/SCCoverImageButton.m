//
//  SCCoverImageButton.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 28.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "QuartzCore+SoundCloudAPI.h"
#import "UIColor+SoundCloudAPI.h"

#import "SCCoverImageButton.h"

@implementation SCCoverImageButton

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor blackColor] setStroke];
    [[UIColor transparentBlack] setFill];
    
    CGContextSetLineWidth(context, 1.0);
    SC_CGContextAddRoundedRect(context, CGRectInset(self.bounds, 0.5, 0.5), 7.0);
    CGContextStrokePath(context);
    SC_CGContextAddRoundedRect(context, CGRectInset(self.bounds, 0.5, 0.5), 7.0);
    CGContextFillPath(context);
}

@end
