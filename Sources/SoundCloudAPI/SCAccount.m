//
//  SCAccount.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "SCAccount+Private.h"
#import "SCAccount.h"

#pragma mark Notifications

NSString * const SCAccountDidFailToGetAccessToken = @"SCAccountDidFailToGetAccessToken";

#pragma mark -

@implementation SCAccount

- (void)dealloc;
{
    [oauthAccount release];
    [super dealloc];
}

#pragma mark Accessors

- (NSString *)identifier;
{
    return self.oauthAccount.identifier;
}

@end
