/*
 * Copyright 2010 nxtbgthng for SoundCloud Ltd.
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

@class NXOAuth2Client;
@class SCSoundCloudAPIConfiguration, SCSoundCloudConnection;
@class SCSoundCloudAPIAuthentication;
@protocol SCSoundCloudAPIAuthenticationDelegate, SCSoundCloudAPIDelegate;


typedef enum {
	SCResponseFormatXML,
	SCResponseFormatJSON
} SCResponseFormat;


@interface SCSoundCloudAPI : NSObject <NSCopying> {
	SCSoundCloudAPIAuthentication *authentication;
	SCResponseFormat responseFormat;				// default is SCResponseFormatJSON
	
	NSMutableDictionary *apiConnections;
	
	id<SCSoundCloudAPIDelegate> delegate;
}

@property SCResponseFormat responseFormat;
@property (readonly) BOOL isAuthenticated;	// this might change dynamicaly. not observable, atm


/*!
 * initialize the api object
 */
- (id)initWithDelegate:(id<SCSoundCloudAPIDelegate>)delegate
authenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)authDelegate
	  apiConfiguration:(SCSoundCloudAPIConfiguration *)configuration;

/*!
 * pass along an existing api object
 */
- (SCSoundCloudAPI *)copyWithAPIDelegate:(id)apiDelegate;

/*!
 * invokes a request using the specified HTTP method on the specified resource
 * returns a connection identifier that can be used to cancel the connection
 */
- (id)performMethod:(NSString *)httpMethod
		 onResource:(NSString *)resource
	 withParameters:(NSDictionary *)parameters
			context:(id)context;

/*!
 * cancels the connection with the particular connection identifier
 */
- (void)cancelConnection:(id)connectionId;


#pragma mark Authentication

/*!
 * checks if authorized, and if not lets you know in the authDelegate
 */
- (void)requestAuthentication;

/*!
 * resets token to nil, and removes it from the keychain
 */
- (void)resetAuthentication;

/*!
 * When you app recieves the callback via it's callback URL pass it on to this method
 * returns YES if the redirectURL was handled
 */
- (BOOL)handleOpenRedirectURL:(NSURL *)redirectURL;

/*!
 * Use this method to pass Username & Password on Credentials flow
 */
- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password;


@end
