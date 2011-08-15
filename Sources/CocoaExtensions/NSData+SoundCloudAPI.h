//
//  NSData+SoundCloudAPI.h
//  SCKit
//
//  Created by Ullrich Schäfer on 16.03.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (SoundCloudAPI)

- (id)JSONObject;
- (NSString *)errorMessageFrom422Error;

@end
