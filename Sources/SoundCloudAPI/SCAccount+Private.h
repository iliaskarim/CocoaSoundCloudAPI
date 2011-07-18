//
//  SCAccount+Private.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 18.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCAccount.h"

@interface SCAccount (Private)

@property (nonatomic, readonly) NXOAuth2Account *oauthAccount;
- (id)initWithOAuthAccount:(NXOAuth2Account *)account;

@end
