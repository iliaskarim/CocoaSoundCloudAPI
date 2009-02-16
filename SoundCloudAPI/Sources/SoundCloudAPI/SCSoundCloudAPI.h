/*
 Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
 All rights reserved.
 
 This file is part of SoundCloudAPI.
 
 SoundCloudAPI is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published
 by the Free Software Foundation, version 3.
 
 SoundCloudAPI is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with SoundCloudAPI. If not, see <http://www.gnu.org/licenses/>.
 
 For more information and documentation refer to <http://soundcloud.com/api>.
 */

#import <Foundation/Foundation.h>

#import "SCDataFetcher.h"

@class SCSoundCloudAPIConfiguration;
@class OAConsumer;
@class OADataFetcher;
@class OAToken;
@protocol SCSoundCloudAPIDelegate;
@protocol SCSoundCloudAPIAuthenticationDelegate;


typedef enum {
	SCAuthenticationStatusNotAuthenticated,			// api is not authenticated. -> requestAuthentication
	SCAuthenticationStatusAuthenticated,			// api is authenticated and ready to use
	SCAuthenticationStatusGettingToken,				// wait till 
	SCAuthenticationStatusWillAuthorizeRequestToken	// got request token. need to authenticate it. -> authorizeRequestToken
} SCAuthenticationStatus;

typedef enum {
	SCResponseFormatXML,
	SCResponseFormatJSON
} SCResponseFormat;


@interface SCSoundCloudAPI : NSObject <SCDataFetcherDelegate> {
	OAConsumer *_oauthConsumer;
	
	id<SCSoundCloudAPIDelegate> delegate;
	id<SCSoundCloudAPIAuthenticationDelegate> authDelegate;
	NSMutableArray *_dataFetchers;
	OADataFetcher *_authDataFetcher;
	
	OAToken *_requestToken;
	OAToken *_accessToken;
	SCAuthenticationStatus status;
	SCResponseFormat responseFormat;
}

@property (nonatomic, assign) id<SCSoundCloudAPIDelegate> delegate;
@property (nonatomic, assign) id<SCSoundCloudAPIAuthenticationDelegate> authDelegate;
@property (readonly) SCAuthenticationStatus status;
@property SCResponseFormat responseFormat;

- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)authDelegate;

// API Authentication

/*!
 * sends request for unauthenticated request token and tries to authenticate it
 * if no error occures, results in the authentication delegate beeing requested to open token authentication url
 */
- (void)requestAuthentication;

/*!
 * sends request token to server for authentication.
 * if no error, sets the access token.
 */
- (void)authorizeRequestToken;

/*!
 * resets all tokens to nil, and removes them from the keychain
 */
- (void)resetAuthentication;


// API method
- (void)performMethod:(NSString *)httpMethod
		   onResource:(NSString *)resource
	   withParameters:(NSDictionary *)parameters
			  context:(id)targetContext;

@end


@protocol SCSoundCloudAPIAuthenticationDelegate <NSObject>
- (SCSoundCloudAPIConfiguration *)configurationForSoundCloudAPI:(SCSoundCloudAPI *)scAPI;
- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI requestedAuthenticationWithURL:(NSURL *)authURL;
- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI didChangeAuthenticationStatus:(SCAuthenticationStatus)status;
@end


@protocol SCSoundCloudAPIDelegate <NSObject>
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didFinishWithData:(NSData *)data context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didFailWithError:(NSError *)error context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveData:(NSData *)data context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveBytes:(UInt32)loadedBytes total:(UInt32)totalBytes context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didSendBytes:(UInt32)sendBytes total:(UInt32)totalBytes context:(id)context;
@end