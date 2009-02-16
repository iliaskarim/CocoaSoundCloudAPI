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

