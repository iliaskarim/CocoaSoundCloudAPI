//
//  SCNumberToStringValueTransformer.m
//  SoundCloudKit
//
//  Created by Thomas Kollbach on 30.03.11.
//  Copyright 2011 com.soundcloud. All rights reserved.
//

#import "SCNumberToStringValueTransformer.h"

NSString *const SCNumberToStringValueTransformerName = @"SCNumberToStringValueTransformerName";

@implementation SCNumberToStringValueTransformer

#pragma mark Class Methods

+ (void)registerValueTransformer;
{
	[NSValueTransformer setValueTransformer:[[[SCNumberToStringValueTransformer alloc] init] autorelease]
									forName:SCNumberToStringValueTransformerName];
}

+ (BOOL)allowsReverseTransformation;
{
	return YES;
}

+ (Class)transformedValueClass;
{
	return [NSString class];
}

#pragma mark NSValueTransformer

- (id)transformedValue:(id)value;
{
	if ([value isKindOfClass:[NSString class]] || value == nil) return value;
		
    if (value && ![value respondsToSelector:@selector(stringValue)]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does not respond to -stringValue.", [value class]];
    }
	
	return [value stringValue];
}

- (id)reverseTransformedValue:(id)value;
{
    if (value && ![value respondsToSelector:@selector(doubleValue)]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does not respond to -doubleValue.", [value class]];
    }
    
    double doubleValue = [value doubleValue];
	return [NSNumber numberWithDouble:doubleValue];
}

@end
