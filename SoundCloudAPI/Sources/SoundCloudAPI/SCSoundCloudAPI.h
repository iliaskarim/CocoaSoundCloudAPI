/*
 * Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
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

#import <Foundation/Foundation.h>

#import "NXOAuth2Connection.h"
#import "NXOAuth2ConnectionDelegate.h"
#import "NXOAuth2Client.h"
#import "NXOAuth2PostBodyStream.h"
#import "NSMutableURLRequest+NXOAuth2.h"


@class SCSoundCloudAPIConfiguration;
@class NXOAuth2Client;
@class NXOAuth2Connection;
@protocol SCSoundCloudAPIDelegate;
@protocol SCSoundCloudAPIAuthenticationDelegate;

typedef enum {
	SCAuthenticationStatusNotAuthenticated,				// api is not authenticated. -> requestAuthentication
	SCAuthenticationStatusAuthenticated,				// api is authenticated and ready to use
	SCAuthenticationStatusGettingToken,					// wait till
	SCAuthenticationStatusWillAuthorizeRequestToken,	// got request token. need to authenticate it. -> authorizeRequestToken
	SCAuthenticationStatusCannotAuthenticate			// error occured during token exchange
} SCAuthenticationStatus;

typedef enum {
	SCResponseFormatXML,
	SCResponseFormatJSON
} SCResponseFormat;


@interface SCSoundCloudAPI : NSObject <NXOAuth2ConnectionDelegate, NXOAuth2ClientAuthDelegate> {
	NXOAuth2Client *oauthClient;
	
	id<SCSoundCloudAPIDelegate> delegate;
	id<SCSoundCloudAPIAuthenticationDelegate> authDelegate;
	NSMutableDictionary *_dataFetchers;
	
	SCAuthenticationStatus status;
	SCResponseFormat responseFormat;
}

@property (nonatomic, assign) id<SCSoundCloudAPIDelegate> delegate;
@property (nonatomic, assign) id<SCSoundCloudAPIAuthenticationDelegate> authDelegate;
@property SCResponseFormat responseFormat;

/*!
 * initialize the api object
 */
- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)authDelegate; // tokenVerifier = nil

/*!
 * resets token to nil, and removes it from the keychain
 */
- (void)resetAuthentication;

/*!
 * invokes a request using the specified HTTP method on the specified resource
 * returns a request identifier which can be used to cancel the request.
 * returns nil if an error occured
 */
- (id)performMethod:(NSString *)httpMethod
		 onResource:(NSString *)resource
	 withParameters:(NSDictionary *)parameters
			context:(id)targetContext;

/*!
 * cancels the request with the particular request identifier
 */
- (void)cancelRequest:(id)requestIdentifier;

- (BOOL)openRedirectURL:(NSURL *)URL;
@end


@protocol SCSoundCloudAPIAuthenticationDelegate <NSObject>
- (SCSoundCloudAPIConfiguration *)configurationForSoundCloudAPI:(SCSoundCloudAPI *)scAPI;
- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI requestedAuthenticationWithURL:(NSURL *)authURL;
- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI didChangeAuthenticationStatus:(SCAuthenticationStatus)status;
- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI didEncounterError:(NSError *)error;
@end


@protocol SCSoundCloudAPIDelegate <NSObject>
@optional
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didFinishWithData:(NSData *)data context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didFailWithError:(NSError *)error context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didCancelRequestWithContext:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveData:(NSData *)data context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
- (void)soundCloudAPI:(SCSoundCloudAPI *)api didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
@end