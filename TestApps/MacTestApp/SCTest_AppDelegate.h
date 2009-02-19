/*
 * Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
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
