//
//  SCAccount.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Notifications

extern NSString * const SCAccountDidFailToGetAccessToken;

@class NXOAuth2Account;

@interface SCAccount : NSObject {
@private
    NXOAuth2Account *oauthAccount;
}

#pragma mark Accessors

@property (nonatomic, readonly) NSString *identifier;

@end
