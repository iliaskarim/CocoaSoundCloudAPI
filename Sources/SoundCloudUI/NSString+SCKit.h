//
//  NSString+SCKit.h
//  SCKit
//
//  Created by Ullrich Schäfer on 16.03.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (SCKit)

- (id)JSONObject;

+ (NSString *)stringWithSeconds:(NSTimeInterval)seconds;
+ (NSString *)stringWithMilliseconds:(NSInteger)seconds;
+ (NSString *)stringWithInteger:(NSInteger)integer upperRange:(NSInteger)upperRange;

- (NSArray *)componentsSeparatedByWhitespacePreservingQuotations;


@end
