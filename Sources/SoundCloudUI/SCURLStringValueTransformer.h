//
//  SCURLStringValueTransformer.h
//  SoundCloudKit
//
//  Created by Thomas Kollbach on 18.03.11.
//  Copyright 2011 SoundCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SCURLStringValueTransformerName;

@interface SCURLStringValueTransformer : NSValueTransformer {
@private
    
}

+ (void)registerValueTransformer;

@end
