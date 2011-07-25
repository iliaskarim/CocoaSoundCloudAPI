//
//  NSData+SCKit.m
//  SCKit
//
//  Created by Ullrich Schäfer on 16.03.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "NSString+SCKit.h"

#import "NSData+SCKit.h"


@implementation NSData (SCKit)

- (id)JSONObject;
{
	NSString *jsonString = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
	id jsonObject = [[jsonString JSONObject] retain];
	[jsonString release];
	return [jsonObject autorelease];
}

- (NSString *)errorMessageFrom422Error;
{
    NSDictionary *result = [self JSONObject];
    if (![result isKindOfClass:[NSDictionary class]]) return nil;
    NSArray *errors = [result objectForKey:@"errors"];
    if (![errors isKindOfClass:[NSArray class]]) return nil;
    if (errors.count == 0) return nil;
    NSDictionary *errorDict = [errors objectAtIndex:0];
    if (![errorDict isKindOfClass:[NSDictionary class]]) return nil;
    NSString *message = [errorDict objectForKey:@"error_message"];
    if (![message isKindOfClass:[NSString class]]) return nil;
    return message;
}

@end
