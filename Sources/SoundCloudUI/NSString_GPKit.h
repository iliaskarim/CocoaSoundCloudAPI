//
//  NSString_GPKit.h
//
//  Created by Gernot Poetsch on 19.02.09.
//  Copyright 2009 Gernot Poetsch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (GPKit) 

+ (NSString *)stringWithUUID;

- (NSString *)stringByEscapingXMLEntities;
- (NSString *)stringByUnescapingXMLEntities;

- (NSString *)stringByAddingURLEncoding;
- (NSString *)stringByRemovingURLEncoding;

- (NSDictionary *)dictionaryFromQuery;

- (NSString *)md5Value;

@end
