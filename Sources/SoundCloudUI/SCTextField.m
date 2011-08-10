//
//  SCTextField.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 04.08.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCTextField.h"
#import "UIColor+SoundCloudAPI.h"

@implementation SCTextField

- (void)drawPlaceholderInRect:(CGRect)rect;
{
    [[UIColor listSubtitleColor] setFill];
    [self.placeholder drawInRect:rect withFont:self.font];
}

@end
