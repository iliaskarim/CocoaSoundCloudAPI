//
//  GPURLConnection.h
//  GPKit
//
//  Created by Gernot Poetsch on 09.03.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

@protocol GPURLConnectionDelegate;

@interface GPURLConnection : NSObject {
	id<GPURLConnectionDelegate> _delegate;
	NSMutableData *_data;
	NSURLConnection *_connection;
	id _userInfo;
	id _context;
	
	int _statusCode;
	
	long long _expectedContentLength;
	float _progress;
	
	BOOL _activityIndicatorIsTrackingMe;
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) id context;

@property (readonly) int statusCode;
@property (readonly) long long expectedContentLength;
@property (readonly) float progress;

@end

@interface GPURLConnection (NSURLConnectionProxy)
+ (BOOL)canHandleRequest:(NSURLRequest *)request;
+ (id)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
- (void)start AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
- (void)cancel;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
@end

@interface GPURLConnection (NSURLDelegate)
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
@end

@protocol GPURLConnectionDelegate <NSObject>
@optional
- (NSURLRequest *)connection:(GPURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connection:(GPURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(GPURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(GPURLConnection *)connection;
- (void)connection:(GPURLConnection *)connection didFailWithError:(NSError *)error;
- (NSCachedURLResponse *)connection:(GPURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (void)connectionDidCancel:(GPURLConnection *)connection;
@end
