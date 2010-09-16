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

#import "NXOAuth2.h"

#import "SCSoundCloudAPIConfiguration.h"
#import "SCSoundCloudAPIAuthenticationDelegate.h"

#import "SCSoundCloudAPIAuthentication.h"


@interface SCSoundCloudAPIAuthentication () <NXOAuth2ClientDelegate>
@property (assign, getter=isAuthenticated) BOOL authenticated;
@end


@implementation SCSoundCloudAPIAuthentication

#pragma mark Lifecycle

- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)inAuthDelegate
					apiConfiguration:(SCSoundCloudAPIConfiguration *)aConfiguration;
{
	if (self = [super init]) {
		authDelegate = inAuthDelegate;
		configuration = [aConfiguration retain];
		
		oauthClient = [[NXOAuth2Client alloc] initWithClientID:[configuration consumerKey]
												  clientSecret:[configuration consumerSecret]
												  authorizeURL:[configuration authURL]
													  tokenURL:[configuration accessTokenURL]
													  delegate:self];
	}
	return self;
}

- (void)dealloc;
{
	[configuration release];
	[oauthClient release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize oauthClient;
@synthesize configuration;
@synthesize authenticated;


#pragma mark Public

- (void)requestAuthentication;
{
	[oauthClient requestAccess];
}

- (void)resetAuthentication;
{
	oauthClient.accessToken = nil;
}

- (BOOL)handleOpenRedirectURL:(NSURL *)redirectURL;
{
	return [oauthClient openRedirectURL:redirectURL];
}

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password;
{
	[oauthClient authenticateWithUsername:username password:password];
}


#pragma mark NXOAuth2ClientAuthDelegate

- (void)oauthClientNeedsAuthorization:(NXOAuth2Client *)client;
{
	NSURL *authorizationURL = nil;
	if ([configuration callbackURL]) {
		authorizationURL = [client authorizationURLWithRedirectURL:[configuration callbackURL]];
	}
	[authDelegate soundCloudAPIPreparedAuthorizationURL:authorizationURL];
}

- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client;
{
	self.authenticated = NO;
	[authDelegate soundCloudAPIDidResetAuthentication];
}

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client;
{
	self.authenticated = YES;
	[authDelegate soundCloudAPIDidAuthenticate];
}

- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error;
{
	[authDelegate soundCloudAPIDidFailToGetAccessTokenWithError:error];
}


@end
