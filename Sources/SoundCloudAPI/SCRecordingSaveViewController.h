//
//  SCRecordingSaveViewController.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 25.10.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "SCRecordingSaveViewControllerDelegate.h"
//#import "SCSharingMailPickerController.h"
//#import "SCFoursquarePlacePickerControllerDelegate.h"
//#import "SCAddConnectionViewControllerDelegate.h"

@class SCUserFile;
@class SCSwitch;
@class SCFoursquarePlacePickerController;

typedef enum {
    SCRecordingSaveViewControllerModeSave,
    SCRecordingSaveViewControllerModeEdit
} SCRecordingSaveViewControllerMode;

@interface SCRecordingSaveViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate/*, SCSharingMailPickerControllerDelegate, SCFoursquarePlacePickerControllerDelegate, SCAddConnectionViewControllerDelegate*/> {
    
    id<SCRecordingSaveViewControllerDelegate> delegate;
    
    SCRecordingSaveViewControllerMode mode;

    IBOutlet UIButton *coverButton;
    IBOutlet UITextField *titleField;
    IBOutlet UITextField *locationField;
    IBOutlet SCSwitch *privateSwitch;
    
    IBOutlet UITableView *tableView;
    IBOutlet UIToolbar *toolbar;
    
@private
    SCUserFile *userFile;
    NSArray *availableConnections;
    NSMutableArray *unconnectedServices;
    SCFoursquarePlacePickerController *foursquareController;
}

- (id)initWithUserFile:(SCUserFile *)file mode:(SCRecordingSaveViewControllerMode)mode;

@property (nonatomic, assign) id<SCRecordingSaveViewControllerDelegate> delegate;
@property (nonatomic, readonly) SCUserFile *userFile;

- (IBAction)privacyChanged:(id)sender;
- (IBAction)selectImage;

@end

//We need to expose those for IB

@interface SCRecordingSaveViewControllerHeaderView : UIView {}
@end

@interface SCRecordingSaveViewControllerTextField : UITextField {}
@end


