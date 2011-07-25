//
//  SCAPITimestampValueTransformer.m
//  SoundCloudKit
//
//  Created by Thomas Kollbach on 18.03.11.
//  Copyright 2011 SoundCloud. All rights reserved.
//

#import "SCAPITimestampValueTransformer.h"

NSString *const SCAPITimestampValueTransformerName = @"SCAPITimestampValueTransformerName";


@interface SCAPITimestampValueTransformer ()
@property (nonatomic, retain, readwrite) NSDateFormatter *apiDateFormatter;
@end


@implementation SCAPITimestampValueTransformer

#pragma mark Class Methods

+ (void)registerValueTransformer;
{
	[NSValueTransformer setValueTransformer:[[[SCAPITimestampValueTransformer alloc] init] autorelease]
					  				forName:SCAPITimestampValueTransformerName];
}

+ (BOOL)allowsReverseTransformation;
{
	return YES;
}

+ (Class)transformedValueClass;
{
	return [NSDate class];
}


#pragma mark Lifecycle

- (id)init;
{
	self = [super init];
	if (self) {
		apiDateFormatter = [[NSDateFormatter alloc] init];
		apiDateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss ZZZ";
	}
	return self;
}

- (void)dealloc;
{
	[apiDateFormatter release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize apiDateFormatter; // private


#pragma mark NSValueTransformer

- (id)transformedValue:(id)value;
{
    if (value && ![value isKindOfClass:[NSString class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does is not of class NSString.", [value class]];
    }
	if (!value) return nil;
	if ([value isEqualToString:@""]) return nil;
	
	NSDate *date = [self.apiDateFormatter dateFromString:value];
	
	return date;
}

- (id)reverseTransformedValue:(id)value;
{
    if (![value isKindOfClass:[NSDate class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does is not of class NSDate.", [value class]];
    }
	
	return [self.apiDateFormatter stringFromDate:value];
}


@end
