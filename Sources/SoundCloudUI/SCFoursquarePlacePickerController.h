//
//  SCFoursquarePlacePickerController.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 30.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCRequest.h"
#import "SCFoursquarePlacePickerControllerDelegate.h"

@interface SCFoursquarePlacePickerController : UITableViewController <UITextFieldDelegate>
- (id)initWithDelegate:(id<SCFoursquarePlacePickerControllerDelegate>)aDelegate
              clientID:(NSString *)aClientID
          clientSecret:(NSString *)aClientSecret;
@end
