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

#import "SCAPI.h"

//Production
//#define kTestAppConsumerKey		@"INHqfaDE8vt4Xr1mRzOmQ"
//#define kTestAppConsumerSecret	@"MSAO1CJTAMkF2UkfhqKfTIAA0KFyiHFgQpELe5CTs"

//Sandbox
#define kTestAppConsumerKey		@"gAnpKglV95xfMtb64zYAsg"
#define kTestAppConsumerSecret	@"cshaWBLTZR2a1PQK3qVwuq4IpjNZcrJN1NhSY8b4vIk"

#define kCallbackURL	@"myapp://oauth"	//remember that the myapp protocol also is set in the info.plist

@class iPhoneTestAppViewController;

@interface iPhoneTestAppAppDelegate : NSObject <UIApplicationDelegate, SCSoundCloudAPIAuthenticationDelegate> {
    UIWindow *window;
    iPhoneTestAppViewController *viewController;
	SCSoundCloudAPIConfiguration *scAPIConfig;
	
	UIAlertView *safariAlertView;
	NSURL *authURL;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPhoneTestAppViewController *viewController;

@property (nonatomic, readonly) SCSoundCloudAPIConfiguration *scAPIConfig;

@end

