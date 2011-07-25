//
//  SCSharingMailPickerController.h
//  Soundcloud
//
//  Created by Ullrich Schäfer on 22.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@protocol SCSharingMailPickerControllerDelegate;


@interface SCSharingMailPickerController : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITextField				*emailsField;
	UITableViewController	*autocompleteTableViewController;
	
	UIBarButtonItem			*doneBarButton;
	
	UIView			*inputView;
	
	NSMutableArray	*result;
	
	NSMutableArray	*autocompleteData;
	
	NSOperationQueue	*autocompleteOperationQueue;
	
	NSDictionary		*addressBookData;
	NSOperationQueue	*fetchAddressbookDataOperationQueue;	
	
	id<SCSharingMailPickerControllerDelegate> delegate;
	
	id userInfo;
}

- (id)initWithDelegate:(id<SCSharingMailPickerControllerDelegate>)delegate;

@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) NSArray *result;

@end


@protocol SCSharingMailPickerControllerDelegate <NSObject>
- (void)sharingMailPickerController:(SCSharingMailPickerController *)controller didFinishWithResult:(NSArray *)emailAdresses;
- (void)sharingMailPickerControllerDidCancel:(SCSharingMailPickerController *)controller;
@end