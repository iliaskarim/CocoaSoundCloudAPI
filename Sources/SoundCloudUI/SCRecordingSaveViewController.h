//
//  SCRecordingSaveViewController.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 25.10.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "SCSharingMailPickerController.h"
#import "SCFoursquarePlacePickerControllerDelegate.h"
#import "SCAddConnectionViewControllerDelegate.h"

typedef void(^SCRecordingSaveViewControllerCompletionHandler)(BOOL canceled, NSDictionary *trackInfo);

@class SCSwitch;
@class SCAccount;


@interface SCRecordingSaveViewController : UIViewController <UITableViewDelegate,
                                                             UITableViewDataSource,
                                                             UITextFieldDelegate,
                                                             UINavigationControllerDelegate,
                                                             UIImagePickerControllerDelegate,
                                                             UIActionSheetDelegate,
                                                             SCSharingMailPickerControllerDelegate,
                                                             SCFoursquarePlacePickerControllerDelegate,
                                                             SCAddConnectionViewControllerDelegate> {
    
    // UI
    IBOutlet UIButton *coverButton;
    IBOutlet UITextField *titleField;
    IBOutlet UITextField *locationField;
    IBOutlet SCSwitch *privateSwitch;
    IBOutlet UITableView *tableView;
    IBOutlet UIToolbar *toolbar;
}

#pragma mark Accessors

- (void)setFileURL:(NSURL *)aFileURL;
- (void)setFileData:(NSData *)someFileData;

- (void)setAccount:(SCAccount *)anAccount;
- (void)setPrivate:(BOOL)isPrivate;
- (void)setCoverImage:(UIImage *)aCoverImage;
- (void)setTitle:(NSString *)aTitle;
- (void)setCompletionHandler:(SCRecordingSaveViewControllerCompletionHandler)aCompletionHandler;

#pragma mark Actions

- (IBAction)privacyChanged:(id)sender;
- (IBAction)selectImage;

@end


#pragma mark -

//We need to expose those for IB

@interface SCRecordingSaveViewControllerHeaderView : UIView {}
@end

@interface SCRecordingSaveViewControllerTextField : UITextField {}
@end
