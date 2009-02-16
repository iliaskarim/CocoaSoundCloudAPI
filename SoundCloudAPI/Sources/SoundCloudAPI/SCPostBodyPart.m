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

#import "SCPostBodyPart.h"

@interface SCPostBodyPart(Private)
- (id)initWithName:(NSString *)name dataContent:(NSData *)data;
- (id)initWithName:(NSString *)name fileContent:(NSString *)path;
- (id)initWithName:(NSString *)name stringContent:(NSString *)string;
@end


@implementation SCPostBodyPart

#pragma mark Lifecycle

+ partWithName:(NSString *)name content:(id)content;
{
	return [[[self alloc] initWithName:name content:content] autorelease];
}

- (id)initWithName:(NSString *)name content:(id)content;
{
	if ([content isKindOfClass:[NSString class]]) {
		return [self initWithName:name stringContent:content];
	} else if ([content isKindOfClass:[NSURL class]] && [content isFileURL]) {
		return [self initWithName:name fileContent:[content path]];
	} else if ([content isKindOfClass:[NSData class]]) {
		return [self initWithName:name dataContent:content];
	} else {
		NSLog(@"SCPostBodyPart with illegal type:\n%@", [content class]);
		return nil;
	}
}

- (id)initWithName:(NSString *)name dataContent:(NSData *)data;
{
    NSMutableString *headers = [NSMutableString string];
	[headers appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"unknown\"\r\n", name];
    [headers appendString:@"Content-Transfer-Encoding: binary\r\n"];
	[headers appendString:@"Content-Type: application/octet-stream\r\n"];
	[headers appendString:@"\r\n"];
    return [self initWithHeaders:headers dataContent:data];
}

- (id)initWithName:(NSString *)name fileContent:(NSString *)path;
{
    NSMutableString *headers = [NSMutableString string];
    [headers appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, [path lastPathComponent]];
    [headers appendString:@"Content-Transfer-Encoding: binary\r\n"];
    [headers appendString:@"Content-Type: application/octet-stream\r\n"];
	[headers appendString:@"\r\n"];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
    NSNumber *fileSize = [fileAttributes valueForKey:NSFileSize];
    
    return [self initWithHeaders:headers
                   streamContent:[NSInputStream inputStreamWithFileAtPath:path]
                          length:[fileSize unsignedLongLongValue]];
}

- (id)initWithName:(NSString *)name stringContent:(NSString *)string;
{
	NSMutableString *headers = [NSMutableString string];
	[headers appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", name];
	[headers appendString:@"\r\n"];
	return [self initWithHeaders:headers dataContent:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithHeaders:(NSString *)headers dataContent:(NSData *)data;
{
    return [self initWithHeaders: headers
                   streamContent: [NSInputStream inputStreamWithData:data]
                          length: [data length]];
}

- (id)initWithHeaders:(NSString *)headers streamContent:(NSInputStream *)stream length:(unsigned long long)length;
{
    if(self = [super init]){
		contentHeaders = [headers retain];
		contentStream = [stream retain];
		contentLength  = length;
	}    
    return self;
}

- (void)dealloc;
{
    [contentHeaders release];
    [contentStream release];
    [super dealloc];
}

#pragma mark Accessors

@synthesize contentHeaders;
@synthesize contentStream;
@synthesize contentLength;


@end