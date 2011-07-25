//
//  NSString_GPKit.m
//
//  Created by Gernot Poetsch on 19.02.09.
//  Copyright 2009 Gernot Poetsch. All rights reserved.
//

#include <CommonCrypto/CommonDigest.h>

#import "NSString_GPKit.h"


@implementation NSString (GPKit)


#pragma mark Class methods

+ (NSString *)stringWithUUID;
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
    return [(NSString *)string autorelease];
}


#pragma mark Escaping

- (NSString *)stringByUnescapingXMLEntities;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *returnValue = [self stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"auml;" withString:@"ä"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&Auml;" withString:@"Ä"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&ouml;" withString:@"ö"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&Ouml;" withString:@"Ö"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&uuml;" withString:@"ü"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&Üuml;" withString:@"Ü"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&szlig;" withString:@"ß"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];	
	
	[returnValue retain];
	[pool release];
	[returnValue autorelease];
	return returnValue;
}

- (NSString *)stringByEscapingXMLEntities;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *returnValue = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"ä" withString:@"auml;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"Ä" withString:@"&Auml;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"ö" withString:@"&ouml;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"Ö" withString:@"&Ouml;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"ü" withString:@"&uuml;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"Ü" withString:@"&Üuml;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@"ß" withString:@"&szlig;"];
	returnValue = [returnValue stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];	
	
	[returnValue retain];
	[pool release];
	[returnValue autorelease];
	return returnValue;
}

- (NSString *)stringByAddingURLEncoding;
{
	CFStringRef returnValue = CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault, //Allocator
																	   (CFStringRef)self, //Original String
																	   NULL, //Characters to leave unescaped
																	   (CFStringRef)@"!*'();:@&=+$,/?%#[]", //Legal Characters to be escaped
																	   kCFStringEncodingUTF8); //Encoding
	return [(NSString *)returnValue autorelease];
}

- (NSString *)stringByRemovingURLEncoding;
{
	CFStringRef returnValue = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, //Allocator
																		 (CFStringRef)self,
																		 nil);
	return [(NSString *)returnValue autorelease];
}


#pragma mark MD5

- (NSString *)md5Value
{
	//from http://www.tomdalling.com/cocoa/md5-hashes-in-cocoa
	NSData* inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	CC_MD5([inputData bytes], [inputData length], outputData);
	
	NSMutableString* hashStr = [NSMutableString string];
	int i = 0;
	for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
		[hashStr appendFormat:@"%02x", outputData[i]];
	
	return hashStr;
}


#pragma mark Query String Helpers

- (NSDictionary *)dictionaryFromQuery;
{
	NSArray *encodedParameterPairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    
    for (NSString *encodedPair in encodedParameterPairs) {
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
		if (encodedPairElements.count == 2) {
			[requestParameters setValue:[[encodedPairElements objectAtIndex:1] stringByRemovingURLEncoding]
								 forKey:[[encodedPairElements objectAtIndex:0] stringByRemovingURLEncoding]];
		}
    }
	return requestParameters;
}

@end
