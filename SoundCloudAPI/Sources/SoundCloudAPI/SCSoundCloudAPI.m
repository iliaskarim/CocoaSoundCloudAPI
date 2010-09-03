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


#import "NXOAuth2Client.h"
#import "NXOAuth2PostBodyStream.h"
#import "NSMutableURLRequest+NXOAuth2.h"

#import "SCAPIErrors.h"
#import "SCSoundCloudConnection.h"
#import "SCSoundCloudAPIConfiguration.h"

#import "NSString+SoundCloudAPI.h"

#import "SCSoundCloudAPI.h"


@interface SCSoundCloudAPI () <NXOAuth2ConnectionDelegate, NXOAuth2ClientAuthDelegate>
- (NSString *)_responseTypeFromEnum:(SCResponseFormat)responseFormat;
@end


@implementation SCSoundCloudAPI

#pragma mark Lifecycle

- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)inAuthDelegate
					apiConfiguration:(SCSoundCloudAPIConfiguration *)aConfiguration;
{
	if (self = [super init]) {
		responseFormat = SCResponseFormatXML;
		
		configuration = [aConfiguration retain];
		authDelegate = inAuthDelegate;
		
		oauthClient = [[NXOAuth2Client alloc] initWithClientID:[configuration consumerKey]
												  clientSecret:[configuration consumerSecret]
												  authorizeURL:[configuration authURL]
													  tokenURL:[configuration accessTokenURL]
												  authDelegate:self];
		
	}
	return self;
}

- (void)dealloc;
{
	[configuration release];
	oauthClient.authDelegate = nil;
	[oauthClient release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize authDelegate;
@synthesize responseFormat;
@synthesize isAuthenticated;


#pragma mark Public methods

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
	[oauthClient authorizeWithUsername:username password:password];
}

#pragma mark Pirivate methods

- (NSString *)_responseTypeFromEnum:(SCResponseFormat)inResponseFormat;
{
	switch (inResponseFormat) {
		case SCResponseFormatJSON:
			return @"application/json";
		case SCResponseFormatXML:
		default:
			return @"application/xml";
	}	
}

#pragma mark API method

- (SCSoundCloudConnection *)performMethod:(NSString *)httpMethod
							   onResource:(NSString *)resource
						   withParameters:(NSDictionary *)parameters
								  context:(id)context
					   connectionDelegate:(NSObject<SCSoundCloudConnectionDelegate> *)connectionDelegate;
{
	if (!configuration.apiBaseURL) {
		NSLog(@"API is not configured with base URL");
		return nil;
	}
	
	NSURL *url = [NSURL URLWithString:resource relativeToURL:configuration.apiBaseURL];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[request addValue:[self _responseTypeFromEnum:self.responseFormat] forHTTPHeaderField:@"Accept"];
	
	[request setHTTPMethod:[httpMethod uppercaseString]];
	if ((![[httpMethod uppercaseString] isEqualToString:@"POST"]
		 && ![[httpMethod uppercaseString] isEqualToString:@"PUT"])
		|| parameters.count == 0) {
		[request setParameters:parameters];
	} else {
		NXOAuth2PostBodyStream *postStream = [[NXOAuth2PostBodyStream alloc] initWithParameters:parameters];
		[request setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [postStream boundary]] forHTTPHeaderField: @"Content-Type"];
		[request setValue:[NSString stringWithFormat:@"%d", [postStream length]] forHTTPHeaderField:@"Content-Length"];
		
		[request setHTTPBodyStream:postStream];
		[postStream release];
	}
	
	return [SCSoundCloudConnection connectionWithRequest:request oauthClient:oauthClient context:context connectionDelegate:connectionDelegate];
}


#pragma mark NXOAuth2ClientAuthDelegate

- (void)oauthClientRequestedAuthorization:(NXOAuth2Client *)client;
{
	NSURL *authorizationURL = nil;
	if ([configuration callbackURL]) {
		authorizationURL = [client authorizationURLWithRedirectURL:[configuration callbackURL]];
	}
	[authDelegate soundCloudAPI:self preparedAuthorizationURL:authorizationURL];
}

- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client;
{
	self.isAuthenticated = NO;
	[authDelegate soundCloudAPIDidResetAuthentication:self];
}

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client;
{
	self.isAuthenticated = YES;
	[authDelegate soundCloudAPIDidAuthenticate:self];
}

- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error;
{
	[authDelegate soundCloudAPI:self didFailToGetAccessTokenWithError:error];
}


@end

