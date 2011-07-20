//
//  SCAccount+Private.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 18.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "SCSoundCloud.h"
#import "SCRequest.h"
#import "SCConstants.h"

#import "SCAccount+Private.h"

#pragma mark Notifications

NSString * const SCAccountDidChangeUserInfo = @"SCAccountDidChangeUserInfo";

#pragma mark -

@implementation SCAccount (Private)

- (id)initWithOAuthAccount:(NXOAuth2Account *)anAccount;
{
    self = [super init];
    if (self) {
        oauthAccount = [anAccount retain];
    }
    return self;
}

- (NXOAuth2Account *)oauthAccount;
{
    return oauthAccount;
}

- (void)setOauthAccount:(NXOAuth2Account *)anOAuthAccount;
{
    [anOAuthAccount retain];
    [oauthAccount release];
    oauthAccount = anOAuthAccount;
}

- (NSDictionary *)userInfo;
{
    return (NSDictionary *)self.oauthAccount.userData;
}

- (void)setUserInfo:(NSDictionary *)userInfo;
{
    self.oauthAccount.userData = userInfo;
}

@end
