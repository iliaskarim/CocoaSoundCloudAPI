//
//  SCNumberToStringValueTransformer.h
//  SoundCloudKit
//
//  Created by Thomas Kollbach on 30.03.11.
//  Copyright 2011 Soundcloud All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SCNumberToStringValueTransformerName;

@interface SCNumberToStringValueTransformer : NSValueTransformer {
@private
    
}

+ (void)registerValueTransformer;

@end
