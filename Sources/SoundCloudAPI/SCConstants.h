//
//  SCConstants.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 18.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Notifications

extern NSString * const SCAccountCreated;
extern NSString * const SCAccountRemoved;

extern NSString * const SCSoundCloudDidFailToRequestAccess;

extern NSString * const SCAccountDidChangeUserInfo;
extern NSString * const SCAccountDidFailToGetAccessToken;


#pragma mark OAuth2 Configuration

extern NSString * const kSCAccountType;

extern NSString * const kSCConfigurationClientID;
extern NSString * const kSCConfigurationSecret;
extern NSString * const kSCConfigurationRedirectURL;
extern NSString * const kSCConfigurationSandbox;
extern NSString * const kSCConfigurationAPIURL;
extern NSString * const kSCConfigurationAuthorizeURL;
