//
//  SCBundle.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 27.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCBundle : NSObject
+ (NSBundle *)bundle;
+ (UIImage *)imageFromPNGWithName:(NSString *)aName;
@end

#define SCLocalizedString(key, comment) [[SCBundle bundle] localizedStringForKey:key value:key table:nil]
