//
//  SCConstants.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 18.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import "SCConstants.h"

#pragma mark Notifications

NSString * const SCAccountCreated = @"SCAccountCreated";
NSString * const SCAccountRemoved = @"SCAccountRemoved";

NSString * const SCSoundCloudDidFailToRequestAccess = @"SCSoundCloudDidFailToRequestAccess";

NSString * const SCAccountDidChangeUserInfo = @"SCAccountDidChangeUserInfo";
NSString * const SCAccountDidChangeAccessToken = @"SCAccountDidChangeAccessToken";
NSString * const SCAccountDidFailToGetAccessToken = @"SCAccountDidFailToGetAccessToken";

#pragma mark OAuth2 Configuration

NSString * const kSCAccountType = @"com.soundcloud.api";

NSString * const kSCConfigurationClientID = @"kSCConfigurationClientID";
NSString * const kSCConfigurationSecret = @"kSCConfigurationSecret";
NSString * const kSCConfigurationRedirectURL = @"kSCConfigurationRedirectURL";
NSString * const kSCConfigurationSandbox = @"kSCConfigurationSandbox";
NSString * const kSCConfigurationAPIURL = @"kSCConfigurationAPIURL";
