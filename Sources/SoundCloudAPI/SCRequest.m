/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
 */

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "SCAccount.h"
#import "SCAccount+Private.h"
#import "SCConstants.h"

#import "SCRequest.h"

@interface SCRequest ()
@property (nonatomic, retain) NXOAuth2Request *oauthRequest;
@end

@implementation SCRequest

#pragma mark Class Methods

+ (id)   performMethod:(SCRequestMethod)aMethod
            onResource:(NSURL *)aResource
       usingParameters:(NSDictionary *)someParameters
           withAccount:(SCAccount *)anAccount
sendingProgressHandler:(SCRequestSendingProgressHandler)aProgressHandler
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
    r.responseHandler = aResponseHandler;
    r.sendProgressHandler = aProgressHandler;
    [r performRequest];
    return r;
}

+ (void)cancelRequest:(id)request;
{
    if ([request isKindOfClass:[NXOAuth2Request class]] ||
        [request isKindOfClass:[SCRequest class]]) {
        [request cancel];
    }
}

+ (SCRequest *)request;
{
    return [[self new] autorelease];
}

#pragma mark Accessors

@synthesize oauthRequest;

- (SCAccount *)account;
{
    if (self.oauthRequest.account) {
        return [[[SCAccount alloc] initWithOAuthAccount:self.oauthRequest.account] autorelease];
    } else {
        return nil;
    }
}

- (void)setAccount:(SCAccount *)account;
{
    self.oauthRequest.account = account.oauthAccount;
}

- (SCRequestMethod)requestMethod;
{
    NSString *aMethod = self.oauthRequest.requestMethod;
    
    if ([aMethod caseInsensitiveCompare:@"POST"]) {
        return SCRequestMethodPOST;
    } else if ([aMethod caseInsensitiveCompare:@"PUT"]) {
        return SCRequestMethodPUT;
    } else if ([aMethod caseInsensitiveCompare:@"DELETE"]) {
        return SCRequestMethodDELETE;
    } else {
        NSAssert([aMethod caseInsensitiveCompare:@"GET"], @"SCRequest only supports 'GET', 'PUT', 'POST' and 'DELETE' as request method. Underlying NXOAuth2Accound uses the request method 'l%'.", aMethod);
        return SCRequestMethodGET;
    }
}

- (void)setRequestMethod:(SCRequestMethod)requestMethod;
{
    NSString *theMethod;
    switch (requestMethod) {
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
    self.oauthRequest.requestMethod = theMethod;
}

- (NSURL *)resource;
{
    return self.oauthRequest.resource;
}

- (void)setResource:(NSURL *)resource;
{
    self.oauthRequest.resource = resource;
}

- (NSDictionary *)parameters;
{
    return self.oauthRequest.parameters;
}

- (void)setParameters:(NSDictionary *)parameters;
{
    self.oauthRequest.parameters = parameters;
}

- (SCRequestResponseHandler)responseHandler;
{
    return self.oauthRequest.responseHandler;
}

- (void)setResponseHandler:(SCRequestResponseHandler)responseHandler;
{
    self.oauthRequest.responseHandler = responseHandler;
}

- (SCRequestSendingProgressHandler)sendProgressHandler;
{
    return self.oauthRequest.sendProgressHandler;
}

- (void)setSendProgressHandler:(SCRequestSendingProgressHandler)sendProgressHandler;
{
    self.oauthRequest.sendProgressHandler = sendProgressHandler;
}


#pragma mark Signed NSURLRequest

- (NSURLRequest *)signedRequest;
{
    return [self.oauthRequest signedURLRequest];
}


#pragma mark Perform Request

- (void)performRequest;
{
    [self.oauthRequest performRequest];
}

- (void)cancel;
{
    [self.oauthRequest cancel];
}

@end
