//
//  NSString+SCKit.m
//  SCKit
//
//  Created by Ullrich Schäfer on 16.03.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "JSONKit.h"

#import "NSString+SCKit.h"


@implementation NSString (SCKit)

- (id)JSONObject;
{
	return [self objectFromJSONString];
}

+ (NSString *)stringWithSeconds:(NSTimeInterval)seconds;
{
	return [NSString stringWithMilliseconds:(NSInteger)(seconds * 1000.0)];
}

+ (NSString *)stringWithMilliseconds:(NSInteger)seconds;
{
	seconds = seconds / 1000;
	NSInteger hours = seconds / 60 / 60;
	seconds -= hours * 60 * 60;
	NSInteger minutes = seconds / 60;
	seconds -= minutes * 60;
	
	
	NSMutableString *string = [NSMutableString string];
	
	if (hours > 0) {
		[string appendFormat:@"%u.", hours];
	}
	
	if (minutes >= 10 || hours == 0) {
		[string appendFormat:@"%u.", minutes];
	} else {
		[string appendFormat:@"0%u.", minutes];
	}
	
	if (seconds >= 10) {
		[string appendFormat:@"%u", seconds];
	} else {
		[string appendFormat:@"0%u", seconds];
	}
	
	return string;
}

+ (NSString *)stringWithInteger:(NSInteger)integer upperRange:(NSInteger)upperRange;
{
	if (integer <= upperRange) {
		return [[self class] stringWithFormat:@"%d", integer];
	} else {
		return [[self class] stringWithFormat:@"%d+", upperRange];
	}
}

- (NSArray *)componentsSeparatedByWhitespacePreservingQuotations;
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSMutableArray *result = [NSMutableArray array];
    while (![scanner isAtEnd]) {
        NSString *tag = nil;
        NSString *beginning = [self substringWithRange:NSMakeRange([scanner scanLocation], 1)];
        if ([beginning isEqualToString:@"\""]) {
            [scanner setScanLocation:[scanner scanLocation] + 1];
            [scanner scanUpToString:@"\"" intoString:&tag];
            [scanner setScanLocation:[scanner scanLocation] + 1];
        } else {
            [scanner scanUpToString:@" " intoString:&tag];
        }
        if (![scanner isAtEnd]) {
            [scanner setScanLocation:[scanner scanLocation] + 1];
        }
        if (tag) [result addObject:tag];
    }
    return result;
}


@end
