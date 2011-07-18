//
//  SCRequest.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCRequestResponseHandler)(NSData *responseData, NSError *error);
typedef void(^SCRequestProgressHandler)(unsigned long long bytesSend, unsigned long long bytesTotal);

@class SCAccount;

@interface SCRequest : NSObject

+ (void)requestWithPath:(NSString *)path
             parameters:(NSDictionary *)parameters
          requestMethod:(NSString *)requestMethod
                account:(SCAccount *)account
        responseHandler:(SCRequestResponseHandler)responseHandler;

+ (void)requestWithPath:(NSString *)path
             parameters:(NSDictionary *)parameters
          requestMethod:(NSString *)requestMethod
                account:(SCAccount *)account
        progressHandler:(SCRequestProgressHandler)progressHandler
        responseHandler:(SCRequestResponseHandler)responseHandler;

@end
