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

+ (void)requestWithPath:(NSString *)aPath
            parameters:(NSDictionary *)parameters
         requestMethod:(NSString *)requestMethod
               account:(SCAccount *)account
       responseHandler:(SCRequestResponseHandler)responseHandler;
{
    NSURL *apiURL = [[[NXOAuth2AccountStore sharedStore] configurationForAccountType:kSCAccountType] objectForKey:kSCConfigurationAPIURL];
    NSURL *url = [NSURL URLWithString:aPath relativeToURL:apiURL];
    
    NXOAuth2Request *r = [NXOAuth2Request requestWithURL:url
                                              parameters:parameters
                                           requestMethod:requestMethod];
    r.account = account.oauthAccount;
    [r performRequestWithResponseHandler:responseHandler];
}

+ (void)requestWithPath:(NSString *)aPath
            parameters:(NSDictionary *)parameters
         requestMethod:(NSString *)requestMethod
               account:(SCAccount *)account
       progressHandler:(SCRequestProgressHandler)aProgressHandler
       responseHandler:(SCRequestResponseHandler)responseHandler;
{
    NSURL *apiURL = [[[NXOAuth2AccountStore sharedStore] configurationForAccountType:kSCAccountType] objectForKey:kSCConfigurationAPIURL];
    NSURL *url = [NSURL URLWithString:aPath relativeToURL:apiURL];
    
    NXOAuth2Request *r = [NXOAuth2Request requestWithURL:url
                                              parameters:parameters
                                           requestMethod:requestMethod];
    r.account = account.oauthAccount;
    [r performRequestWithResponseHandler:responseHandler progressHandler:aProgressHandler];
}

@end
