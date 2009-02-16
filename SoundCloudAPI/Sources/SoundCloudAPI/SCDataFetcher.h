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

#import "SCPostBodyStream.h"

@class OAMutableURLRequest;
@protocol SCDataFetcherDelegate;

@interface SCDataFetcher : NSObject <SCPostBodyStreamMonitorDelegate> {
	NSURLConnection *_connection;
	unsigned long long _expectedContentLength;
	NSInteger _statusCode;
	
	NSMutableData *_data;
	
	id<SCDataFetcherDelegate> _delegate;
	id _context;
}

-(id)initWithRequest:(OAMutableURLRequest *)request delegate:(id<SCDataFetcherDelegate>)inDelegate context:(id)context;

@end

@protocol SCDataFetcherDelegate <NSObject>
-(void)scDataFetcher:(SCDataFetcher *)fetcher didFinishWithData:(NSData *)data context:(id)context;
-(void)scDataFetcher:(SCDataFetcher *)fetcher didFailWithError:(NSError *)error context:(id)context;
-(void)scDataFetcher:(SCDataFetcher *)fetcher didReceiveData:(NSData *)data context:(id)context;
-(void)scDataFetcher:(SCDataFetcher *)fetcher didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
-(void)scDataFetcher:(SCDataFetcher *)fetcher didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
@end