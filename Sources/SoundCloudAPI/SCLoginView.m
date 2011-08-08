//
//  SCLoginView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 05.08.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCLoginView.h"

@interface SCLoginView ()
@property (nonatomic, readwrite, assign) UIButton *login;
@end

@implementation SCLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.login = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
        [self.login setTitle:@"Go" forState:UIControlStateNormal];
        self.login.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:self.login];
        
        self.login.center = self.center;
        
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

#pragma mark Accessors

@synthesize login;

@end
