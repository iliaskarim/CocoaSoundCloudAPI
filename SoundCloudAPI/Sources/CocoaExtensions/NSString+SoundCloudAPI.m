//
//  NSString+SoundCloudAPI.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 07.10.09.
//  Copyright 2009 nxtbgthng. All rights reserved.
//

#import "NSString+SoundCloudAPI.h"


@implementation NSString (SoundCloudAPI)

+ (NSString *)stringWithUUID;
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
    return [(NSString *)string autorelease];
}

@end
