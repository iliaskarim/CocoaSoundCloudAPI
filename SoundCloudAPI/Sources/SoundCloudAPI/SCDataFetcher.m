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

#import "SCDataFetcher.h"

#import "OAuthConsumer.h"
#import "OAMutableURLRequest.h"

#import "SCAPIErrors.h"

@implementation SCDataFetcher

-(id)initWithRequest:(OAMutableURLRequest *)inRequest delegate:(id<SCDataFetcherDelegate>)inDelegate context:(id)inContext;
{
	if (self = [super init]) {
		[inRequest prepare];
		
		id bodyStream = [inRequest HTTPBodyStream];
		if ([bodyStream isKindOfClass:[SCPostBodyStream class]]){
			[bodyStream setMonitorDelegate:self];
		}
		
		_delegate = inDelegate;
		_context = [inContext retain];
		_connection = [[NSURLConnection alloc] initWithRequest:inRequest delegate:self];
	}
	return self;
}

-(void)dealloc;
{
	[_connection release];
	[_data release];
	[_context release];
	[super dealloc];
}

#pragma mark -
#pragma mark SCPostBodyStream Delegate

- (void)stream:(SCPostBodyStream *)stream hasBytesDelivered:(unsigned long long)deliveredBytes total:(unsigned long long)totalBytes;
{
	if ([_delegate respondsToSelector:@selector(scDataFetcher:didSendBytes:total:context:)]){
		[_delegate scDataFetcher:self
					didSendBytes:deliveredBytes
						   total:totalBytes
						 context:_context];
	}
}

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
	_expectedContentLength = response.expectedContentLength;
	_statusCode = [(NSHTTPURLResponse *)response statusCode];
	
	if (!_data) {
		_data = [[NSMutableData alloc] init];
	} else {
		[_data setLength:0];
	}
	if ([_delegate respondsToSelector:@selector(scDataFetcher:didReceiveBytes:total:context:)]) {
		[_delegate scDataFetcher:self didReceiveBytes:[_data length] total:_expectedContentLength context:_context];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
	[_data appendData:data];
	if ([_delegate respondsToSelector:@selector(scDataFetcher:didReceiveData:context:)]) {
		[_delegate scDataFetcher:self didReceiveData:data context:_context];
	}
	if ([_delegate respondsToSelector:@selector(scDataFetcher:didReceiveBytes:total:context:)]) {
		[_delegate scDataFetcher:self didReceiveBytes:[_data length] total:_expectedContentLength context:_context];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
	if(_statusCode < 400) {
		if ([_delegate respondsToSelector:@selector(scDataFetcher:didFinishWithData:context:)]) {
			[_delegate scDataFetcher:self didFinishWithData:_data context:_context];
		}
	} else {
		NSError *httpError = [NSError errorWithDomain:NSURLErrorDomain
												 code:_statusCode
											 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSHTTPURLResponse localizedStringForStatusCode:_statusCode], NSLocalizedDescriptionKey,
													   nil]];
		NSError *error = [NSError errorWithDomain:SCAPIErrorDomain
											 code:SCAPIErrorHttpResponseError
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   httpError, SCAPIHttpResponseErrorStatusKey,
												   nil]];
		if ([_delegate respondsToSelector:@selector(scDataFetcher:didFailWithError:context:)]) {
			[_delegate scDataFetcher:self didFailWithError:error context:_context];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)httpError;
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  httpError, SCAPIHttpResponseErrorStatusKey,
							  nil];
	NSError *error = [NSError errorWithDomain:SCAPIErrorDomain
										 code:SCAPIErrorHttpResponseError
									 userInfo:userInfo];
	if ([_delegate respondsToSelector:@selector(scDataFetcher:didFailWithError:context:)]) {
		[_delegate scDataFetcher:self didFailWithError:error context:_context];
	}
}

@end
