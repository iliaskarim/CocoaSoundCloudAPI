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


@protocol SCSoundCloudAPIAuthenticationDelegate;
@class SCSoundCloudAPIConfiguration;
@class NXOAuth2Client;

@interface SCSoundCloudAPIAuthentication : NSObject {
	SCSoundCloudAPIConfiguration *configuration;
	
	NXOAuth2Client *oauthClient;
	id<SCSoundCloudAPIAuthenticationDelegate> authDelegate;	// assigned
	BOOL authenticated;
}

@property (readonly) NXOAuth2Client *oauthClient;
@property (readonly, getter=isAuthenticated) BOOL authenticated;
@property (readonly) SCSoundCloudAPIConfiguration *configuration;

- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)authDelegate
					apiConfiguration:(SCSoundCloudAPIConfiguration *)configuration;


- (void)requestAuthentication;
- (void)resetAuthentication;
- (BOOL)handleOpenRedirectURL:(NSURL *)redirectURL;
- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password;

@end
