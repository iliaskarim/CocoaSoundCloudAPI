//
//  SCSoundCloud.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCPreparedAuthorizationURLHandler)(NSURL *preparedURL);


@class SCAccount;

@interface SCSoundCloud : NSObject {
@private
    id accountAccountCreatedObserver;
    id accountDidFailToGetAccessTokenObserver;
}

+ (SCSoundCloud *)shared;

#pragma mark Accessors

@property(nonatomic, readonly) NSArray *accounts;
- (SCAccount *)accountWithIdentifier:(NSString *)identifier;


#pragma mark Manage Accounts

- (void)requestAccess;
- (void)removeAccount:(SCAccount *)account;


#pragma mark Configuration

@property (nonatomic, copy) NSDictionary *configuration;


#pragma mark Prepared Authorization URL Handler

- (void)setPreparedAuthorizationURLHandler:(SCPreparedAuthorizationURLHandler)handler;
- (SCPreparedAuthorizationURLHandler)preparedAuthorizationURLHandler;


#pragma mark OAuth2 Flow

- (BOOL)handleRedirectURL:(NSURL *)URL;

@end
