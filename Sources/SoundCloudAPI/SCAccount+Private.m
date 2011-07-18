//
//  SCAccount+Private.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 18.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import "SCAccount+Private.h"

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

@end
