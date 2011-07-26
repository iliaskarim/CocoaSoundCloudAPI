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
        return kSCRequestMethodPOST;
    } else if ([aMethod caseInsensitiveCompare:@"PUT"]) {
        return kSCRequestMethodPUT;
    } else if ([aMethod caseInsensitiveCompare:@"DELETE"]) {
        return kSCRequestMethodDELETE;
    } else {
        NSAssert([aMethod caseInsensitiveCompare:@"GET"], @"SCRequest only supports 'GET', 'PUT', 'POST' and 'DELETE' as request method. Underlying NXOAuth2Accound uses the request method 'l%'.", aMethod);
        return kSCRequestMethodGET;
    }
}

- (void)setRequestMethod:(SCRequestMethod)requestMethod;
{
    NSString *theMethod;
    switch (requestMethod) {
        case kSCRequestMethodPOST:
            theMethod = @"POST";
            break;
            
        case kSCRequestMethodPUT:
            theMethod = @"PUT";
            break;
            
        case kSCRequestMethodDELETE:
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
