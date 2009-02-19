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