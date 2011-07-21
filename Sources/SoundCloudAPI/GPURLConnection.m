//
//  GPURLConnection.m
//  GPKit
//
//  Created by Gernot Poetsch on 09.03.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

#import "GPURLConnection.h"

#if TARGET_OS_IPHONE
#import "GPNetworkActivityController.h"
#endif

@implementation GPURLConnection

#pragma mark LifeCycle

- (id)init;
{
	return nil;
}

- (void)dealloc;
{
	_delegate = nil;
	[self cancel];
	[_connection release];
	[_userInfo release];
	[_context release];
	[_data release];
	[super dealloc];
}

#pragma mark Accessors

@synthesize connection = _connection, data = _data, userInfo = _userInfo, context = _context;
@synthesize statusCode = _statusCode, expectedContentLength = _expectedContentLength, progress = _progress;

@end

#pragma mark -

@implementation GPURLConnection (NSURLConnectionProxy)
+ (BOOL)canHandleRequest:(NSURLRequest *)request;
{
	return [NSURLConnection canHandleRequest:request];
}

+ (id)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;
{
	return [[[self alloc] initWithRequest:request delegate:delegate] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;
{
	if (![super init]) return nil;
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	_delegate = delegate;
	_statusCode = 0;
	_activityIndicatorIsTrackingMe = NO;
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	if (![super init]) return nil;
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:startImmediately];
	_delegate = delegate;
	_statusCode = 0;
	_activityIndicatorIsTrackingMe = NO;
	return self;
}

- (void)start AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	[_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_connection start];
}

- (void)cancel;
{
	[_connection cancel];
#if TARGET_OS_IPHONE
	if (_activityIndicatorIsTrackingMe) [[GPNetworkActivityController sharedActivityController] decreaseNumberOfActiveTransmissions];
	_activityIndicatorIsTrackingMe = NO;
#endif
	if ([_delegate respondsToSelector:@selector(connectionDidCancel:)]){
		[_delegate connectionDidCancel:self];
	}
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	[_connection scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	[_connection unscheduleFromRunLoop:aRunLoop forMode:mode];
}

@end

#pragma mark -

@implementation GPURLConnection (NSURLDelegate)

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
{
	NSURLRequest *returnValue = request;
	if ([_delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]){
		returnValue = [_delegate connection:self willSendRequest:request redirectResponse:response];
	}
	
	#if TARGET_OS_IPHONE
	if (returnValue && !_activityIndicatorIsTrackingMe) {
		[[GPNetworkActivityController sharedActivityController] increaseNumberOfActiveTransmissions];
		_activityIndicatorIsTrackingMe = YES;
	}
	#endif
	
	return returnValue;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{	
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
		_statusCode = [HTTPResponse statusCode];
	}
	
	_expectedContentLength = response.expectedContentLength;
	_progress = 0.0;
	if (!_data) 
		_data = [[NSMutableData alloc] init];
	else [_data setLength:0];
	if ([_delegate respondsToSelector:@selector(connection:didReceiveResponse:)]){
		[_delegate connection:self didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
	[_data appendData:data];
	if (_expectedContentLength != 0.0) _progress = (float)_data.length / (float)_expectedContentLength;
	if ([_delegate respondsToSelector:@selector(connection:didReceiveData:)]){
		[_delegate connection:self didReceiveData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
	#if TARGET_OS_IPHONE
	if (_activityIndicatorIsTrackingMe) [[GPNetworkActivityController sharedActivityController] decreaseNumberOfActiveTransmissions];
	_activityIndicatorIsTrackingMe = NO;
	#endif
	
	if ([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)]){
		[_delegate connectionDidFinishLoading:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	#if TARGET_OS_IPHONE
	if (_activityIndicatorIsTrackingMe) [[GPNetworkActivityController sharedActivityController] decreaseNumberOfActiveTransmissions];
	_activityIndicatorIsTrackingMe = NO;
	#endif
	
	if ([_delegate respondsToSelector:@selector(connection:didFailWithError:)]){
		[_delegate connection:self didFailWithError:error];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
{
	if ([_delegate respondsToSelector:@selector(connection:willCacheResponse:)]){
		return [_delegate connection:self willCacheResponse:cachedResponse];
	} else {
		return cachedResponse;
	}
}

#if TARGET_OS_IPHONE
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
{
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		//if ([trustedHosts containsObject:challenge.protectionSpace.host])
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
#endif

@end
