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

#import "SCDataFetcher.h"

#import "OAuthConsumer.h"
#import "OAMutableURLRequest.h"

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
		NSError *error = [NSError errorWithDomain:@"SoundCloudAPI Response Error"
											 code:_statusCode
										 userInfo:nil];
		if ([_delegate respondsToSelector:@selector(scDataFetcher:didFailWithError:context:)]) {
			[_delegate scDataFetcher:self didFailWithError:error context:_context];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	if ([_delegate respondsToSelector:@selector(scDataFetcher:didFailWithError:context:)]) {
		[_delegate scDataFetcher:self didFailWithError:error context:_context];
	}
}

@end
