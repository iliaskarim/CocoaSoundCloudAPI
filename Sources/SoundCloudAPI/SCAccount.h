//
//  SCAccount.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXOAuth2Account;

@interface SCAccount : NSObject {
@private
    NXOAuth2Account *oauthAccount;
}

#pragma mark Accessors

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, copy) NSDictionary *userInfo;

- (void)fetchUserInfoWithCompletionHandler:(void(^)(BOOL success, SCAccount *account, NSError * error))handler;

@end
