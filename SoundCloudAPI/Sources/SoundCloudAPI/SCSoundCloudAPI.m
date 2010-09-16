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

#import "SCAPIErrors.h"
#import "SCSoundCloudAPIConfiguration.h"
#import "SCSoundCloudAPIAuthentication.h"
#import "SCSoundCloudAPIAuthenticationDelegate.h"
#import "SCSoundCloudAPIDelegate.h"


#import "NSString+SoundCloudAPI.h"

#import "SCSoundCloudAPI.h"


@interface SCSoundCloudAPI () <NXOAuth2ConnectionDelegate>
- (NSString *)_responseTypeFromEnum:(SCResponseFormat)responseFormat;
- (NSMutableURLRequest *)_requestForMethod:(NSString *)httpMethod
                                onResource:(NSString *)resource
                            withParameters:(NSDictionary *)parameters;

// private initializer used for NSCopying
- (id)initWithDelegate:(id<SCSoundCloudAPIDelegate>)aDelegate
		authentication:(SCSoundCloudAPIAuthentication *)anAuthentication;
@end


@implementation SCSoundCloudAPI

#pragma mark Lifecycle

- (id)initWithDelegate:(id<SCSoundCloudAPIDelegate>)theDelegate
authenticationDelegate:(id<SCSoundCloudAPIAuthenticationDelegate>)authDelegate
	  apiConfiguration:(SCSoundCloudAPIConfiguration *)configuration;

{
	SCSoundCloudAPIAuthentication *anAuthentication =  [[SCSoundCloudAPIAuthentication alloc] initWithAuthenticationDelegate:authDelegate
																											apiConfiguration:configuration];
	if (self = [self initWithDelegate:theDelegate
					   authentication:anAuthentication]) {
		responseFormat = SCResponseFormatJSON;
		apiConnections = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithDelegate:(id<SCSoundCloudAPIDelegate>)aDelegate
		authentication:(SCSoundCloudAPIAuthentication *)anAuthentication;
{
	if (self = [super init]) {
		responseFormat = SCResponseFormatXML;
		delegate = aDelegate;
		authentication = [anAuthentication retain];
		apiConnections = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc;
{
	for(SCSoundCloudConnection *connection in [apiConnections allValues]) {
		[connection cancel];
	}
	[apiConnections release];
	[authentication release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize responseFormat;

- (BOOL)authenticated;
{
	return authentication.authenticated;
}


#pragma mark Public methods

- (void)requestAuthentication;
{
	[authentication requestAuthentication];
}

- (void)resetAuthentication;
{
	[authentication resetAuthentication];
}

- (BOOL)handleOpenRedirectURL:(NSURL *)redirectURL;
{
	return [authentication handleOpenRedirectURL:redirectURL];
}

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password;
{
	[authentication authorizeWithUsername:username password:password];
}


#pragma mark Private

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

- (NSMutableURLRequest *)_requestForMethod:(NSString *)httpMethod
                                onResource:(NSString *)resource
                            withParameters:(NSDictionary *)parameters;
{
    if (!authentication.configuration.apiBaseURL) {
		NSLog(@"API is not configured with base URL");
		return nil;
	}
	
	NSURL *url = [NSURL URLWithString:resource relativeToURL:authentication.configuration.apiBaseURL];
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
    return request;
}

#pragma mark API method

- (id)performMethod:(NSString *)httpMethod
		 onResource:(NSString *)resource
	 withParameters:(NSDictionary *)parameters
			context:(id)context;
{
	NSURLRequest *request = [self _requestForMethod:httpMethod onResource:resource withParameters:parameters];
	
	NXOAuth2Connection *connection = [[NXOAuth2Connection alloc] initWithRequest:request oauthClient:authentication.oauthClient delegate:self];
	connection.context = context;
	
    id connectionId = [NSString stringWithUUID];
	[apiConnections setObject:connection forKey:connectionId];
    [connection release];
	return connectionId;
}

#if NS_BLOCKS_AVAILABLE
- (id)performMethod:(NSString *)httpMethod
         onResource:(NSString *)resource
     withParameters:(NSDictionary *)parameters
             finish:(void (^)(void))finishBlock 
               fail:(void (^)(NSError *error))failBlock
            context:(id)context;
{
    NSURLRequest *request = [self _requestForMethod:httpMethod onResource:resource withParameters:parameters];
	
	NXOAuth2Connection *connection = [[NXOAuth2Connection alloc] initWithRequest:request
                                                                     oauthClient:authentication.oauthClient
                                                                          finish:finishBlock 
                                                                            fail:failBlock];
    connection.delegate = self;
	connection.context = context;
	
    id connectionId = [NSString stringWithUUID];
	[apiConnections setObject:connection forKey:connectionId];
    [connection release];
	return connectionId;
}
#endif

- (void)cancelConnection:(id)connectionId;
{
	SCSoundCloudConnection *connection = [apiConnections objectForKey:connectionId];
	if (connection) {
		[connection cancel];
		[apiConnections removeObjectForKey:connectionId];
	}
}


#pragma mark NXOAuth2ConnectionDelegate

- (void)oauthConnection:(NXOAuth2Connection *)connection didFinishWithData:(NSData *)data;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didFinishWithData:context:)]) {
		[delegate soundCloudAPI:self didFinishWithData:data context:connection.context];
	}
	[apiConnections removeObjectsForKeys:[apiConnections allKeysForObject:connection]];
}

- (void)oauthConnection:(NXOAuth2Connection *)connection didFailWithError:(NSError *)error;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didFailWithError:context:)]) {
		[delegate soundCloudAPI:self didFailWithError:error context:connection.context];
	}
	[apiConnections removeObjectsForKeys:[apiConnections allKeysForObject:connection]];
}

- (void)oauthConnection:(NXOAuth2Connection *)connection didReceiveData:(NSData *)data;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didReceiveData:context:)]) {
		[delegate soundCloudAPI:self didReceiveData:data context:connection.context];
	}
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didReceiveBytes:total:context:)]) {
		[delegate soundCloudAPI:self didReceiveBytes:connection.data.length total:connection.expectedContentLength context:connection.context];
	}
}

- (void)oauthConnection:(NXOAuth2Connection *)connection didSendBytes:(unsigned long long)bytesSend ofTotal:(unsigned long long)bytesTotal;
{
	if ([delegate respondsToSelector:@selector(soundCloudAPI:didSendBytes:total:context:)]) {
		[delegate soundCloudAPI:self didSendBytes:bytesSend total:bytesTotal context:connection.context];
	}
}


#pragma mark NSCopying

- (id)copy;
{
	SCSoundCloudAPI *copy = [[[self class] alloc] initWithDelegate:delegate
													authentication:authentication];	// same authentication
	copy->responseFormat = responseFormat;
	return copy;
}

- (id)copyWithZone:(NSZone *)zone;
{
	return [self copy];
}

- (id)copyWithAPIDelegate:(id)apiDelegate;
{
	SCSoundCloudAPI *copy = [self copy];	// same authentication
	copy->delegate = apiDelegate;
	return copy;
}


@end

