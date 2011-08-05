//
//  SCSCRecordingSaveViewControllerTitleView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 28.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCBundle.h"

#import "SCSCRecordingSaveViewControllerTitleView.h"

@implementation SCSCRecordingSaveViewControllerTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor blackColor];
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        
        CGRect logoRect;
        CGRect connectRect;
        CGRect closeRect;
        CGRectDivide(self.bounds, &logoRect, &connectRect, 40.0, CGRectMinXEdge);
        CGRectDivide(connectRect, &closeRect, &connectRect, connectRect.size.height, CGRectMaxXEdge);
        
        logoRect.origin.x += 6.0;
        logoRect.origin.y += 8.0;
        connectRect.origin.y += 9.0;
        
        UIImageView *cloudImageView = [[UIImageView alloc] initWithFrame:logoRect];
        UIImage *cloudImage = [SCBundle imageFromPNGWithName:@"cloud"];
        cloudImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
        cloudImageView.image = cloudImage;
        [cloudImageView sizeToFit];
        [self addSubview:cloudImageView];
        [cloudImageView release];
        
        UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:connectRect];
        UIImage *titleImage = [SCBundle imageFromPNGWithName:@"sharetosc"];
        titleImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
        titleImageView.image = titleImage;
        [titleImageView sizeToFit];
        [self addSubview:titleImageView];
        [titleImageView release];
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    CGRect topLineRect;
    CGRect gradientRect;
    CGRect bottomLineRect;
    CGRectDivide(self.bounds, &topLineRect, &gradientRect, 0.0, CGRectMinYEdge);
    CGRectDivide(gradientRect, &bottomLineRect, &gradientRect, 1.0, CGRectMaxYEdge);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 (CGFloat[]){1.0,0.40,0.0,1.0,  1.0,0.21,0.0,1.0},
                                                                 (CGFloat[]){0.0, 1.0},
                                                                 2);
    CGContextDrawLinearGradient(context, gradient, gradientRect.origin, CGPointMake(gradientRect.origin.x, CGRectGetMaxY(gradientRect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetFillColor(context, (CGFloat[]){0.0,0.0,0.0,1.0});
    CGContextFillRect(context, topLineRect);
}

@end
