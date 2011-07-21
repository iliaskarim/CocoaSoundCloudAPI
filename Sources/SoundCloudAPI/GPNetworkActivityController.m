//
//  GPNetworkActivityController.m
//
//  Created by Gernot Poetsch on 19.07.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

#import "GPNetworkActivityController.h"


@implementation GPNetworkActivityController

#pragma mark Singleton
static GPNetworkActivityController *sharedActivityController = nil;

+ (GPNetworkActivityController *)sharedActivityController;
{
	//Static Code analyzer thinks we leak here. Hes's right, but we intend so
    @synchronized(@"ActivityControllerLock") {
        if (sharedActivityController == nil) {
            sharedActivityController = [[super allocWithZone:NULL] init]; // assignment not done here
        }
    }
    return sharedActivityController;
}


#pragma mark Lifecycle

- (id)init;
{
	if (![super init]) return nil;
	numberOfActiveTransmissions = 0;
	return self;
}

#pragma mark Accessors

@synthesize numberOfActiveTransmissions;

- (void)increaseNumberOfActiveTransmissions;
{
	numberOfActiveTransmissions++;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)decreaseNumberOfActiveTransmissions;
{
	if (numberOfActiveTransmissions > 0) numberOfActiveTransmissions--;
	if (numberOfActiveTransmissions == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

@end
