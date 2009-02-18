/*
 Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
 All rights reserved.
 
 This file is part of SoundCloudAPI.
 
 SoundCloudAPI is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published
 by the Free Software Foundation, version 3.
 
 SoundCloudAPI is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with SoundCloudAPI. If not, see <http://www.gnu.org/licenses/>.
 
 For more information and documentation refer to <http://soundcloud.com/api>.
 */

#import <Cocoa/Cocoa.h>

#import <SoundCloudAPI/SCAPI.h>

// for production
#define kTestAppConsumerKey		@"INHqfaDE8vt4Xr1mRzOmQ"
#define kTestAppConsumerSecret	@"MSAO1CJTAMkF2UkfhqKfTIAA0KFyiHFgQpELe5CTs"

// for sandbox
//#define kTestAppConsumerKey		@"gAnpKglV95xfMtb64zYAsg"
//#define kTestAppConsumerSecret	@"cshaWBLTZR2a1PQK3qVwuq4IpjNZcrJN1NhSY8b4vIk"

#define kCallbackURL	@"myapp://oauth"	//remember that the myapp protocol also is set in the info.plist

@class SCParameterTableDataSource;

@interface SCTest_AppDelegate : NSObject <SCSoundCloudAPIAuthenticationDelegate, SCSoundCloudAPIDelegate> {
	SCSoundCloudAPI *scAPI; // create one for each delegate you want. init with singleton config instance
	SCParameterTableDataSource *parametersDataSource;
	SCSoundCloudAPIConfiguration *scAPIConfig;
	
	// Outlets
    IBOutlet NSProgressIndicator *fetchProgressIndicator;
    IBOutlet NSComboBox *httpMethodCombo;
    IBOutlet NSButton *newParameterAddButton;
    IBOutlet NSTextField *newParameterKeyField;
    IBOutlet NSButton *newParameterRemoveButton;
    IBOutlet NSTextField *newParameterValueField;
    IBOutlet NSTableView *parametersTableView;
    IBOutlet NSTextField *resourceField;
    IBOutlet NSTextView *responseField;
    IBOutlet NSButton *sendRequestButton;
	IBOutlet NSButton *postTestButton;
	IBOutlet NSProgressIndicator *postProgress;
}


#pragma mark Actions
- (IBAction)addParameter:(id)sender;
- (IBAction)removeParameter:(id)sender;
- (IBAction)sendRequest:(id)sender;
- (IBAction)deleteAllMyTracks:(id)sender;

- (IBAction)postTest:(id)sender;
@end
