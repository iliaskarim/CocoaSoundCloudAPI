//
//  GPCellLoader.m
//  Monopol
//
//  Created by Gernot Poetsch on 16.02.09.
//  Copyright 2009 Gernot Poetsch. All rights reserved.
//

#import "GPCellLoader.h"


@implementation GPCellLoader

#pragma mark Lifecycle

- (id)initWithNibNamed:(NSString *)nibName;
{
	if ((self = [super init])) {
		nib = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] retain];
	}
	return self;
}

- (void)dealloc;
{
	[nib release];
	[super dealloc];
}

#pragma mark Accessors

- (UITableViewCell *)cell;
{
	return cell;
}

@end
