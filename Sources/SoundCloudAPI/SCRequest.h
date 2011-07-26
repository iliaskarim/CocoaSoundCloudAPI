//
//  SCRequest.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCRequestResponseHandler)(NSURLResponse *response, NSData *responseData, NSError *error);
typedef void(^SCRequestProgressHandler)(unsigned long long bytesSend, unsigned long long bytesTotal);

enum SCRequestMethod {
    SCRequestMethodGET = 0,
    SCRequestMethodPOST,
    SCRequestMethodPUT,
    SCRequestMethodDELETE
};
typedef enum SCRequestMethod SCRequestMethod;

@class SCAccount;

@interface SCRequest : NSObject

+ (id)   performMethod:(SCRequestMethod)aMethod
            onResource:(NSURL *)resource
       usingParameters:(NSDictionary *)parameters
           withAccount:(SCAccount *)account
sendingProgressHandler:(SCRequestProgressHandler)progressHandler
       responseHandler:(SCRequestResponseHandler)responseHandler;

+ (void)cancelRequest:(id)request;

@end
