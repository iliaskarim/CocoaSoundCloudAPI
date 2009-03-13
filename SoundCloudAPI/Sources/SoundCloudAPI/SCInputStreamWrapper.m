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

#import "SCInputStreamWrapper.h"


@implementation SCInputStreamWrapper

#pragma mark Lifecycle

+ (id)wrapperWithStream:(NSInputStream *)_stream contentLength:(unsigned long long)_contentLength;
{
	return [[[self alloc] initWithStream:_stream contentLength:_contentLength] autorelease];
}

- (id)initWithStream:(NSInputStream *)_stream contentLength:(unsigned long long)_contentLength;
{
	if (self = [super init]) {
		stream = [_stream retain];
		contentLength = _contentLength;
	}
	return self;
}

- (void)dealloc;
{
	[stream release];
	[super dealloc];
}

#pragma mark Accessors

@synthesize stream, contentLength;

@end
