//
//  SCNameAndEmailCell.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 18.09.09.
//  Copyright 2009 nxtbgthng. All rights reserved.
//

#import "UIColor+SoundCloudAPI.h"

#import "SCNameAndEmailCell.h"

@interface SCNameAndEmailCell ()
@property (nonatomic, assign) UILabel *nameLabel;
@property (nonatomic, assign) UILabel *emailLabel;
@property (nonatomic, assign) UILabel *mailTypeLabel;
@end

@implementation SCNameAndEmailCell

#pragma mark Lifecycle

- (id)init;
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.nameLabel = [[[UILabel alloc] init] autorelease];
        self.nameLabel.opaque = NO;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        
        self.emailLabel = [[[UILabel alloc] init] autorelease];
        self.emailLabel.opaque = NO;
        self.emailLabel.textColor = [UIColor listSubtitleColor];
        self.emailLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.emailLabel];
        
        self.mailTypeLabel = [[[UILabel alloc] init] autorelease];
        self.mailTypeLabel.opaque = NO;
        self.mailTypeLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.mailTypeLabel.textColor = [UIColor listSubtitleColor];
        self.mailTypeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mailTypeLabel];
    }
    return self;
}

#pragma mark Accessors

@synthesize nameLabel;
@synthesize emailLabel;
@synthesize mailTypeLabel;

- (NSString *)name;
{
	return nameLabel.text;
}

- (NSString *)email;
{
	return emailLabel.text;
}

- (NSString *)mailType;
{
	return mailTypeLabel.text;
}

- (void)setName:(NSString *)value;
{
	nameLabel.text = value;
}

- (void)setEmail:(NSString *)value;
{
	emailLabel.text = value;
}

- (void)setMailType:(NSString *)value;
{
	mailTypeLabel.text = value;
}

#pragma mark View

- (void)layoutSubviews;
{
    [super layoutSubviews];
    self.nameLabel.frame = CGRectMake(11, 2, 289, 21);
    self.emailLabel.frame = CGRectMake(76, 20, 224, 21);
    self.mailTypeLabel.frame = CGRectMake(11, 20, 57, 21);
}

@end
