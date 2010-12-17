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

#pragma mark Class Methods

+ (id)wrapperWithStream:(NSInputStream *)aStream contentLength:(unsigned long long)aContentLength;
{
	return [self wrapperWithStream:aStream contentLength:aContentLength fileName:nil];
}

+ (id)wrapperWithStream:(NSInputStream *)aStream contentLength:(unsigned long long)aContentLength fileName:(NSString *)aFileName;
{
	return [[[self alloc] initWithStream:aStream contentLength:aContentLength fileName:aFileName] autorelease];
}


#pragma mark Lifecycle

- (id)init;
{
    NSAssert(NO, @"-init should not be used in the SCInputStreamWrapper");
    return nil;
}

- (id)initWithStream:(NSInputStream *)theStream contentLength:(unsigned long long)theContentLength;
{
	return [self initWithStream:theStream contentLength:theContentLength fileName:nil];
}

- (id)initWithStream:(NSInputStream *)aStream contentLength:(unsigned long long)aContentLength fileName:(NSString *)aFileName;
{
	if (!aFileName) aFileName = @"unknown";
	
	if (self = [super init]) {
		stream = [aStream retain];
		contentLength = aContentLength;
		fileName = [aFileName copy];
	}
	return self;
}

- (void)dealloc;
{
	[stream release];
	[fileName release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize stream, contentLength, fileName;


@end
