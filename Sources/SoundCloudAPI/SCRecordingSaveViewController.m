//
//  SCRecordingSaveViewController.m
//  Soundcloud
//
//  Created by Gernot Poetsch on 25.10.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "QuartzCore_GPKit.h"
#import "UIImage_GPKit.h"
#import "SCSwitch.h"
#import "GPTableCellBackgroundView.h"
#import "GPURLConnection.h"

//#import "SCiPhoneAppDelegate.h"
//#import "SCResourceController.h"
//#import "SCShareConnectionCollectionController.h"
//#import "SCUserFile.h"
//#import "SCUserFileManager.h"
//#import "SCShareConnection.h"
//#import "SCSharingMailPickerController.h"
//#import "SCiPhoneTabBarController.h"
//#import "SCiPhoneMeUserViewController.h"
//#import "SCFoursquarePlacePickerController.h"
#import "SCConstants.h"
//#import "SCAddConnectionViewController.h"

#import "SCRecordingSaveViewController.h"


#define COVER_WIDTH 600.0
#define TEXTBOX_LEFT 102.0
#define TEXTBOX_RIGHT 9.0
#define TEXTBOX_TOP 9.0
#define TEXTBOX_HEIGHT 84.0


@interface SCRecordingSaveViewController ()
@property (nonatomic, retain) NSArray *availableConnections;
- (void)updateInterface;
- (void)shareConnectionsDidUpdate;
- (IBAction)shareConnectionSwitchToggled:(id)sender;
- (IBAction)openCameraPicker;
- (IBAction)openImageLibraryPicker;
- (IBAction)openPlacePicker;
- (IBAction)closePlacePicker;
- (IBAction)resetImage;
- (IBAction)upload;
- (IBAction)recordAnother;
- (IBAction)delete;
@end



@implementation SCRecordingSaveViewController

#pragma mark Class methods

const NSArray *allServices = nil;

+ (void)initialize;
{
//	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
//															 [NSNumber numberWithBool:NO], SCDefaultsKeyRecordingIsPrivate,
//															 nil]];
    allServices = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"service_twitter", @"Twitter"), @"displayName",
                    @"twitter", @"service",
                    nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"service_facebook", @"Facebook"), @"displayName",
                    @"facebook_profile", @"service",
                    nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"service_tumblr", @"Tumblr"), @"displayName",
                    @"tumblr", @"service",
                    nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"service_foursquare", @"Foursquare"), @"displayName",
                    @"foursquare", @"service",
                    nil],
                   nil];
}


#pragma mark Lifecycle

- (id)initWithUserFile:(SCUserFile *)file mode:(SCRecordingSaveViewControllerMode)aMode;
{
    if ((self = [super initWithNibName:@"RecordingSave" bundle:nil])) {
        
        mode = aMode;
        userFile = [file retain];
        
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navigation_back", @"Back")
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:nil
                                                                                 action:nil] autorelease];
        
//        foursquareController = [[SCFoursquarePlacePickerController alloc] initWithDelegate:self];
//        foursquareController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                                               target:self
//                                                                                                               action:@selector(closePlacePicker)] autorelease];
        
        [self.navigationController setToolbarHidden:NO];
        
//        [[appDelegate.resourceController shareConnectionsForMeUser] resetAndReload];
    }
    return self;
}


- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [foursquareController release];
    [availableConnections release];
    [unconnectedServices release];
    [userFile release];
    [super dealloc];
}


#pragma mark Accessors

@synthesize delegate;
@synthesize userFile;
@synthesize availableConnections;

- (void)setAvailableConnections:(NSArray *)value;
{
    [value retain]; [availableConnections release]; availableConnections = value;
    
    
    [unconnectedServices release];
    unconnectedServices = [allServices mutableCopy];
    
//    //Set the unconnected Services
//    for (SCShareConnection *connection in availableConnections) {
//        NSDictionary *connectedService = nil;
//        for (NSDictionary *unconnectedService in unconnectedServices) {
//            if ([connection.service isEqualToString:[unconnectedService objectForKey:@"service"]]) {
//                connectedService = unconnectedService;
//            }
//        }
//        if (connectedService) [unconnectedServices removeObject:connectedService];
//    }
//    
//    //Set default sharing connections if we don't yet have some
//    if (!userFile.sharingConnections) {
//        NSMutableArray *defaultSharingConnections = [[[NSMutableArray alloc] initWithCapacity:availableConnections.count] autorelease];
//        for (SCShareConnection *connection in availableConnections) {
//            if ((connection.postPublish) ||
//                [userFile.sharingConnections containsObject:connection])
//            {
//                [defaultSharingConnections addObject:connection];
//            }
//        }
//        userFile.sharingConnections = defaultSharingConnections;
//    }
    
    [tableView reloadData];
}


#pragma mark ViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    tableView.backgroundColor = tableView.tableHeaderView.backgroundColor;
    
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:3];
    if (mode == SCRecordingSaveViewControllerModeSave) {
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"record_another_sound", @"Record another sound")
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(recordAnother)] autorelease]];
    } else {
        UIButton *deleteButton = [[UIButton alloc] init];
        [deleteButton setImage:[UIImage imageNamed:@"delete_bar.png"] forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"delete_bar_pressed.png"] forState:UIControlStateSelected];
        [deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton sizeToFit];
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithCustomView:deleteButton] autorelease]];
		[deleteButton release];
    }
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"upload_and_share", @"Upload & Share")
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(upload)] autorelease]];
    toolbar.items = toolbarItems;
    
    [self updateInterface];
    
    [self shareConnectionsDidUpdate];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(shareConnectionsDidUpdate)
//                                                 name:SCRemoteCollectionDidLoadNotification
//                                               object:[appDelegate.resourceController shareConnectionsForMeUser]];
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:SCRemoteCollectionDidLoadNotification
//                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
//    userFile.title = titleField.text;
//    userFile.locationText = locationField.text;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return YES;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        return YES;
    }
    return NO;
}

- (void)updateInterface;
{
//    titleField.text = userFile.title;
//    locationField.text = userFile.locationText;
    
    coverButton.layer.masksToBounds = YES;
    coverButton.layer.cornerRadius = 3.0;
    
//    if (userFile.coverImage) {
//        [coverButton setImage:[userFile.coverImage imageByResizingTo:coverButton.bounds.size] forState:UIControlStateNormal];
//    } else {
//        [coverButton setImage:[UIImage imageNamed:@"add-image.png"] forState:UIControlStateNormal];
//    }
    
//	privateSwitch.on = !userFile.isPrivate;
    privateSwitch.onText = NSLocalizedString(@"sc_upload_public", @"Public");
    privateSwitch.offText = NSLocalizedString(@"sc_upload_private", @"Private");
}


#pragma mark Observing

- (void)shareConnectionsDidUpdate;
{
//    self.availableConnections = [appDelegate.resourceController shareConnectionsForMeUser].items;
}


#pragma mark TableView

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
//    if (userFile.isPrivate){
//        return 1;
//    } else {
        return availableConnections.count + unconnectedServices.count;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    if (userFile.isPrivate) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"mailShare"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mailShare"] autorelease];
            GPTableCellBackgroundView *backgroundView = [[[GPTableCellBackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
            backgroundView.backgroundColor = aTableView.backgroundColor;
            backgroundView.borderColor = [UIColor colorWithWhite:0.27 alpha:1.0];
            cell.backgroundView = backgroundView;
            cell.textLabel.backgroundColor = aTableView.backgroundColor;
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = aTableView.backgroundColor;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
                
        cell.textLabel.text = NSLocalizedString(@"sc_upload_with_access", @"With access");
//        if (userFile.sharingMailAddresses.count == 0) {
//            cell.detailTextLabel.text = NSLocalizedString(@"sc_upload_only_you", @"Only you");
//        } else {
//            cell.detailTextLabel.text = [userFile.sharingMailAddresses componentsJoinedByString:@", "];
//        }

        [(GPTableCellBackgroundView *)cell.backgroundView setPosition:[aTableView cellPositionForIndexPath:indexPath]];
        
        return cell;
        
//    } else {
//        if (indexPath.row < availableConnections.count) {
//            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"connection"];
//            if (!cell) {
//                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"connection"] autorelease];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                GPTableCellBackgroundView *backgroundView = [[[GPTableCellBackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
//                backgroundView.backgroundColor = aTableView.backgroundColor;
//                backgroundView.borderColor = [UIColor colorWithWhite:0.27 alpha:1.0];
//                cell.backgroundView = backgroundView;
//                cell.textLabel.backgroundColor = aTableView.backgroundColor;
//                cell.textLabel.font = [UIFont systemFontOfSize:16.0];
//                cell.textLabel.textColor = [UIColor whiteColor];
//            }
//            
//            SCShareConnection *connection = [availableConnections objectAtIndex:indexPath.row];
//            
//            cell.textLabel.text = connection.displayName;
//            
//            SCSwitch *accessorySwitch = [[[SCSwitch alloc] init] autorelease];
//            accessorySwitch.offBackgroundImage = [UIImage imageNamed:@"switch_gray.png" leftCapWidth:5 topCapHeight:5];
//            accessorySwitch.on = [userFile.sharingConnections containsObject:connection];
//            [accessorySwitch addTarget:self action:@selector(shareConnectionSwitchToggled:) forControlEvents:UIControlEventValueChanged];
//            if ([connection.service isEqualToString:@"foursquare"] && !userFile.foursquareID) {
//                accessorySwitch.on = NO;
//            }
//            cell.accessoryView = accessorySwitch;
//            
//            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"service_%@.png", connection.service]];
//            
//            [(GPTableCellBackgroundView *)cell.backgroundView setPosition:[aTableView cellPositionForIndexPath:indexPath]];
//            
//            return cell;
//        } else {
//            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"newConnection"];
//            if (!cell) {
//                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"newConnection"] autorelease];
//                cell.selectionStyle = UITableViewCellSelectionStyleGray;
//                GPTableCellBackgroundView *backgroundView = [[[GPTableCellBackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
//                backgroundView.backgroundColor = aTableView.backgroundColor;
//                backgroundView.borderColor = [UIColor colorWithWhite:0.27 alpha:1.0];
//                cell.backgroundView = backgroundView;
//                cell.textLabel.backgroundColor = aTableView.backgroundColor;
//                cell.textLabel.font = [UIFont systemFontOfSize:16.0];
//                cell.textLabel.textColor = [UIColor whiteColor];
//                cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicator.png"]]autorelease];
//                cell.detailTextLabel.text = NSLocalizedString(@"configure", @"Configure");
//                cell.detailTextLabel.textColor = [UIColor whiteColor];
//                cell.detailTextLabel.backgroundColor = aTableView.backgroundColor;
//            }
//            
//            NSDictionary *service = [unconnectedServices objectAtIndex:indexPath.row - availableConnections.count];
//            cell.textLabel.text = [service objectForKey:@"displayName"];
//            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"service_%@.png", [service objectForKey:@"service"]]];
//            
//            [(GPTableCellBackgroundView *)cell.backgroundView setPosition:[aTableView cellPositionForIndexPath:indexPath]];
//            return cell;
//        }
//    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return NSLocalizedString(@"sc_upload_sharing_options", @"Sharing Options");
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)] autorelease];
    headerView.backgroundColor = aTableView.backgroundColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 10.0, 0.0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = aTableView.backgroundColor;
    label.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = [self tableView:aTableView titleForHeaderInSection:section];
    [headerView addSubview:label];
    [label release];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 28.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
//    if (userFile.isPrivate) {
        return nil;
//    } else {
//        if (availableConnections.count == 0) {
//            return nil; // @"To add sharing options, go to your settings on SoundCloud.com and select 'Connections'";
//        } else {
//            return NSLocalizedString(@"connection_list_footer", @"To change your default sharing options, go to your settings on SoundCloud and select 'Connections'");
//        }
//    }
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section;
{
//    if (userFile.isPrivate) {
        return nil;
//    } else {
//        UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)] autorelease];
//        footerView.backgroundColor = aTableView.backgroundColor;
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(footerView.bounds, 10.0, 0.0)];
//        label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//        label.backgroundColor = aTableView.backgroundColor;
//        label.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
//        label.font = [UIFont systemFontOfSize:13.0];
//        label.text = [self tableView:aTableView titleForFooterInSection:section];
//        label.numberOfLines = 2;
//        [footerView addSubview:label];
//        [label release];
//        return footerView;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 48.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    if (userFile.isPrivate) {
        if (indexPath.section == 0 && indexPath.row == 0) {
//            SCSharingMailPickerController  *controller = [[SCSharingMailPickerController alloc] initWithDelegate:self];
//			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
//			navController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
//			controller.title = NSLocalizedString(@"sc_upload_with_access", @"With Access");
//			controller.result = userFile.sharingMailAddresses;
//            [self presentModalViewController:navController animated:YES];
//			[controller release];
//			[navController release];
            
            [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
//    } else {
//        if (indexPath.row >= availableConnections.count) {
//            NSDictionary *service = [unconnectedServices objectAtIndex:indexPath.row - availableConnections.count];
//            SCAddConnectionViewController *controller = [[SCAddConnectionViewController alloc] initWithService:[service objectForKey:@"service"] delegate:self];
//            controller.title = [NSString stringWithFormat:NSLocalizedString(@"sc_upload_connect_to", @"Connect %@"), [service objectForKey:@"displayName"]];
//            [self.navigationController pushViewController:controller animated:YES];
//            [controller release];
//            [aTableView deselectRowAtIndexPath:indexPath animated:YES];
//        }
//    }

}


#pragma mark SCSharingMailPickerControllerDelegate

//- (void)sharingMailPickerController:(SCSharingMailPickerController *)controller didFinishWithResult:(NSArray *)emailAdresses;
//{
//    userFile.sharingMailAddresses = emailAdresses;
//    [tableView reloadData];
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)sharingMailPickerControllerDidCancel:(SCSharingMailPickerController *)controller;
//{
//    [self dismissModalViewControllerAnimated:YES];
//}


#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == titleField) {
//        userFile.title = text;
    } else if (textField == locationField) {
//        userFile.locationText = text;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    if (textField == titleField) {
//        userFile.title = textField.text;
    } else if (textField == locationField) {
//        userFile.locationText = textField.text;
    }
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    if (textField == locationField) {
        [titleField resignFirstResponder]; //So we don't get the keyboard when coming back
        [self openPlacePicker];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return NO;
}


#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self openImageLibraryPicker];  
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1
               && [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera].count > 0) {
        [self openCameraPicker];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self resetImage];
    }
}


#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
{
    UIImage *actualImage = image;
    if (!CGSizeEqualToSize(actualImage.size, CGSizeMake(COVER_WIDTH, COVER_WIDTH))) {
        actualImage = [actualImage imageByResizingTo:CGSizeMake(COVER_WIDTH, COVER_WIDTH)];
    }
    
//    userFile.coverImage = actualImage;
    
//    if (userFile.coverImage) {
//        [coverButton setImage:[userFile.coverImage imageByResizingTo:coverButton.bounds.size] forState:UIControlStateNormal];
//    } else {
        [coverButton setImage:[UIImage imageNamed:@"add-image.png"] forState:UIControlStateNormal];
//    }
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark Place Picker Delegate

- (void)foursquarePlacePicker:(SCFoursquarePlacePickerController *)picker
           didFinishWithTitle:(NSString *)title
                 foursquareID:(NSString *)aFoursquareID
                     location:(CLLocation *)aLocation;
{
    locationField.text = title;
//    userFile.locationText = title;
//    userFile.location = aLocation;
//    userFile.foursquareID = aFoursquareID;
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark Add Connection Delegate

//- (void)addConnectionController:(SCAddConnectionViewController *)controller didFinishWithService:(NSString *)service success:(BOOL)success;
//{
//    if (success) {
//        NSDictionary *serviceToRemove = nil;
//        for (NSDictionary *unconnectedService in unconnectedServices) {
//            if ([[unconnectedService objectForKey:@"service"] isEqualToString:service]) {
//                serviceToRemove = unconnectedService;
//            }
//        }
//        if (serviceToRemove) [unconnectedServices removeObject:serviceToRemove];
//        [tableView reloadData];
//    }
//    if (self.navigationController.topViewController == controller) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    [[appDelegate.resourceController shareConnectionsForMeUser] resetAndReload];
//}


#pragma mark Actions

- (IBAction)shareConnectionSwitchToggled:(SCSwitch *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[(UIView *)sender superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
//    SCShareConnection *connection = [availableConnections objectAtIndex:indexPath.row];
//    
//    //If this is a foursquare switch, we don't have a venue and want to switch it on, display place picker
//    if ([connection.service isEqualToString:@"foursquare"] && !userFile.foursquareID && [sender isOn]) {
//        [self openPlacePicker];
//    }
//    
//    NSMutableArray *newSharingConnections = [userFile.sharingConnections mutableCopy];
//    if ([sender isOn]) {
//        [newSharingConnections addObject:connection];
//    } else {
//        [newSharingConnections removeObject:connection];
//    }
//    userFile.sharingConnections = newSharingConnections;
//    [newSharingConnections release];
}

- (IBAction)privacyChanged:(id)sender;
{
//    if (sender == privateSwitch) {
//		userFile.isPrivate = !privateSwitch.on;
//        [[NSUserDefaults standardUserDefaults] setBool:!privateSwitch.on forKey:SCDefaultsKeyRecordingIsPrivate];
//        [tableView reloadData];
//    }
}

- (IBAction)selectImage;
{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"recording_image", @"Cover Image")
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
//                                         destructiveButtonTitle:(userFile.coverImage) ? NSLocalizedString(@"artwork_reset", @"Reset") : nil
//                                              otherButtonTitles:
//                            ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary].count > 0) ? NSLocalizedString(@"use_existing_image", @"Photo Library") : nil,
//                            ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera].count > 0) ? NSLocalizedString(@"take_new_picture", @"Camera") : nil,
//                            nil];
//    [sheet showInView:self.view];
//    [sheet release];
}

- (IBAction)openCameraPicker;
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (IBAction)openImageLibraryPicker;
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (IBAction)openPlacePicker;
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:foursquareController];
    navController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    [self presentModalViewController:navController animated:YES];
    [navController release];
}

- (IBAction)closePlacePicker;
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)resetImage;
{
//    userFile.coverImage = nil;
}

- (IBAction)upload;
{
//    [userFile startUpload];
//    [appDelegate.userFileManager synchronizeUserFile:userFile];
//    [delegate recordingSaveViewControllerDidFinish:self reset:YES];
//    if (mode == SCRecordingSaveViewControllerModeSave) {
//        SCiPhoneMeUserViewController *meUserController = [appDelegate.tabBarController showMeUserControllerInYouTab];
//        [meUserController setSelectedTab:SCUserProfileViewTabTracks];
//    }
}

- (IBAction)recordAnother;
{
//    [appDelegate.userFileManager synchronizeUserFile:userFile];
//    [delegate recordingSaveViewControllerDidFinish:self reset:YES];
}

- (IBAction)delete;
{
//    [appDelegate.userFileManager removeUserFile:userFile];
//    [delegate recordingSaveViewControllerDidFinish:self reset:YES];
}


@end


#pragma mark -

@implementation SCRecordingSaveViewControllerHeaderView

- (void)drawRect:(CGRect)rect;
{
    [super drawRect:rect];
    
    CGRect textRect = CGRectMake(self.bounds.origin.x + TEXTBOX_LEFT,
                                 self.bounds.origin.y + TEXTBOX_TOP,
                                 self.bounds.size.width - TEXTBOX_LEFT - TEXTBOX_RIGHT,
                                 TEXTBOX_HEIGHT);
    textRect = CGRectInset(textRect, 0.5, 0.5);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0.27 alpha:1.0] set];
    CGContextSetLineWidth(context, 1.0);
    GP_CGContextAddRoundedRect(context, textRect, 7.0);
    CGContextMoveToPoint(context, CGRectGetMinX(textRect), CGRectGetMidY(textRect)+0.5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(textRect), CGRectGetMidY(textRect)+0.5);
    CGContextStrokePath(context);
}

@end

@implementation SCRecordingSaveViewControllerTextField

- (void)drawPlaceholderInRect:(CGRect)rect;
{
    [[UIColor colorWithWhite:0.6 alpha:1.0] setFill];
    [self.placeholder drawInRect:rect withFont:self.font];
}

@end

