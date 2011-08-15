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

@interface SCRecordingSaveViewController : UIViewController <UITableViewDelegate,
                                                             UITableViewDataSource,
                                                             UITextFieldDelegate,
                                                             UINavigationControllerDelegate,
                                                             UIImagePickerControllerDelegate,
                                                             UIActionSheetDelegate,
                                                             SCSharingMailPickerControllerDelegate,
                                                             SCFoursquarePlacePickerControllerDelegate,
                                                             SCAddConnectionViewControllerDelegate> {
    
    IBOutlet UITableView *tableView;
    IBOutlet UIToolbar *toolbar;
                                
    NSBundle *resourceBundle;
}

#pragma mark Accessors

- (void)setFileURL:(NSURL *)aFileURL;
- (void)setFileData:(NSData *)someFileData;

- (void)setPrivate:(BOOL)isPrivate;
- (void)setCoverImage:(UIImage *)aCoverImage;
- (void)setTitle:(NSString *)aTitle;
- (void)setCreationDate:(NSDate *)aCreationDate;
- (void)setCompletionHandler:(SCRecordingSaveViewControllerCompletionHandler)aCompletionHandler;

#pragma mark Foursquare

- (void)setFoursquareClientID:(NSString *)aClientID clientSecret:(NSString *)aClientSecret;

@end
