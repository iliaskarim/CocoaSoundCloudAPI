//
//  SCFoursquarePlacePickerController.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 30.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "GPWebAPI.h"
#import "SCFoursquarePlacePickerControllerDelegate.h"

@interface SCFoursquarePlacePickerController : UITableViewController <CLLocationManagerDelegate, GPWebAPIDelegate, UITextFieldDelegate> {
    id<SCFoursquarePlacePickerControllerDelegate> delegate;
    GPWebAPI *api;
    NSArray *venues;
    CLLocationManager *locationManager;
    id venueRequestIdentifier;
}

- (id)initWithDelegate:(id<SCFoursquarePlacePickerControllerDelegate>)aDelegate;

@end
