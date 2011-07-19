//
//  SCSoundCloud+Private.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 19.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import "SCSoundCloud.h"

@interface SCSoundCloud (Private)

#pragma mark Manage Accounts

- (void)requestAccessWithUsername:(NSString *)username password:(NSString *)password;

@end
