//
//  SCURLStringValueTransformer.m
//  SoundCloudKit
//
//  Created by Thomas Kollbach on 18.03.11.
//  Copyright 2011 SoundCloud. All rights reserved.
//

#import "SCURLStringValueTransformer.h"

NSString *const SCURLStringValueTransformerName = @"SCURLStringValueTransformerName";

@implementation SCURLStringValueTransformer

#pragma mark Class Methods

+ (void)registerValueTransformer;
{
	[NSValueTransformer setValueTransformer:[[[SCURLStringValueTransformer alloc] init] autorelease]
					  				forName:SCURLStringValueTransformerName];
}

+ (BOOL)allowsReverseTransformation;
{
	return YES;
}

+ (Class)transformedValueClass;
{
	return [NSURL class];
}


#pragma mark NSValueTransformer

- (id)transformedValue:(id)value;
{
	if (value && ![value isKindOfClass:[NSString class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does is not of class NSString.", [value class]];
    }
	if (!value) return nil;
	if ([value isEqualToString:@""]) return nil;
	
	return [NSURL URLWithString:value];
}

- (id)reverseTransformedValue:(id)value;
{
	if (![value isKindOfClass:[NSURL class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does is not of class NSURL.", [value class]];
    }
	
	return [value absoluteString];
}


@end
