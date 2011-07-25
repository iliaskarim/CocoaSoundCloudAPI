//
//  SCAPITimestampValueTransformer.h
//  SoundCloudKit
//
//  Created by Thomas Kollbach on 18.03.11.
//  Copyright 2011 SoundCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SCAPITimestampValueTransformerName;

@interface SCAPITimestampValueTransformer : NSValueTransformer {
@private
    NSDateFormatter *apiDateFormatter;
}

+ (void)registerValueTransformer;

@end
