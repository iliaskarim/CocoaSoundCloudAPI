//
//  SCRecordingSaveViewController.m
//  Soundcloud
//
//  Created by Gernot Poetsch on 25.10.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "QuartzCore+SoundCloudAPI.h"
#import "UIImage+SoundCloudAPI.h"
#import "SCSwitch.h"
#import "SCTableCellBackgroundView.h"

#import "JSONKit.h"

#import "SCSharingMailPickerController.h"
#import "SCFoursquarePlacePickerController.h"
#import "SCConstants.h"
#import "SCAddConnectionViewController.h"
#import "SCAccount.h"
#import "SCSoundCloud.h"
#import "SCRequest.h"
#import "SCLoginViewController.h"

#import "SCBundle.h"
#import "SCSCRecordingSaveViewControllerTitleView.h"
#import "SCRecordingSaveViewControllerHeaderView.h"
#import "SCRecordingUploadProgressView.h"
#import "SCLoginView.h"

#import "SCAppIsRunningOnIPad.h"

#import "UIColor+SoundCloudAPI.h"

#import "SCRecordingSaveViewController.h"


#define COVER_WIDTH 600.0


@interface SCRecordingSaveViewController ()

#pragma mark Accessors
@property (nonatomic, retain) NSArray *availableConnections;
@property (nonatomic, retain) NSArray *unconnectedServices;
@property (nonatomic, retain) NSArray *sharingConnections;
@property (nonatomic, retain) NSArray *sharingMailAddresses;

@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, retain) NSData *fileData;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, retain) UIImage *coverImage;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *trackCreationDate;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, copy) NSString *locationTitle;
@property (nonatomic, copy) NSString *foursquareID;

@property (nonatomic, readwrite, retain) SCAccount *account;

@property (nonatomic, retain) SCFoursquarePlacePickerController *foursquareController;

@property (nonatomic, assign) SCRecordingSaveViewControllerHeaderView *headerView;
@property (nonatomic, assign) SCRecordingUploadProgressView *uploadProgressView;
@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) UIToolbar *toolBar;
@property (nonatomic, assign) SCLoginView *loginView;

@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, copy) SCRecordingSaveViewControllerCompletionHandler completionHandler;

#pragma mark UI
- (void)updateInterface;

#pragma mark Actions
- (IBAction)shareConnectionSwitchToggled:(id)sender;
- (IBAction)openCameraPicker;
- (IBAction)openImageLibraryPicker;
- (IBAction)openPlacePicker;
- (IBAction)closePlacePicker;
- (IBAction)privacyChanged:(id)sender;
- (IBAction)selectImage;
- (IBAction)resetImage;
- (IBAction)upload;
- (IBAction)cancel;
- (IBAction)relogin;


#pragma mark Notification Handling
- (void)accountDidChange:(NSNotification *)aNotification;
- (void)didFailToRequestAccess:(NSNotification *)aNotification;


#pragma mark Tool Bar Animation
- (void)hideToolBar;
- (void)showToolBar;


#pragma mark Login View
- (void)showLoginView:(BOOL)animated;
- (void)hideLoginView:(BOOL)animated;


#pragma mark Helpers
- (NSString *)generatedTitle;
- (NSString *)generatedSharingNote;
- (NSString *)dateString;
- (float)cellMargin;
@end


NSString * const SCDefaultsKeyRecordingIsPrivate = @"SCRecordingIsPrivate";


@implementation SCRecordingSaveViewController


#pragma mark Class methods

const NSArray *allServices = nil;

+ (void)initialize;
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSNumber numberWithBool:NO], SCDefaultsKeyRecordingIsPrivate,
															 nil]];
    allServices = [[NSArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    SCLocalizedString(@"service_twitter", @"Twitter"), @"displayName",
                    @"twitter", @"service",
                    nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    SCLocalizedString(@"service_facebook", @"Facebook"), @"displayName",
                    @"facebook_profile", @"service",
                    nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    SCLocalizedString(@"service_tumblr", @"Tumblr"), @"displayName",
                    @"tumblr", @"service",
                    nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    SCLocalizedString(@"service_foursquare", @"Foursquare"), @"displayName",
                    @"foursquare", @"service",
                    nil],
                   nil];
}


@synthesize availableConnections;
@synthesize unconnectedServices;
@synthesize sharingConnections;
@synthesize sharingMailAddresses;
@synthesize fileURL;
@synthesize fileData;
@synthesize isPrivate;
@synthesize coverImage;
@synthesize title;
@synthesize trackCreationDate;
@synthesize location;
@synthesize locationTitle;
@synthesize foursquareID;
@synthesize account;
@synthesize foursquareController;
@synthesize headerView;
@synthesize uploadProgressView;
@synthesize completionHandler;
@synthesize tableView;
@synthesize toolBar;
@synthesize loginView;
@synthesize popoverController;


#pragma mark Lifecycle

- (id)init;
{
    self = [super init];
    if (self) {
        unconnectedServices = [[NSArray alloc] init];
        availableConnections = [[NSArray alloc] init];
        sharingConnections = [[NSArray alloc] init];
        sharingMailAddresses = [[NSArray alloc] init];
        
        isPrivate = [[NSUserDefaults standardUserDefaults] boolForKey:SCDefaultsKeyRecordingIsPrivate];
        location = nil;
        locationTitle = nil;
        foursquareID = nil;
        
        coverImage = nil;
        title = nil;
        
        trackCreationDate = [[NSDate date] retain];
        
        completionHandler = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountDidChange:)
                                                     name:SCSoundCloudAccountDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFailToRequestAccess:)
                                                     name:SCSoundCloudDidFailToRequestAccessNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [availableConnections release];
    [unconnectedServices release];
    [sharingConnections release];
    [sharingMailAddresses release];
    [account release];
    [coverImage release];
    [title release];
    [trackCreationDate release];
    [location release];
    [locationTitle release];
    [foursquareID release];
    [foursquareController release];
    [completionHandler release];
    [popoverController release];
    
    [super dealloc];
}


#pragma mark Accessors

- (void)setFileURL:(NSURL *)aFileURL;
{
    if (fileURL != aFileURL) {
        [fileURL release];
        [aFileURL retain];
        fileURL = aFileURL;
    }
}

- (void)setFileData:(NSData *)someFileData;
{
    if (fileData != someFileData) {
        [fileData release];
        [someFileData retain];
        fileData = someFileData;
    }
}

- (void)setAccount:(SCAccount *)anAccount;
{   
    if (account != anAccount) {
        [account release];
        [anAccount retain];
        account = anAccount;
 
        if (self.account) {
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/connections.json"]
                     usingParameters:nil
                         withAccount:self.account
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                         if (data) {
                             NSError *jsonError = nil;
                             NSArray *result = [data objectFromJSONData];
                             if (result) {
                                 [self setAvailableConnections:result];
                             } else {
                                 NSLog(@"%s json error: %@", __FUNCTION__, [jsonError localizedDescription]);
                             }
                         } else {
                             NSLog(@"%s error: %@", __FUNCTION__, [error localizedDescription]);
                         }
                     }];
            
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
                     usingParameters:nil
                         withAccount:self.account
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                         if (data) {
                             NSError *jsonError = nil;
                             id result = [data objectFromJSONData];
                             if (result) {
                                 
                                 NSURL *avatarURL = [NSURL URLWithString:[result objectForKey:@"avatar_url"]];
                                 NSData *avatarData = [NSData dataWithContentsOfURL:avatarURL];
                                 [self.headerView setAvatarImage:[UIImage imageWithData:avatarData]];
                                 [self.headerView setUserName:[result objectForKey:@"username"]];
                                 
                             } else {
                                 NSLog(@"%s json error: %@", __FUNCTION__, [jsonError localizedDescription]);
                             }
                         } else {
                             NSLog(@"%s error: %@", __FUNCTION__, [error localizedDescription]);
                         }
                     }];
        }
    }
}

- (void)setPrivate:(BOOL)p;
{
    isPrivate = p;
}

- (void)setCoverImage:(UIImage *)aCoverImage;
{
    if (coverImage != aCoverImage) {
        [coverImage release];
        [aCoverImage retain];
        coverImage = aCoverImage;
        [self.headerView setCoverImage:aCoverImage];
    }
}

- (void)setTitle:(NSString *)aTitle;
{
    if (title != aTitle) {
        [title release];
        [aTitle retain];
        title = aTitle;
    }
}

- (void)setCreationDate:(NSDate *)aCreationDate;
{
    self.trackCreationDate = aCreationDate;
}

- (void)setAvailableConnections:(NSArray *)value;
{
    [value retain]; [availableConnections release]; availableConnections = value;
    
    NSMutableArray *newUnconnectedServices = [allServices mutableCopy];
    
    //Set the unconnected Services
    for (NSDictionary *connection in availableConnections) {
        NSDictionary *connectedService = nil;
        for (NSDictionary *unconnectedService in newUnconnectedServices) {
            if ([[connection objectForKey:@"service"] isEqualToString:[unconnectedService objectForKey:@"service"]]) {
                connectedService = unconnectedService;
            }
        }
        if (connectedService) [newUnconnectedServices removeObject:connectedService];
    }
    
    self.unconnectedServices = newUnconnectedServices;
    [newUnconnectedServices release];
    [self.tableView reloadData];
}


#pragma mark Foursquare

- (void)setFoursquareClientID:(NSString *)aClientID clientSecret:(NSString *)aClientSecret;
{
    self.foursquareController = [[[SCFoursquarePlacePickerController alloc] initWithDelegate:self
                                                                                    clientID:aClientID
                                                                                clientSecret:aClientSecret] autorelease];
    
    if (self.foursquareController) {
        self.headerView.disclosureButton.hidden = NO;
        [self.headerView.disclosureButton addTarget:self
                                             action:@selector(openPlacePicker)
                                   forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.headerView.disclosureButton.hidden = YES;
        [self.headerView.disclosureButton removeTarget:self
                                                action:@selector(openPlacePicker)
                                      forControlEvents:UIControlEventTouchUpInside];
    }
}


#pragma mark ViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
        
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);

    
    // Background
    UIImage *bg = [SCBundle imageFromPNGWithName:@"darkTexturedBackgroundPattern"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    
    // Navigation Bar
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    
    // Toolbar
    self.toolBar = [[[UIToolbar alloc] init] autorelease];
    self.toolBar.barStyle = UIBarStyleBlack;
    self.toolBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleTopMargin);
    [self.view addSubview:self.toolBar];
    
    
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:3];
    
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"cancel", @"Cancel")
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(cancel)] autorelease]];
    
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"upload_and_share", @"Upload & Share")
                                                            style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(upload)] autorelease]];
    
    [self.toolBar setItems:toolbarItems];
    
    
    // Table View
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                                                   style:UITableViewStyleGrouped] autorelease];
    
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                       UIViewAutoresizingFlexibleWidth);
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view insertSubview:self.tableView belowSubview:self.toolBar];
    
    
    // Header
    self.headerView = [[[SCRecordingSaveViewControllerHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 0)] autorelease];
    
    self.headerView.whatTextField.delegate = self;
    self.headerView.whereTextField.delegate = self;
    
    [self.headerView.coverImageButton addTarget:self
                                         action:@selector(selectImage)
                               forControlEvents:UIControlEventTouchUpInside];
    
    [self.headerView.privateSwitch addTarget:self
                                      action:@selector(privacyChanged:)
                            forControlEvents:UIControlEventValueChanged];
    
    if (self.foursquareController) {
        self.headerView.disclosureButton.hidden = NO;
        [self.headerView.disclosureButton addTarget:self
                                             action:@selector(openPlacePicker)
                                   forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.headerView.disclosureButton.hidden = YES;
        [self.headerView.disclosureButton removeTarget:self
                                                action:@selector(openPlacePicker)
                                      forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.headerView.logoutButton addTarget:self
                                     action:@selector(relogin)
                           forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableHeaderView = self.headerView;

    
    [self updateInterface];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [self.view addSubview:[[[SCSCRecordingSaveViewControllerTitleView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 28.0)] autorelease]];
    
    [self.toolBar sizeToFit];
    [self.toolBar setFrame:CGRectMake(0.0,
                                      self.view.frame.size.height - self.toolBar.frame.size.height, 
                                      self.toolBar.frame.size.width,
                                      self.toolBar.frame.size.height)];
    
    CGRect tableViewFrame = self.view.bounds;
    tableViewFrame.origin.y += 28.0;        // Banner
    tableViewFrame.size.height -= 28.0;     // Banner
    tableViewFrame.size.height -= CGRectGetHeight(self.toolBar.frame); // Toolbar
    
    self.tableView.frame = tableViewFrame;
    
    self.account = [SCSoundCloud account];
    
    [tableView reloadData];
    [self updateInterface];
    
    if (!self.account) {
        [self showLoginView:NO];
        [self relogin];
    }
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    if (!self.account) {
        [self relogin];
    }
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    self.title = self.headerView.whatTextField.text;
    self.locationTitle = self.headerView.whereTextField.text;
}

- (void)updateInterface;
{
    self.headerView.whatTextField.text = self.title;
    self.headerView.whereTextField.text = self.locationTitle;
    self.headerView.privateSwitch.on = !isPrivate;
    [self.headerView setCoverImage:self.coverImage];
}


#pragma mark TableView

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
    if (isPrivate){
        return 1;
    } else {
        return self.availableConnections.count + self.unconnectedServices.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (isPrivate) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"mailShare"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mailShare"] autorelease];
            SCTableCellBackgroundView *backgroundView = [[[SCTableCellBackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), 44.0)] autorelease];
            backgroundView.opaque = NO;
            backgroundView.backgroundColor = [UIColor transparentBlack];
            backgroundView.borderColor = [UIColor blackColor];
            cell.backgroundView = backgroundView;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = [UIColor listSubtitleColor];
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
                
        cell.textLabel.text = SCLocalizedString(@"sc_upload_with_access", @"With access");
        if (self.sharingMailAddresses.count == 0) {
            cell.detailTextLabel.text = SCLocalizedString(@"sc_upload_only_you", @"Only you");
        } else {
            cell.detailTextLabel.text = [self.sharingMailAddresses componentsJoinedByString:@", "];
        }

        [(SCTableCellBackgroundView *)cell.backgroundView setPosition:[aTableView cellPositionForIndexPath:indexPath]];
        
        return cell;
        
    } else {
        
        if (indexPath.row < self.availableConnections.count) {
            UITableViewCell *cell = nil;  // WORKAROUND: Reusing cells causes a problem with the boarder
                                          //[aTableView dequeueReusableCellWithIdentifier:@"connection"];
            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"connection"] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.opaque = NO;
                SCTableCellBackgroundView *backgroundView = [[[SCTableCellBackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), 44.0)] autorelease];
                backgroundView.opaque = NO;
                backgroundView.backgroundColor = [UIColor transparentBlack];
                backgroundView.borderColor = [UIColor blackColor];
                cell.backgroundView = backgroundView;
                cell.textLabel.backgroundColor = [UIColor clearColor];
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
            
            
            NSDictionary *connection = [self.availableConnections objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [connection objectForKey:@"display_name"];
            
            SCSwitch *accessorySwitch = [[[SCSwitch alloc] init] autorelease];
            accessorySwitch.offBackgroundImage = [[SCBundle imageFromPNGWithName:@"switch_gray"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            
            accessorySwitch.on = NO;
            [self.sharingConnections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                if ([[obj objectForKey:@"id"] isEqual:[connection objectForKey:@"id"]]) {
                    if (self.foursquareID || ![[connection objectForKey:@"service"] isEqualToString:@"foursquare"]) {
                        accessorySwitch.on = YES;
                    }
                    *stop = YES;
                }
            }];
            
            [accessorySwitch addTarget:self action:@selector(shareConnectionSwitchToggled:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = accessorySwitch;
            
            cell.imageView.image = [SCBundle imageFromPNGWithName:[NSString stringWithFormat:@"service_%@", [connection objectForKey:@"service"]]];
            
            [(SCTableCellBackgroundView *)cell.backgroundView setPosition:[aTableView cellPositionForIndexPath:indexPath]];
            
            return cell;
        } else {
            UITableViewCell *cell = nil; // WORKAROUND: Reusing cells causes a problem with the boarder
                                         // [aTableView dequeueReusableCellWithIdentifier:@"newConnection"];
            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"newConnection"] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                SCTableCellBackgroundView *backgroundView = [[[SCTableCellBackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), 44.0)] autorelease];
                backgroundView.opaque = NO;
                backgroundView.backgroundColor = [UIColor transparentBlack];
                backgroundView.borderColor = [UIColor blackColor];
                cell.backgroundView = backgroundView;
                cell.textLabel.backgroundColor = [UIColor clearColor];
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[SCBundle imageFromPNGWithName:@"DisclosureIndicator"]];
                cell.detailTextLabel.text = SCLocalizedString(@"configure", @"Configure");
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *service = [self.unconnectedServices objectAtIndex:indexPath.row - self.availableConnections.count];
            cell.textLabel.text = [service objectForKey:@"displayName"];
            cell.imageView.image = [SCBundle imageFromPNGWithName:[NSString stringWithFormat:@"service_%@", [service objectForKey:@"service"]]];
            
            [(SCTableCellBackgroundView *)cell.backgroundView setPosition:[aTableView cellPositionForIndexPath:indexPath]];
            return cell;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (self.isPrivate) {
        // TODO: Insert correct text describing the private options
        return SCLocalizedString(@"sc_upload_sharing_options_private", @"Your track will be private after the upload. You want to share it with others?");
    } else {
        return SCLocalizedString(@"sc_upload_sharing_options_public", @"Your track will be available for the public after the upload. You want to push it to other services afterwards?");
    }
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section;
{
    NSString *text = [self tableView:aTableView titleForHeaderInSection:section];
    
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:15.0]
                       constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.bounds) - 2 * [self cellMargin], CGFLOAT_MAX)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    UIView *sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds) - 2 * [self cellMargin], textSize.height + 2 * 10.0)] autorelease];
    sectionHeaderView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(sectionHeaderView.bounds, [self cellMargin], 0.0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor listSubtitleColor];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = text;
    [sectionHeaderView addSubview:label];
    [label release];
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section;
{
    NSString *text = [self tableView:aTableView titleForHeaderInSection:section];
    
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:15.0]
                       constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.bounds) - 2 * [self cellMargin], CGFLOAT_MAX)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    return textSize.height + 2 * 10.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
    if (isPrivate) {
        return nil;
    } else {
        if (availableConnections.count == 0) {
            return nil; // @"To add sharing options, go to your settings on SoundCloud.com and select 'Connections'";
        } else {
            return SCLocalizedString(@"connection_list_footer", @"To change your default sharing options, go to your settings on SoundCloud and select 'Connections'");
        }
    }
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section;
{
    if (isPrivate) {
        return nil;
    } else {
        UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), 20.0)] autorelease];
        footerView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(footerView.bounds, [self cellMargin], 0.0)];
        label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor listSubtitleColor];
        label.font = [UIFont systemFontOfSize:13.0];
        label.text = [self tableView:aTableView titleForFooterInSection:section];
        label.numberOfLines = 2;
        [footerView addSubview:label];
        [label release];
        return footerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 48.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (isPrivate) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            SCSharingMailPickerController  *controller = [[SCSharingMailPickerController alloc] initWithDelegate:self];
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
			navController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
			controller.title = SCLocalizedString(@"sc_upload_with_access", @"With Access");
			controller.result = self.sharingMailAddresses;
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:navController animated:YES];
			[controller release];
			[navController release];
            
            [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else {
        if (indexPath.row >= availableConnections.count) {
            NSDictionary *service = [unconnectedServices objectAtIndex:indexPath.row - availableConnections.count];
            SCAddConnectionViewController *controller = [[SCAddConnectionViewController alloc] initWithService:[service objectForKey:@"service"] account:account delegate:self];
            controller.title = [NSString stringWithFormat:SCLocalizedString(@"sc_upload_connect_to", @"Connect %@"), [service objectForKey:@"displayName"]];
            
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}


#pragma mark SCSharingMailPickerControllerDelegate

- (void)sharingMailPickerController:(SCSharingMailPickerController *)controller didFinishWithResult:(NSArray *)emailAdresses;
{
    self.sharingMailAddresses = emailAdresses;
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sharingMailPickerControllerDidCancel:(SCSharingMailPickerController *)controller;
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.headerView.whatTextField) {
        self.title = text;
    } else if (textField == self.headerView.whereTextField) {
        self.locationTitle = text;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    if (textField == self.headerView.whatTextField) {
        self.title = textField.text;
    } else if (textField == self.headerView.whereTextField) {
        self.locationTitle = textField.text;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    if (self.foursquareController && textField == self.headerView.whereTextField) {
        [self.headerView.whatTextField resignFirstResponder]; //So we don't get the keyboard when coming back
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
    
    [self updateInterface];
}


#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
{
    UIImage *actualImage = image;
    if (!CGSizeEqualToSize(actualImage.size, CGSizeMake(COVER_WIDTH, COVER_WIDTH))) {
        actualImage = [actualImage imageByResizingTo:CGSizeMake(COVER_WIDTH, COVER_WIDTH)];
    }
    
    self.coverImage = actualImage;
    
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark Place Picker Delegate

- (void)foursquarePlacePicker:(SCFoursquarePlacePickerController *)aPicker
           didFinishWithTitle:(NSString *)aTitle
                 foursquareID:(NSString *)aFoursquareID
                     location:(CLLocation *)aLocation;
{
    self.headerView.whereTextField.text = aTitle;
    self.locationTitle = aTitle;
    self.location = aLocation;
    self.foursquareID = aFoursquareID;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark Add Connection Delegate

- (void)addConnectionController:(SCAddConnectionViewController *)controller didFinishWithService:(NSString *)service success:(BOOL)success;
{
    if (success) {
        
        // Update the sharing connections of this user and set the new connection to "on".
        // Dismiss the connection view controller after the connections where updated.
        
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/connections.json"]
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                     if (data) {
                         NSError *jsonError = nil;
                         NSArray *result = [data objectFromJSONData];
                         if (result) {
                             [self setAvailableConnections:result];
                         } else {
                             NSLog(@"%s json error: %@", __FUNCTION__, [jsonError localizedDescription]);
                         }
                     } else {
                         NSLog(@"%s error: %@", __FUNCTION__, [error localizedDescription]);
                     }
                     
                     NSIndexSet *idxs = [availableConnections indexesOfObjectsPassingTest:^(id obj, NSUInteger i, BOOL *stop){
                         if ([[obj objectForKey:@"service"] isEqual:service]) {
                             *stop = YES;
                             return YES;
                         } else {
                             return NO;
                         }
                     }];
                     
                     NSMutableArray *newSharingConnections = [self.sharingConnections mutableCopy];
                     [newSharingConnections addObject:[availableConnections objectAtIndex:[idxs firstIndex]]];
                     self.sharingConnections = newSharingConnections;
                     
                     if (self.navigationController.topViewController == controller) {
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                 }];
    }
}


#pragma mark Actions

- (IBAction)shareConnectionSwitchToggled:(SCSwitch *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[(UIView *)sender superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    NSDictionary *connection = [availableConnections objectAtIndex:indexPath.row];
    
    //If this is a foursquare switch, we don't have a venue and want to switch it on, display place picker
    if ([[connection objectForKey:@"service"] isEqualToString:@"foursquare"] && !self.foursquareID && [sender isOn]) {
        [self openPlacePicker];
    }
    
    NSMutableArray *newSharingConnections = [self.sharingConnections mutableCopy];
    if ([sender isOn]) {
        [newSharingConnections addObject:connection];
    } else {
        NSIndexSet *idxs = [newSharingConnections indexesOfObjectsPassingTest:^(id obj, NSUInteger i, BOOL *stop){
            if ([[obj objectForKey:@"id"] isEqual:[connection objectForKey:@"id"]]) {
                *stop = YES;
                return YES;
            } else {
                return NO;
            }
        }];
        [newSharingConnections removeObjectsAtIndexes:idxs];
    }
    
    self.sharingConnections = newSharingConnections;
    [newSharingConnections release];
}

- (IBAction)privacyChanged:(id)sender;
{
    if (sender == self.headerView.privateSwitch) {
		isPrivate = !self.headerView.privateSwitch.on;
        [[NSUserDefaults standardUserDefaults] setBool:!self.headerView.privateSwitch.on forKey:SCDefaultsKeyRecordingIsPrivate];
        [self.tableView reloadData];
    }
}

- (IBAction)selectImage;
{
    if (SCAppIsRunningOnIPad() && [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary].count > 0) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
        [self.popoverController presentPopoverFromRect:self.headerView.coverImageButton.frame
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
        
        if (self.coverImage) {
            UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"artwork_reset", @"Reset")
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(resetImage)];
            picker.navigationBar.topItem.leftBarButtonItem = resetButton;
            [resetButton release];
        }
        
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera].count > 0) {
            UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(openCameraPicker)];
            picker.navigationBar.topItem.rightBarButtonItem = cameraButton;
            [cameraButton release];
        }
        
        [picker release];
        
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:SCLocalizedString(@"recording_image", @"Cover Image")
                                                           delegate:self
                                                  cancelButtonTitle:SCLocalizedString(@"cancel", @"Cancel")
                                             destructiveButtonTitle:self.coverImage ? SCLocalizedString(@"artwork_reset", @"Reset") : nil
                                                  otherButtonTitles:
                                ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary].count > 0) ? SCLocalizedString(@"use_existing_image", @"Photo Library") : nil,
                                ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera].count > 0) ? SCLocalizedString(@"take_new_picture", @"Camera") : nil,
                                nil];
        [sheet showInView:self.view];
        [sheet release];
    }
}

- (IBAction)openCameraPicker;
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
    
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
    if (self.foursquareController) {
        [self.navigationController pushViewController:self.foursquareController animated:YES];
    }
}

- (IBAction)closePlacePicker;
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)resetImage;
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
    self.coverImage = nil;
}

- (IBAction)upload;
{    
    [self hideToolBar];
    
    // setup progress view
    self.tableView.hidden = YES;
    [self.navigationController setToolbarHidden:YES animated:YES];

    if (self.uploadProgressView) {
        [self.uploadProgressView removeFromSuperview];
    }
    
    self.uploadProgressView = [[SCRecordingUploadProgressView alloc] initWithFrame:CGRectMake(26, 58, CGRectGetWidth(self.view.bounds) - 52, CGRectGetHeight(self.view.bounds) - 26 - 58)];
    [self.view insertSubview:self.uploadProgressView belowSubview:self.toolBar];
    
    [self.uploadProgressView setTitle:[self generatedTitle]];
    [self.uploadProgressView setCoverImage:self.coverImage];
    
    [self.uploadProgressView.cancelButton addTarget:self
                                             action:@selector(cancel)
                                   forControlEvents:UIControlEventTouchUpInside];
    
    
    // set up request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // track
    if (self.fileURL) {
        [parameters setObject:self.fileURL forKey:@"track[asset_data]"];
    } else {
        [parameters setObject:self.fileData forKey:@"track[asset_data]"];
    }
    
    // metadata
    [parameters setObject:[self generatedTitle] forKey:@"track[title]"];
    [parameters setObject:(self.isPrivate) ? @"private" : @"public" forKey: @"track[sharing]"];
    [parameters setObject:[self generatedSharingNote] forKey:@"track[sharing_note]"];
	[parameters setObject:@"recording" forKey:@"track[track_type]"];
	[parameters setObject:@"1" forKey:@"track[downloadable]"];

    // sharing
    if (self.isPrivate) {
        if (self.sharingMailAddresses.count > 0) {
            [parameters setObject:self.sharingMailAddresses forKey:@"track[shared_to][emails][][address]"];
        }
    } else {
        if (self.sharingConnections.count > 0) {
            NSMutableArray *idArray = [NSMutableArray arrayWithCapacity:self.sharingConnections.count];
            for (NSDictionary *sharingConnection in sharingConnections) {
                if ([[sharingConnection objectForKey:@"service"] isEqualToString:@"foursquare"] && !self.foursquareID) {
                    //Ignore Foursquare sharing when there is no venue ID set.
                } else {
                    [idArray addObject:[NSString stringWithFormat:@"%@", [sharingConnection objectForKey:@"id"]]];
                }
            }
            [parameters setObject:idArray forKey:@"track[post_to][][id]"];
        } else {
            [parameters setObject:@"" forKey:@"track[post_to][]"];
        }
    }
    
    // artwork
    if (self.coverImage) {
        NSData *coverData = UIImageJPEGRepresentation(self.coverImage, 0.8);
        [parameters setObject:coverData forKey:@"track[artwork_data]"];
    }
    
    // tags (location)
    NSMutableArray *tags = [NSMutableArray array];
    [tags addObject:@"soundcloud:source=iphone-record"];
    if (self.location) {
        [tags addObject:[NSString stringWithFormat:@"geo:lat=%f", self.location.coordinate.latitude]];
        [tags addObject:[NSString stringWithFormat:@"geo:lon=%f", self.location.coordinate.longitude]];
    }
    if (self.foursquareID) {
        [tags addObject:[NSString stringWithFormat:@"foursquare:venue=%@", self.foursquareID]];
    }
    [parameters setObject:[tags componentsJoinedByString:@" "] forKey:@"track[tag_list]"];
    
    
    // perform request
    [SCRequest performMethod:SCRequestMethodPOST
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks.json"]
             usingParameters:parameters
                 withAccount:self.account
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal){self.uploadProgressView.progressView.progress = (float)bytesSend / bytesTotal;}
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 if (data) {
                     NSError *jsonError = nil;
                     id result = [data objectFromJSONData]; //[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                     if (result) {
                         
                         [self.uploadProgressView setSuccess:YES];
                         
                         double delayInSeconds = 1.0;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             self.completionHandler(NO, result);
                             [self.parentViewController dismissModalViewControllerAnimated:YES];
                         });
                     } else {
                         NSLog(@"Upload failed with json error: %@", [jsonError localizedDescription]);
                         
                         [self.uploadProgressView setSuccess:NO];
                         UIBarButtonItem *button = [self.toolBar.items lastObject];
                         [self showToolBar];
                         button.title = SCLocalizedString(@"retry_upload", @"Retry upload");
                     }
                 } else {
                     NSLog(@"Upload failed with error: %@", [error localizedDescription]);
                     
                     [self.uploadProgressView setSuccess:NO];
                     UIBarButtonItem *button = [self.toolBar.items lastObject];
                     [self showToolBar];
                     button.title = SCLocalizedString(@"retry_upload", @"Retry upload");
                 }
             }];
}

- (IBAction)cancel;
{
    self.completionHandler(YES, nil);
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)relogin;
{
    [SCSoundCloud removeAccess];
    self.account = nil;
    [self showLoginView:YES];
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        [self.loginView loadURL:preparedURL];
    }];
}


#pragma mark Notification Handling

- (void)accountDidChange:(NSNotification *)aNotification;
{
    self.account = [SCSoundCloud account];
    if (self.account){
        [self hideLoginView:YES];
    }
}

- (void)didFailToRequestAccess:(NSNotification *)aNotification;
{
    [self cancel];
}



#pragma mark Tool Bar Animation
- (void)hideToolBar;
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         CGPoint center = self.toolBar.center;
                         self.toolBar.center = CGPointMake(center.x, center.y + CGRectGetHeight(self.toolBar.frame));
                     }];
}

- (void)showToolBar;
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         CGPoint center = self.toolBar.center;
                         self.toolBar.center = CGPointMake(center.x, center.y - CGRectGetHeight(self.toolBar.frame));
                     }];
}


#pragma mark Login View

- (void)showLoginView:(BOOL)animated;
{
    if (self.loginView)
        return;
    
    CGRect loginViewFrame = CGRectMake(0,
                                       28.0,
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) - 28.0 - CGRectGetHeight(self.toolBar.frame));
    
    self.loginView = [[[SCLoginView alloc] initWithFrame:loginViewFrame] autorelease];
    self.loginView.delegate = self;
    [self.view insertSubview:self.loginView belowSubview:self.toolBar];
    
    
    NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:self.toolBar.items];
    [toolBarItems removeLastObject];
    [self.toolBar setItems:toolBarItems animated:animated];
    
    if (animated) {
        self.loginView.center = CGPointMake(self.loginView.center.x, self.loginView.center.y + CGRectGetHeight(self.loginView.frame));
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.loginView.center = self.tableView.center;
                         }];
    }
}

- (void)hideLoginView:(BOOL)animated;
{
    if (!self.loginView)
        return;
    
    NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:self.toolBar.items];
    [toolBarItems addObject:[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"upload_and_share", @"Upload & Share")
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(upload)] autorelease]];
    [self.toolBar setItems:toolBarItems animated:animated];
    
    if (!animated) {
        [self.loginView removeFromSuperview];
        self.loginView = nil;
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.loginView.center = CGPointMake(self.loginView.center.x, self.loginView.center.y + CGRectGetHeight(self.loginView.frame));
                         }
                         completion:^(BOOL finished){
                             [self.loginView removeFromSuperview];
                             self.loginView = nil;
                         }];
    }
}

- (void)loginView:(SCLoginView *)aLoginView didFailWithError:(NSError *)anError;
{
    NSLog(@"Login did fail with error: %@", anError);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[anError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert autorelease];
    [self cancel];
}

#pragma mark Helpers


- (NSString *)generatedTitle;
{
    if (self.title.length > 0) {
        if (self.locationTitle.length > 0) {
            return [NSString stringWithFormat:SCLocalizedString(@"recording_title_at_location_name", @"%@ at %@"), self.title, self.locationTitle];
        } else {
            return self.title;
        }
    } else {
        if (self.locationTitle.length > 0) {
            return [NSString stringWithFormat:SCLocalizedString(@"recording_at_location", @"Sounds at %@"), self.locationTitle];
        } else {
            return [NSString stringWithFormat:SCLocalizedString(@"recording_from_data", @"Sounds from %@"), [self dateString]];
        }
    }
}

- (NSString *)generatedSharingNote;
{
    NSString *note = nil;
    
    if (self.title.length > 0) {
        if (self.locationTitle.length > 0) {
            note = [NSString stringWithFormat:SCLocalizedString(@"recording_title_at_location_name", @"%@ at %@"), self.title, self.locationTitle];
        } else {
            note = self.title;
        }
    } else {
        if (self.locationTitle.length > 0) {
            note = [NSString stringWithFormat:SCLocalizedString(@"recording_at_location", @"Sounds at %@"), self.locationTitle];
        } else {
            note = [NSString stringWithFormat:SCLocalizedString(@"recording_from_data", @"Sounds from %@"), [self dateString]];
        }
    }
    
    return note;
}

- (NSString *)dateString;
{
    NSString *weekday = nil;
    NSString *time = nil;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSWeekdayCalendarUnit | NSHourCalendarUnit) fromDate:self.trackCreationDate];
    [gregorian release];
    
    switch ([components weekday]) {
        case 1:
            weekday = SCLocalizedString(@"recording_weekday_sunday", @"Sunday");
            break;
        case 2:
            weekday = SCLocalizedString(@"recording_weekday_monday", @"Monday");
            break;
        case 3:
            weekday = SCLocalizedString(@"weekday_tuesday", @"Tuesday");
            break;
        case 4:
            weekday = SCLocalizedString(@"weekday_wednesday", @"Wednesday");
            break;
        case 5:
            weekday = SCLocalizedString(@"weekday_thursday", @"Thursday");
            break;
        case 6:
            weekday = SCLocalizedString(@"weekday_friday", @"Friday");
            break;
        case 7:
            weekday = SCLocalizedString(@"weekday_saturday", @"Saturday");
            break;
    }
    
    if ([components hour] <= 12) {
        time = SCLocalizedString(@"timeframe_morning", @"morning");
    } else if ([components hour] <= 17) {
        time = SCLocalizedString(@"timeframe_afternoon", @"afternoon");
    } else if ([components hour] <= 21) {
        time = SCLocalizedString(@"timeframe_evening", @"evening");
    } else {
        time = SCLocalizedString(@"timeframe_night", @"night");
    }
    
    return [NSString stringWithFormat:@"%@ %@", weekday, time];
}

- (float)cellMargin;
{
    if (SCAppIsRunningOnIPad()) {
        return 30.0;
    } else {
        return 9.0;
    }
}

@end

