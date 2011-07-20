//
//  SCAccount+Private.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 18.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCAccount.h"

#pragma mark Notifications

extern NSString * const SCAccountDidChangeUserInfoNotification;

#pragma mark -

@interface SCAccount (Private)

@property (nonatomic, readonly) NXOAuth2Account *oauthAccount;
@property (nonatomic, copy) NSDictionary *userInfo;
- (id)initWithOAuthAccount:(NXOAuth2Account *)account;

@end
