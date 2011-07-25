//
//  SCFoursquarePlacePickerControllerDelegate.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 30.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class SCFoursquarePlacePickerController;

@protocol SCFoursquarePlacePickerControllerDelegate <NSObject>

@required
- (void)foursquarePlacePicker:(SCFoursquarePlacePickerController *)picker
           didFinishWithTitle:(NSString *)title
                 foursquareID:(NSString *)foursquareID
                     location:(CLLocation *)location;

@end
