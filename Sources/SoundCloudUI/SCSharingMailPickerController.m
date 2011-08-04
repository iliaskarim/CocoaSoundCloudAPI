//
//  SCSharingMailPickerController.m
//  Soundcloud
//
//  Created by Ullrich Schäfer on 22.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//


#import "GPCellLoader.h"
#import "SCNameAndEmailCell.h"
#import "SCBundle.h"

#import "SCSharingMailPickerController.h"


@interface SCFetchAddressbookOperation : NSOperation
{
@private
	id	_target;
	SEL	_selector;
}
- (id)initWithTarget:(id)target selector:(SEL)selector;
@end


#pragma mark -

@interface SCDoAutocompleteionOperation : NSOperation
{
@private
	id		_target;
	SEL		_selector;
	NSDictionary	*_addressbookData;
	NSString		*_autocompleteString;
}

- (id)initWithTarget:(id)target selector:(SEL)selector addressbookData:(NSDictionary *)addressbookData autocompleteString:(NSString *)autocompleteString;

@end


#pragma mark -


@interface SCSharingMailPickerController ()
- (NSArray *)arrayOfEmailsInString:(NSString *)string unparsebleStrings:(NSArray **)unparsableRet;
- (void)updateAutocompletionWithInputFieldValue:(NSString *)textFieldValue;
- (void)setAutocompleteData:(NSArray *)_autocompleteData;

- (void)updateResult;

@property (nonatomic, retain) NSDictionary *addressBookData;
@end


@implementation SCSharingMailPickerController

#pragma mark Lifecycle

- (id)initWithDelegate:(id<SCSharingMailPickerControllerDelegate>)aDelegate;
{
	if ((self = [super initWithNibName:nil bundle:nil])) {
		self.title = SCLocalizedString(@"shared_to_email_adresses", @"Email Addresses");
		delegate = aDelegate;
		autocompleteOperationQueue = [[NSOperationQueue alloc] init];
		autocompleteData = [[NSMutableArray alloc] init];
		autocompleteTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
		autocompleteTableViewController.tableView.delegate = self;
		autocompleteTableViewController.tableView.dataSource = self;
		result = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		
		fetchAddressbookDataOperationQueue = [[NSOperationQueue alloc] init];
		NSOperation *fetchAddressbookDataOperation = [[SCFetchAddressbookOperation alloc] initWithTarget:self selector:@selector(setAddressBookData:)];
		[fetchAddressbookDataOperationQueue addOperation:fetchAddressbookDataOperation];
		[fetchAddressbookDataOperation release];
	}
	return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[addressBookData release];
	[autocompleteOperationQueue cancelAllOperations];
	[autocompleteOperationQueue release];
	[autocompleteData release];
	[result release];
	[inputView release];
	[doneBarButton release];
	[emailsField release];
	[autocompleteTableViewController release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize addressBookData;
@synthesize userInfo;
@synthesize result;

- (void)setAddressBookData:(NSDictionary *)value;
{
	[value retain]; [addressBookData release]; addressBookData = value;
	[self updateAutocompletionWithInputFieldValue:emailsField.text];
}

- (void)setAutocompleteData:(NSMutableArray *)_autocompleteData;
{
	[_autocompleteData retain]; [autocompleteData release]; autocompleteData = _autocompleteData;
	[autocompleteTableViewController.tableView reloadData];
}

- (NSArray *)result;
{
	[self updateResult];
	return result;
}

- (void)setResult:(NSArray *)value;
{
	if (emailsField) {
		emailsField.text = [value componentsJoinedByString:@", "];
		[self updateResult];
	} else {
		[result removeAllObjects];
		[result addObjectsFromArray:value];
	}
}


#pragma mark View loading

- (void)viewDidLoad;
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
	
	doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																  target:self
																  action:@selector(done:)];
	doneBarButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = doneBarButton;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						   target:self
																						   action:@selector(cancel:)] autorelease];
	
	CGRect inputRect = CGRectMake(CGRectGetMinX(self.view.bounds),
								  CGRectGetMinY(self.view.bounds),
								  CGRectGetWidth(self.view.bounds),
								  44);
	inputView = [[UIView alloc] initWithFrame:inputRect];
	inputView.opaque = NO;
	
	UIView *inputBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(inputRect),
																			CGRectGetMinX(inputRect),
																			CGRectGetWidth(inputRect),
																			56)] autorelease];
	inputBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[SCBundle imageFromPNGWithName:@"mailInputBackground"]];
	inputBackgroundView.opaque = NO;
	[inputView addSubview:inputBackgroundView];
	
	UILabel *inputLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	inputLabel.text = @"To:";
	inputLabel.textColor = [UIColor darkGrayColor];
	[inputLabel sizeToFit];
	inputLabel.frame = CGRectMake(CGRectGetMinX(inputLabel.frame) + 4,
								  CGRectGetMidY(inputRect) - CGRectGetMidY(inputLabel.frame),
								  CGRectGetWidth(inputLabel.frame),
								  CGRectGetHeight(inputLabel.frame));
	
	UIButton *addFromAddresbookButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addFromAddresbookButton addTarget:self action:@selector(addFromAB:) forControlEvents:UIControlEventTouchUpInside];
	addFromAddresbookButton.frame = CGRectMake(CGRectGetMaxX(inputRect) - CGRectGetWidth(addFromAddresbookButton.frame) - 4,
											   CGRectGetMidY(inputRect) - CGRectGetMidY(addFromAddresbookButton.frame),
											   CGRectGetWidth(addFromAddresbookButton.frame),
											   CGRectGetHeight(addFromAddresbookButton.frame));
	
	emailsField = [[UITextField alloc] initWithFrame:CGRectZero];
	emailsField.delegate = self;
	emailsField.autocorrectionType = UITextAutocorrectionTypeNo;
	emailsField.keyboardType = UIKeyboardTypeEmailAddress;
	[emailsField sizeToFit];
	emailsField.text = [result componentsJoinedByString:@", "];
	emailsField.frame = CGRectMake(CGRectGetMaxX(inputLabel.frame) + 4,
								   CGRectGetMidY(inputRect) - CGRectGetMidY(emailsField.frame),
								   CGRectGetMinX(addFromAddresbookButton.frame) - CGRectGetMaxX(inputLabel.frame) - 8,
								   CGRectGetHeight(emailsField.frame));
	
	
	[inputView addSubview:addFromAddresbookButton];
	[inputView addSubview:inputLabel];
	[inputView addSubview:emailsField];
	[self.view addSubview:inputView];
	
	autocompleteTableViewController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
															CGRectGetMaxY(inputRect),
															CGRectGetWidth(self.view.bounds),
															CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputRect));
	autocompleteTableViewController.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
	[self.view addSubview:autocompleteTableViewController.view];
}

- (void)viewDidUnload;
{
	[super viewDidUnload];
	[doneBarButton release]; doneBarButton = nil;
	[emailsField release]; emailsField = nil;
}

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
	[emailsField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated;
{
	[super viewWillDisappear:animated];
	[autocompleteOperationQueue cancelAllOperations];
}


#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification;
{
    NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    CGRect keyboardFrame;
    [keyboardFrameValue getValue:&keyboardFrame];
	
	[UIView beginAnimations:@"tableViewFrame" context:nil];
	autocompleteTableViewController.view.frame = CGRectMake(CGRectGetMinX(inputView.frame),
															CGRectGetMaxY(inputView.frame),
															CGRectGetWidth(inputView.frame),
															CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(inputView.frame) - keyboardFrame.size.height);
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification;
{
	[UIView beginAnimations:@"tableViewFrame" context:nil];
	autocompleteTableViewController.view.frame = CGRectMake(CGRectGetMinX(inputView.frame),
															CGRectGetMaxY(inputView.frame),
															CGRectGetWidth(inputView.frame),
															CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(inputView.frame));
	[UIView commitAnimations];
}


#pragma mark Actions

- (IBAction)done:(id)sender;
{
	[delegate sharingMailPickerController:self didFinishWithResult:self.result];
}

- (IBAction)cancel:(id)sender;
{
	[delegate sharingMailPickerControllerDidCancel:self];
}

- (IBAction)addFromAB:(id)sender;
{
	ABPeoplePickerNavigationController *controller = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	controller.navigationBar.barStyle = UIBarStyleBlack;
	[controller setPeoplePickerDelegate:self];
	[controller setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
	
	[self.navigationController presentModalViewController:controller animated:YES];	
}


#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
{
	NSMutableString *resultingString = [[textField.text mutableCopy] autorelease];
	[resultingString replaceCharactersInRange:range withString:replacementString];
	
	[self updateAutocompletionWithInputFieldValue:resultingString];
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField;
{
	[self done:_textField];
	return YES;
}


#pragma mark ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
{
	return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier;
{
	if (property == kABPersonEmailProperty) {
		ABMultiValueRef emailValue = ABRecordCopyValue(person, property);
		CFIndex addressIndex = ABMultiValueGetIndexForIdentifier(emailValue, identifier);
		NSString *emailToShareTo = [(NSString *)ABMultiValueCopyValueAtIndex(emailValue, addressIndex) autorelease];
		CFRelease(emailValue);
		
		NSArray *unparsable = nil;
		NSMutableArray *emails = [[[self arrayOfEmailsInString:emailsField.text unparsebleStrings:&unparsable] mutableCopy] autorelease];
		[emails addObject:emailToShareTo];
		emailsField.text = [emails componentsJoinedByString:@", "];
		
		doneBarButton.enabled = emails.count > 0;
		
		[self dismissModalViewControllerAnimated:YES];
		return NO;
	}
	
	return YES;
}


#pragma mark Private

- (void)updateResult;
{
	if (!emailsField) return;
	
	NSArray *unparsable = nil;
	[result removeAllObjects];
	NSArray *emails = [self arrayOfEmailsInString:emailsField.text unparsebleStrings:&unparsable];
	for (NSString *email in emails) {
		if (![result containsObject:email])
			[result addObject:email];
	}
	
	if (unparsable) {
		NSLog(@"unparsable mail adresses: %@", [unparsable componentsJoinedByString:@", "]);
	}
	
	doneBarButton.enabled = result.count > 0;
}

- (NSArray *)arrayOfEmailsInString:(NSString *)string unparsebleStrings:(NSArray **)unparsableRet;
{
	NSMutableArray *emails = [NSMutableArray array];
	NSMutableArray *unparsable = [NSMutableArray array];
	
	NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx]; 
	NSCharacterSet *splitChars = [NSCharacterSet characterSetWithCharactersInString:@", "];
	
	
	NSScanner *scanner = [NSScanner scannerWithString:string];
	while (![scanner isAtEnd]) {
		NSString *currentScannedString = nil;
		if ([scanner scanUpToCharactersFromSet:splitChars intoString:&currentScannedString]) {
			if ([emailTest evaluateWithObject:currentScannedString] == YES) 
			{
				[emails addObject:currentScannedString];
			} else {
				[unparsable addObject:currentScannedString];
			}
		} else {
			[scanner setScanLocation: [scanner scanLocation] +1];
		}
	}
	
	if (unparsable.count > 0)
		*unparsableRet = unparsable;
	return emails;
}

- (void)updateAutocompletionWithInputFieldValue:(NSString *)textFieldValue;
{
	if (!textFieldValue)
		textFieldValue = emailsField.text;
	assert([NSThread isMainThread]);
	NSArray *unparsable = nil;
	NSArray *emails = [self arrayOfEmailsInString:textFieldValue unparsebleStrings:&unparsable];
	
	[autocompleteOperationQueue cancelAllOperations];
	NSOperation *autocompleteOperation = [[SCDoAutocompleteionOperation alloc] initWithTarget:self
																					 selector:@selector(setAutocompleteData:)
																			  addressbookData:addressBookData
																		   autocompleteString:[unparsable componentsJoinedByString:@" "]];
	[autocompleteOperationQueue addOperation:autocompleteOperation];
	[autocompleteOperation release];
	doneBarButton.enabled = emails.count > 0;
}


#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	return autocompleteData.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSString *reuseIdentifier = @"NameAndEmailCell";
	SCNameAndEmailCell *cell = (SCNameAndEmailCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
        cell = [[[SCNameAndEmailCell alloc] init] autorelease];
//		GPCellLoader *cellLoader = [[GPCellLoader alloc] initWithNibNamed:@"NameAndEmailCell"];
//		cell = (SCNameAndEmailCell *)cellLoader.cell;
//		[cellLoader release];
	}
	NSDictionary *personData = [autocompleteData objectAtIndex:indexPath.row];
	cell.name = [personData objectForKey:@"name"];
	cell.email = [personData objectForKey:@"email"];
	cell.mailType = [personData objectForKey:@"mailType"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSDictionary *personData = [autocompleteData objectAtIndex:indexPath.row];
	
	NSArray *unparsable = nil;
	NSMutableArray *emails = [[[self arrayOfEmailsInString:emailsField.text unparsebleStrings:&unparsable] mutableCopy] autorelease];
	[emails addObject:[personData objectForKey:@"email"]];
	
	emailsField.text = [NSString stringWithFormat:@"%@, ", [emails componentsJoinedByString:@", "]];
	
	[autocompleteData removeAllObjects];
	[autocompleteTableViewController.tableView reloadData];
	
	doneBarButton.enabled = emails.count > 0;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

@end


#pragma mark -

@implementation SCDoAutocompleteionOperation

#pragma mark Lifecycle

- (id)initWithTarget:(id)target selector:(SEL)selector addressbookData:(NSDictionary *)addressbookData autocompleteString:(NSString *)autocompleteString;
{
	if ((self = [super init])) {
		_target = [target retain];
		_selector = selector;
		_addressbookData = [addressbookData retain];
		_autocompleteString = [autocompleteString retain];
	}
	return self;
}

- (void)dealloc;
{
	[_target release];
	[_addressbookData release];
	[_autocompleteString release];
	[super dealloc];
}

#pragma mark main

static int compareAutocompleteData(id dict1, id dict2, void *context)
{
	NSString *name1 = [dict1 objectForKey:context];
	NSString *name2 = [dict2 objectForKey:context];
	return [name1 caseInsensitiveCompare:name2];
}

- (void)main;
{
	if(self.isCancelled)
		return;
	
	NSString *partialMail = [_autocompleteString lowercaseString];
	NSMutableArray *autocompleteData = [NSMutableArray array];
	
	if (partialMail) {
		for (id searchString in _addressbookData.allKeys) {
			if ([searchString rangeOfString:partialMail].location != NSNotFound) {
				[autocompleteData addObject:[_addressbookData objectForKey:searchString]];
			}
		}
	}
	
	if (!self.isCancelled) {
		[autocompleteData sortUsingFunction:compareAutocompleteData context:@"name"];
		[_target performSelectorOnMainThread:_selector withObject:autocompleteData waitUntilDone:NO];
	}
}


@end


#pragma mark -
#pragma mark SCFetchAddressbookOperation

@implementation SCFetchAddressbookOperation


#pragma mark Lifecycle

- (id)initWithTarget:(id)target selector:(SEL)selector;
{
	if ((self = [super init])) {
		_target = [target retain];
		_selector = selector;
	}
	return self;
}

- (void)dealloc;
{
	[_target release];
	[super dealloc];
}


#pragma mark main

- (void)main;
{
	if (self.isCancelled)
		return;
	
	[NSThread setThreadPriority:0.2];
	
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPersons = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
	
	for(CFIndex personIx = 0; personIx < personCount; personIx++) {
		
		if ([self isCancelled])
			break;
		
		ABRecordRef record = CFArrayGetValueAtIndex(allPersons, personIx);
		if (ABRecordGetRecordType(record) != kABPersonType)
			continue;
		NSString *compositeName = (NSString *)ABRecordCopyCompositeName(record);
		
		ABMultiValueRef emailValue = ABRecordCopyValue(record, kABPersonEmailProperty);
		CFIndex valueCount = ABMultiValueGetCount(emailValue);
		for (CFIndex valueIx = 0; valueIx < valueCount; valueIx++) {
			NSString *name = compositeName;
			NSString *email = (NSString *)ABMultiValueCopyValueAtIndex(emailValue, valueIx);
			NSString *label = (NSString *)ABMultiValueCopyLabelAtIndex(emailValue, valueIx);
			NSString *mailType = nil;
			if (email) {
				
				if (label) {
					mailType = (NSString *)ABAddressBookCopyLocalizedLabel((CFStringRef)label);
				} else {
					mailType = @"email";
				}
				
				if (!name) {
					name = email;
				}
				
				NSDictionary *personDict = [[NSDictionary alloc] initWithObjectsAndKeys:
											name, @"name",
											email, @"email",
											mailType, @"mailType",
											nil];
				
				[ret setObject:personDict forKey:[[NSString stringWithFormat:@"%@ %@", compositeName, email] lowercaseString]];
				[personDict release];
			}
			
			[label release];
			[email release];
			[mailType release];
		}
		CFRelease(emailValue);
		[compositeName release];
	}
	
	CFRelease(addressBook);
	CFRelease(allPersons);
	
	if (![self isCancelled]) {
		[_target performSelectorOnMainThread:_selector
								  withObject:ret
							   waitUntilDone:YES];
	}
}

@end
