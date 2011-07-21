//
//  GPNetworkActivityController.h
//  YouAreHere
//
//  Created by Gernot Poetsch on 19.07.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GPNetworkActivityController : NSObject {
	NSUInteger numberOfActiveTransmissions;
}

+ (GPNetworkActivityController*)sharedActivityController;

@property (readonly) NSUInteger numberOfActiveTransmissions;

- (void)increaseNumberOfActiveTransmissions;
- (void)decreaseNumberOfActiveTransmissions;

@end
