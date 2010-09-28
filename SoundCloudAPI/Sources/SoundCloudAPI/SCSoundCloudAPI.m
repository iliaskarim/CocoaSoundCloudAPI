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

#import "SCSoundCloudAPI.h"

#import "OAuthConsumer.h"

#import "SCAPIErrors.h"
#import "SCSoundCloudAPIConfiguration.h"
#import "SCPostBodyStream.h"
#import "SCDataFetcher.h"

#import "OAToken+Keychain.h"
#import "NSMutableURLRequest+SoundCloudAPI.h"
#import "NSURL+SoundCloudAPI.h"
#import "NSString+SoundCloudAPI.h"


@interface SCSoundCloudAPI (Private)
- (OAToken *)requestToken;
- (void)setRequestToken:(OAToken *)value;
- (OAToken *)accessToken;
- (void)setAccessToken:(OAToken *)value;

- (NSString *)_responseTypeFromEnum:(SCResponseFormat)responseFormat;
- (SCSoundCloudAPIConfiguration *)configuration;
@end

@interface SCSoundCloudAPI (SCDataFetcherDelegate) <SCDataFetcherDelegate>
@end

@implementation SCSoundCloudAPI

#pragma mark Lifecycle

- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)inAuthDelegate;
{
	return [self initWithAuthenticationDelegate:inAuthDelegate tokenVerifier:nil];
}

- (id)initWithAuthenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)inAuthDelegate
					   tokenVerifier:(NSString *)verifier;
{
	if (self = [super init]) {
		authDelegate = inAuthDelegate;
		SCSoundCloudAPIConfiguration *configuration = self.configuration;
		_oauthConsumer = [[OAConsumer alloc] initWithKey:[configuration consumerKey]
												  secret:[configuration consumerSecret]
											 callbackURL:[[configuration callbackURL] absoluteString]];
		_dataFetchers = [[NSMutableDictionary alloc] init];
		responseFormat = SCResponseFormatXML;
		
		if (self.accessToken) {
			// NSLog(@"Authenticated");
			status = SCAuthenticationStatusAuthenticated;
		} else if (self.requestToken && verifier) {
			// NSLog(@"Will verify requesttoken");
			self.requestToken.verifier = verifier;
			status = SCAuthenticationStatusWillAuthorizeRequestToken;
		} else {
			// NSLog(@"Not authenticated");
			status = SCAuthenticationStatusNotAuthenticated;
		}
		if ([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
			[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
		
		if (status == SCAuthenticationStatusAuthenticated) {
			// FIXME: test tokens if they are still valid
		} else if (status == SCAuthenticationStatusNotAuthenticated) {
			[self requestAuthentication];
		} else if (status == SCAuthenticationStatusWillAuthorizeRequestToken) {
			[self authorizeRequestToken];
		}
	}
	return self;
}

- (void)dealloc {
	[_oauthConsumer release];
	[_dataFetchers release];
	//FIXME: remove oauth data fetcher
	[_authDataFetcher release];
	[_requestToken release];
	[_accessToken release];
	[super dealloc];
}

#pragma mark Accessors

@synthesize delegate;
@synthesize authDelegate;
@synthesize status;
@synthesize responseFormat;

- (OAToken *)requestToken;
{
	if (_requestToken) return _requestToken;
	_requestToken = [[OAToken alloc] initWithDefaultKeychainUsingAppName:[[NSBundle mainBundle] bundleIdentifier]
													 serviceProviderName:[NSString stringWithFormat:@"%@_Request", self.configuration.apiBaseURL.host]];
	return _requestToken;
}

- (void)setRequestToken:(OAToken *)value;
{
	SCSoundCloudAPIConfiguration *configuration = self.configuration;
	if (!value) {
		[self.requestToken removeFromDefaultKeychainWithAppName:[[NSBundle mainBundle] bundleIdentifier]
											serviceProviderName:[NSString stringWithFormat:@"%@_Request", configuration.apiBaseURL.host]];
	}
	
	[self willChangeValueForKey:@"requestToken"];
	[value retain];	[_requestToken release]; _requestToken = value;
	[self didChangeValueForKey:@"requestToken"];
	
	if (value) {
		[_requestToken storeInDefaultKeychainWithAppName:[[NSBundle mainBundle] bundleIdentifier]
									 serviceProviderName:[NSString stringWithFormat:@"%@_Request", configuration.apiBaseURL.host]];
	}
}

- (OAToken *)accessToken;
{
	if (_accessToken) return _accessToken;
	_accessToken = [[OAToken alloc] initWithDefaultKeychainUsingAppName:[[NSBundle mainBundle] bundleIdentifier]
													serviceProviderName:[NSString stringWithFormat:@"%@_Access", self.configuration.apiBaseURL.host]];
	return _accessToken;
}

- (void)setAccessToken:(OAToken *)value;
{
	SCSoundCloudAPIConfiguration *configuration = self.configuration;
	if (!value) {
		[self.accessToken removeFromDefaultKeychainWithAppName:[[NSBundle mainBundle] bundleIdentifier] 
										   serviceProviderName:[NSString stringWithFormat:@"%@_Access", configuration.apiBaseURL.host]];
	}
	
	[self willChangeValueForKey:@"accessToken"];
	[value retain];	[_accessToken release];	_accessToken = value;
	[self didChangeValueForKey:@"accessToken"];
	
	if (value) {
		[_accessToken storeInDefaultKeychainWithAppName:[[NSBundle mainBundle] bundleIdentifier]
									serviceProviderName:[NSString stringWithFormat:@"%@_Access", configuration.apiBaseURL.host]];
	}
}

#pragma mark Public methods

- (void)requestAuthentication;
{
 	SCSoundCloudAPIConfiguration *configuration = self.configuration;
	if (!configuration.requestTokenURL
		|| !configuration.authURL
		|| !configuration.accessTokenURL) {
		NSLog(@"OAuth is not initialized with all 3 URLs");
		return;
	}
	
	if (status != SCAuthenticationStatusNotAuthenticated) {
		NSLog(@"OAuthApi is already authenticated.");
		return;
	}
	
	status = SCAuthenticationStatusGettingToken;
	if([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
		[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:configuration.requestTokenURL
																   consumer:_oauthConsumer
																	  token:nil
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	
	// FIXME: make asynch
	[_authDataFetcher release];
	_authDataFetcher = [[OADataFetcher alloc] init]; //release and nil in fetch delegate methods
	[_authDataFetcher fetchDataWithRequest:request
								  delegate:self
						 didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
						   didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	[request release];
}

- (void)authorizeRequestToken;
{
	SCSoundCloudAPIConfiguration *configuration = self.configuration;
	if (!configuration.requestTokenURL
		|| !configuration.authURL
		|| !configuration.accessTokenURL) {
		NSLog(@"OAuth is not initialized with all 3 URLs");
		return;
	}
	
	if (!self.requestToken) {
		NSLog(@"No RequestToken to Authorize");
		[self requestAuthentication];
		return;
	}
	
	status = SCAuthenticationStatusGettingToken;
	if([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
		[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:configuration.accessTokenURL
																   consumer:_oauthConsumer
																	  token:self.requestToken
																	  realm:nil 
														  signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	
	//FIXME: make asynch
	[_authDataFetcher release];
	_authDataFetcher = [[OADataFetcher alloc] init];
	[_authDataFetcher fetchDataWithRequest:request
								  delegate:self
						 didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
						   didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
	[request release];
}

- (void)resetAuthentication;
{
	self.requestToken = nil;
	self.accessToken = nil;
	status = SCAuthenticationStatusNotAuthenticated;
	if([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
		[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
}

- (void)setRequestTokenVerifier:(NSString *)verifier;
{
	self.requestToken.verifier = verifier;
}


#pragma mark Datafetcher delegates

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
{
	[_authDataFetcher release]; _authDataFetcher = nil;
	if (ticket.didSucceed) {
		SCSoundCloudAPIConfiguration *configuration = self.configuration;
		NSString *responseBody = [[[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding] autorelease];
		self.requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		
		NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   self.requestToken.key, @"oauth_token",
										   nil];
		
		if ([responseBody rangeOfString:@"oauth_callback_confirmed=true"].location != NSNotFound) {
			[parameters setValue:[configuration.callbackURL absoluteString] forKey:@"oauth_callback"];
		}
		
		// will most likely quit the application. be prepared :)
		if([authDelegate respondsToSelector:@selector(soundCloudAPI:requestedAuthenticationWithURL:)]) {
			[authDelegate soundCloudAPI:self requestedAuthenticationWithURL:[configuration.authURL urlByAddingParameters:parameters]];
		}		   
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
{
	[_authDataFetcher release]; _authDataFetcher = nil;
	if (ticket.didSucceed) {
		NSString *responseBody = [[[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding] autorelease];
		self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		self.requestToken = nil; //We don't need it anymore and we better not reauthorize it.
		status = SCAuthenticationStatusAuthenticated;
		if([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
			[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
{
	[_authDataFetcher release]; _authDataFetcher = nil;
	
	self.requestToken = nil;
	self.accessToken = nil;
	status = SCAuthenticationStatusCannotAuthenticate;
	if([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
		[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  error, SCAPIHttpResponseErrorStatusKey,
							  [error localizedDescription], NSLocalizedDescriptionKey,
							  nil];
	NSError *scError = [NSError errorWithDomain:SCAPIErrorDomain
										   code:SCAPIErrorHttpResponseError
									   userInfo:userInfo];
	[authDelegate soundCloudAPI:self didEncounterError:scError];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[_authDataFetcher release]; _authDataFetcher = nil;
	
	self.requestToken = nil;
	self.accessToken = nil;
	status = SCAuthenticationStatusCannotAuthenticate;
	if([authDelegate respondsToSelector:@selector(soundCloudAPI:didChangeAuthenticationStatus:)])
		[authDelegate soundCloudAPI:self didChangeAuthenticationStatus:status];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  error, SCAPIHttpResponseErrorStatusKey,
							  [error localizedDescription], NSLocalizedDescriptionKey,
							  nil];
	NSError *scError = [NSError errorWithDomain:SCAPIErrorDomain
										   code:SCAPIErrorHttpResponseError
									   userInfo:userInfo];
	[authDelegate soundCloudAPI:self didEncounterError:scError];
}


#pragma mark Pirivate methods

- (SCSoundCloudAPIConfiguration *)configuration;
{
	if([authDelegate respondsToSelector:@selector(configurationForSoundCloudAPI:)])
		return [authDelegate configurationForSoundCloudAPI:self];
	else
		return nil;
}

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

#pragma mark API methods

- (id)performMethod:(NSString *)httpMethod
		 onResource:(NSString *)resource
	 withParameters:(NSDictionary *)parameters
			context:(id)context;
{	
	SCSoundCloudAPIConfiguration *configuration = self.configuration;
	if (!configuration.apiBaseURL) {
		NSLog(@"API is not configured with base URL");
		return nil;
	}
	
	if (!self.accessToken
		|| status != SCAuthenticationStatusAuthenticated) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"SoundCloud API not authenticated"
															 forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:SCAPIErrorDomain
											 code:SCAPIErrorNotAuthenticted
										 userInfo:userInfo];
		if ([delegate respondsToSelector:@selector(soundCloudAPI:didFailWithError:context:)])
			[delegate soundCloudAPI:self didFailWithError:error context:context];
		return nil;
	}
	
	NSURL *url = [NSURL URLWithString:resource relativeToURL:configuration.apiBaseURL];
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
																	consumer:_oauthConsumer
																	   token:self.accessToken
																	   realm:nil
														   signatureProvider:nil] autorelease];
	[request addValue:[self _responseTypeFromEnum:self.responseFormat] forHTTPHeaderField:@"Accept"];
	
	[request setHTTPMethod:[httpMethod uppercaseString]];
	if ((![[httpMethod uppercaseString] isEqualToString:@"POST"]
		 && ![[httpMethod uppercaseString] isEqualToString:@"PUT"])
		|| parameters.count == 0) {
		[request setParameterDictionary:parameters];
	} else {
		SCPostBodyStream *postStream = [[SCPostBodyStream alloc] initWithParameters:parameters];
		[request setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [postStream boundary]] forHTTPHeaderField: @"Content-Type"];
		[request setValue:[NSString stringWithFormat:@"%d", [postStream length]] forHTTPHeaderField:@"Content-Length"];
		
		[request setHTTPBodyStream:postStream];
		[postStream release];
	}
	
	SCDataFetcher *fetcher = [[SCDataFetcher alloc] initWithRequest:request delegate:self context:context];
	NSString *requestId = [NSString stringWithUUID];
	[_dataFetchers setObject:fetcher forKey:requestId];
	[fetcher release];
	return [[_dataFetchers allKeysForObject:fetcher] lastObject];
}

- (void)cancelRequest:(id)requestIdentifier;
{
	if (!requestIdentifier)
		return;
	SCDataFetcher *fetcher = [_dataFetchers objectForKey:requestIdentifier];
	
	id context = [fetcher.context retain];
	[fetcher cancel];
	[_dataFetchers removeObjectForKey:requestIdentifier];
	
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didCancelRequestWithContext:)])
		[delegate soundCloudAPI:self didCancelRequestWithContext:context];
	[context release];
}


#pragma mark SCDataFetcherDelegate

- (void)scDataFetcher:(SCDataFetcher *)fetcher didFinishWithData:(NSData *)data context:(id)context;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didFinishWithData:context:)]) {
		[delegate soundCloudAPI:self didFinishWithData:data context:context];
	}
	[_dataFetchers removeObjectsForKeys:[_dataFetchers allKeysForObject:fetcher]];
}

- (void)scDataFetcher:(SCDataFetcher *)fetcher didFailWithError:(NSError *)error context:(id)context;
{
    NSDictionary *userInfo = [error userInfo];
    NSError *httpError = [userInfo objectForKey:SCAPIHttpResponseErrorStatusKey];
	if([httpError code] == 401) {
		[self resetAuthentication];
	}
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didFailWithError:context:)]) {
		[delegate soundCloudAPI:self didFailWithError:error context:context];
	}
	[_dataFetchers removeObjectsForKeys:[_dataFetchers allKeysForObject:fetcher]];
}

- (void)scDataFetcher:(SCDataFetcher *)fetcher didReceiveData:(NSData *)data context:(id)context;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didReceiveData:context:)]) {
		[delegate soundCloudAPI:self didReceiveData:data context:context];
	}
}

- (void)scDataFetcher:(SCDataFetcher *)fetcher didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didReceiveBytes:total:context:)]) {
		[delegate soundCloudAPI:self didReceiveBytes:loadedBytes total:totalBytes context:context];
	}
}

- (void)scDataFetcher:(SCDataFetcher *)fetcher didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didSendBytes:total:context:)]) {
		[delegate soundCloudAPI:self didSendBytes:sendBytes total:totalBytes context:context];
	}
}


@end

