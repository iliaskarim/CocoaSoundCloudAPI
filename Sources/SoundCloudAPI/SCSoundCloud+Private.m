//
//  SCSoundCloud+Private.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 19.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "SCConstants.h"

#import "SCSoundCloud+Private.h"

@implementation SCSoundCloud (Private)

- (void)requestAccessWithUsername:(NSString *)username password:(NSString *)password;
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kSCAccountType username:username password:password];
}

@end
