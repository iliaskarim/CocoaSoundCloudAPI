//
//  SCRequest.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCRequestResponseHandler)(NSURLResponse *response, NSData *responseData, NSError *error);
typedef void(^SCRequestSendingProgressHandler)(unsigned long long bytesSend, unsigned long long bytesTotal);

enum SCRequestMethod {
    SCRequestMethodGET = 0,
    SCRequestMethodPOST,
    SCRequestMethodPUT,
    SCRequestMethodDELETE
};
typedef enum SCRequestMethod SCRequestMethod;

@class NXOAuth2Request;
@class SCAccount;

@interface SCRequest : NSObject {
@private
    NXOAuth2Request *oauthRequest;
}

#pragma mark Class Methods

+ (id)   performMethod:(SCRequestMethod)aMethod
            onResource:(NSURL *)resource
       usingParameters:(NSDictionary *)parameters
           withAccount:(SCAccount *)account
sendingProgressHandler:(SCRequestSendingProgressHandler)progressHandler
       responseHandler:(SCRequestResponseHandler)responseHandler;

+ (void)cancelRequest:(id)request;

+ (SCRequest *)request;

#pragma mark Accessors

@property (nonatomic, readwrite, retain) SCAccount *account;

@property (nonatomic, assign) SCRequestMethod requestMethod;
@property (nonatomic, readwrite, retain) NSURL *resource;
@property (nonatomic, readwrite, retain) NSDictionary *parameters;

@property (nonatomic, copy) SCRequestResponseHandler responseHandler;
@property (nonatomic, copy) SCRequestSendingProgressHandler sendProgressHandler;


#pragma mark Signed NSURLRequest

- (NSURLRequest *)signedRequest;

#pragma mark Perform Request

- (void)performRequest;

#pragma Cancel Request

- (void)cancel;

@end
