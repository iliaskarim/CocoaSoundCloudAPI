//
//  SCAddConnectionViewControllerDelegate.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 30.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCAddConnectionViewController;

@protocol SCAddConnectionViewControllerDelegate <NSObject>
@optional
- (void)addConnectionController:(SCAddConnectionViewController *)controller didFinishWithService:(NSString *)service success:(BOOL)success;
@end
