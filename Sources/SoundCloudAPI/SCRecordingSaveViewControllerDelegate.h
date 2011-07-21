//
//  SCRecordingSaveViewControllerDelegate.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 25.10.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCRecordingSaveViewController;
@class SCUserFile;

@protocol SCRecordingSaveViewControllerDelegate <NSObject>
- (void)recordingSaveViewControllerDidFinish:(SCRecordingSaveViewController *)viewController reset:(BOOL)reset;
@end
