//
//  SCSoundCloud.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Notifications

extern NSString * const SCSoundCloudDidCreateAccountNotification;
extern NSString * const SCSoundCloudDidRemoveAccountNotification;
extern NSString * const SCSoundCloudDidFailToRequestAccess;


#pragma mark Handler

typedef void(^SCPreparedAuthorizationURLHandler)(NSURL *preparedURL);


#pragma mark -


@class SCAccount;

@interface SCSoundCloud : NSObject {
@private
    id accountStoreDidCreateAccountObserver;
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

- (void)setClientID:(NSString *)aClientID
             secret:(NSString *)aSecret
        redirectURL:(NSURL *)aRedirectURL;

@property (nonatomic, readonly) NSDictionary *configuration;


#pragma mark Prepared Authorization URL Handler

- (void)setPreparedAuthorizationURLHandler:(SCPreparedAuthorizationURLHandler)handler;
- (SCPreparedAuthorizationURLHandler)preparedAuthorizationURLHandler;


#pragma mark OAuth2 Flow

- (BOOL)handleRedirectURL:(NSURL *)URL;

@end
