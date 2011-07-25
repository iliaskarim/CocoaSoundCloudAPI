//
//  SCNameAndEmailCell.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 18.09.09.
//  Copyright 2009 nxtbgthng. All rights reserved.
//

#import "SCNameAndEmailCell.h"


@implementation SCNameAndEmailCell

#pragma mark Lifecycle

- (void)awakeFromNib;
{
	[super awakeFromNib];
	
	// is everything linked
	if (!(nameLabel
		  && emailLabel
		  && mailTypeLabel)) {
		NSLog(@"check references in SCNameAndEmailCell nib file");
	}
}

#pragma mark Accessors

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


@end
