//
//  SCRequest.m
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

#import "SCAccount.h"
#import "SCAccount+Private.h"
#import "SCConstants.h"

#import "SCRequest.h"

@implementation SCRequest

+ (void)performMethod:(NSString *)aMethod
           onResource:(NSURL *)aResource
      usingParameters:(NSDictionary *)someParameters
          withAccount:(SCAccount *)anAccount
      responseHandler:(SCRequestResponseHandler)aResponseHandler;
{
    NXOAuth2Request *r = [NXOAuth2Request requestOnResource:aResource withMethod:aMethod usingParameters:someParameters];
    r.account = anAccount.oauthAccount;
    [r performRequestWithResponseHandler:aResponseHandler];
}

+ (void)performMethod:(NSString *)aMethod
           onResource:(NSURL *)aResource
      usingParameters:(NSDictionary *)someParameters
          withAccount:(SCAccount *)anAccount
  sendProgressHandler:(SCRequestProgressHandler)aProgressHandler
      responseHandler:(SCRequestResponseHandler)aResponseHandler;
{
    NXOAuth2Request *r = [NXOAuth2Request requestOnResource:aResource withMethod:aMethod usingParameters:someParameters];
    r.account = anAccount.oauthAccount;
    [r performRequestWithResponseHandler:aResponseHandler sendProgressHandler:aProgressHandler];
}

@end
