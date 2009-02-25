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
#import "SCPostBodyPart.h"

#import <stdlib.h>
#import <time.h>

@interface SCPostBodyStream (Private)
- (NSArray *)streamsForParameters:(NSDictionary *)bodyParts contentLength:(unsigned long long *)contentLength;
@end

@implementation SCPostBodyStream

#pragma mark Lifecycle

- (id)initWithParameters:(NSDictionary *)postParameters;
{
	if (self = [self init]) {
		srandom(time(NULL));
		boundary = [[NSString alloc] initWithFormat:@"----------------------------scapi%d", rand()];
		_numBytesTotal = 0;
		_numBytesRead = 0;
		
		if (postParameters) {
			_contentStreams = [[self streamsForParameters:postParameters contentLength:&_numBytesTotal] retain];
		} else {
			_contentStreams = [[NSArray alloc] init];
		}
	}
	return self;
}

- (void)dealloc;
{
	[boundary release];
	[_contentStreams release];
	[super dealloc];
}

#pragma mark Accessors

@synthesize monitorDelegate = _monitorDelegate;
@synthesize length = _numBytesTotal;
@synthesize boundary;

#pragma mark private

- (NSArray *)partsForParameters:(NSDictionary *)parameters;
{
	NSMutableArray *parts = [NSMutableArray array];
	for (NSString *key in parameters) {
		id value = [parameters valueForKey:key];
		SCPostBodyPart *part = [[SCPostBodyPart alloc] initWithName:key content:value];
		[parts addObject:part];
		[part release];
	}
	return parts;
}

- (NSArray *)streamsForParameters:(NSDictionary *)parameters contentLength:(unsigned long long *)contentLength;
{
	NSArray *parts = [self partsForParameters:parameters];
	NSMutableArray *streams = [NSMutableArray array];
	
	NSString *firstDelimiter = [NSString stringWithFormat: @"--%@\r\n", boundary];
    NSString *middleDelimiter = [NSString stringWithFormat: @"\r\n--%@\r\n", boundary];
    NSString *finalDelimiter = [NSString stringWithFormat: @"\r\n--%@--\r\n", boundary];

    NSString *delimiter = firstDelimiter;
    for (SCPostBodyPart *part in parts)
    {
		NSAutoreleasePool *_pool = [[NSAutoreleasePool alloc] init];
		
		NSData *delimiterData = [delimiter dataUsingEncoding:NSUTF8StringEncoding];
		NSData *contentHeaderData = [[part contentHeaders] dataUsingEncoding:NSUTF8StringEncoding];
		
		int dataLength = delimiterData.length + contentHeaderData.length;
        NSMutableData *headerData = [NSMutableData dataWithCapacity: dataLength];
        [headerData appendData:delimiterData];
        [headerData appendData:contentHeaderData];
		
        NSInputStream *headerStream = [NSInputStream inputStreamWithData:headerData];
        [streams addObject:headerStream];
        *contentLength += [headerData length];

        [streams addObject:[part contentStream]];
        *contentLength += [part contentLength];
        
        delimiter = middleDelimiter;
		
		[_pool release];
    }
    
    NSData *finalDelimiterData = [finalDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *finalDelimiterStream = [NSInputStream inputStreamWithData:finalDelimiterData];
    [streams addObject:finalDelimiterStream];
    *contentLength += [finalDelimiterData length];
	
	return streams;
}

#pragma mark NSInputStream subclassing

- (void)open;
{
    [_contentStreams makeObjectsPerformSelector:@selector(open)];
    _currentStream = nil;
	_streamIndex = 0;
    if (_contentStreams.count > 0)
        _currentStream = [_contentStreams objectAtIndex: _streamIndex];
}

- (void)close;
{
    [_contentStreams makeObjectsPerformSelector:@selector(close)];
	_currentStream = nil;
}

- (BOOL)hasBytesAvailable;
{
	if (!_currentStream) return NO;
	for (int i = _streamIndex; i < _contentStreams.count; i++) {
		if ([[_contentStreams objectAtIndex:i] hasBytesAvailable]) return YES;
	}
	return NO;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len;
{
	if (_currentStream == nil)
        return 0;
	
    int result = [_currentStream read:buffer maxLength:len];
	
    if (result == 0) {
		if (_streamIndex < _contentStreams.count - 1) {
			_streamIndex++;
			_currentStream = [_contentStreams objectAtIndex:_streamIndex];
			result = [self read:buffer maxLength:len];
		} else {
			_currentStream == nil;
		}
	} else {
		_numBytesRead += result;
		if([_monitorDelegate respondsToSelector:@selector(stream:hasBytesDelivered:total:)]) {
			[_monitorDelegate stream:self hasBytesDelivered:_numBytesRead total:_numBytesTotal];
		}
	}
    return result;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len;
{
	return NO;
}

- (NSStreamStatus)streamStatus;
{
	if(_currentStream)
		return [_currentStream streamStatus];
	return NSStreamStatusNotOpen;
}

- (NSError *)streamError;
{
	if(_currentStream)
		return [_currentStream streamError];
	return nil;
}

#pragma mark Runloop

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
{
	[super scheduleInRunLoop:runLoop forMode:mode];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;
{
	[super stream:theStream handleEvent:streamEvent];
}

#pragma mark NSURLConnection Hacks

- (void)_scheduleInCFRunLoop:(NSRunLoop *)inRunLoop forMode:(id)inMode;
{
    // Safe to ignore this?
	// maybe call this on all child streams?
}

- (void)_setCFClientFlags:(CFOptionFlags)inFlags
                  callback:(CFReadStreamClientCallBack)inCallback
				  context:(CFStreamClientContext)inContext;
{
    // Safe to ignore this?
	// maybe call this on all child streams?
}

@end