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

+ (id)   performMethod:(SCRequestMethod)aMethod
            onResource:(NSURL *)aResource
       usingParameters:(NSDictionary *)someParameters
           withAccount:(SCAccount *)anAccount
sendingProgressHandler:(SCRequestProgressHandler)aProgressHandler
       responseHandler:(SCRequestResponseHandler)aResponseHandler;
{
    NSString *theMethod;
    switch (aMethod) {
        case SCRequestMethodPOST:
            theMethod = @"POST";
            break;
            
        case SCRequestMethodPUT:
            theMethod = @"PUT";
            break;
            
        case SCRequestMethodDELETE:
            theMethod = @"DELETE";
            break;
            
        default:
            theMethod = @"GET";
            break;
    }
    
    NSAssert([[aResource scheme] isEqualToString:@"https"], @"Resource '%@' is invalid because the scheme is not 'https'.", aResource);
    
    NXOAuth2Request *r = [NXOAuth2Request requestOnResource:aResource withMethod:theMethod usingParameters:someParameters];
    r.account = anAccount.oauthAccount;
    [r performRequestWithResponseHandler:aResponseHandler sendProgressHandler:aProgressHandler];
    return r;
}

+ (void)cancelRequest:(id)request;
{
    if ([request isKindOfClass:[NXOAuth2Request class]]) {
        [request cancel];
    }
}

@end
