//
//  SCSoundCloudAPI-Private.h
//  SoundCloudAPI
//
//  Created by Ullrich Schäfer on 05.01.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCSoundCloudAPI.h"


@class SCSoundCloudAPIAuthentication;


@interface SCSoundCloudAPI (Private)

@property (nonatomic, readonly) SCSoundCloudAPIAuthentication *authentication;

@end
