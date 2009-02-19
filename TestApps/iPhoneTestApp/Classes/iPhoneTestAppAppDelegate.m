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

#import "iPhoneTestAppAppDelegate.h"
#import "iPhoneTestAppViewController.h"

@implementation iPhoneTestAppAppDelegate

#pragma mark Lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application;
{
	// global accessible api configuration through application delegate
	// set appDelegate as auth delegate on every api instantiation
	// make shure to register the myapp url scheme to your app :)
	scAPIConfig = [[SCSoundCloudAPIConfiguration alloc] initForSandboxWithConsumerKey:kTestAppConsumerKey
																	   consumerSecret:kTestAppConsumerSecret
																		  callbackURL:[NSURL URLWithString:kCallbackURL]];
	[window addSubview:viewController.view];
    [window makeKeyAndVisible];

}

- (void)dealloc;
{
    [viewController release];
    [window release];
	[scAPIConfig release];
	[authURL release];
	[safariAlertView release];
    [super dealloc];
}

#pragma mark Accessors

@synthesize window;
@synthesize viewController;
@synthesize scAPIConfig;

#pragma mark -

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
    if (!url) { return NO; }
	SCSoundCloudAPI *scAPI = [[SCSoundCloudAPI alloc] initWithAuthenticationDelegate:self];
	
	if([[url absoluteString] hasPrefix:kCallbackURL]) {
		NSLog(@"handling oauth callback");
		[scAPI authorizeRequestToken]; 
	}
	[scAPI release];
	return YES;
}

#pragma mark SoundCloudAPI Authorization Delegate

- (SCSoundCloudAPIConfiguration *)configurationForSoundCloudAPI:(SCSoundCloudAPI *)scAPI;
{
	return scAPIConfig;
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI requestedAuthenticationWithURL:(NSURL *)inAuthURL;
{
	authURL = [inAuthURL retain];
	safariAlertView = [[UIAlertView alloc] initWithTitle:@"OAuth Authentication"
												 message:@"The application will launch the SoundCloud website in Safari to allow you to authorize it."
												delegate:self
									   cancelButtonTitle:@"Launch Safari"
									   otherButtonTitles:nil];
	[safariAlertView show];
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)_scAPI didChangeAuthenticationStatus:(SCAuthenticationStatus)status;
{
	switch (status) {
		case SCAuthenticationStatusAuthenticated:
			// authenticated
			viewController.postButton.enabled = YES;
			// not the most elegant way to enable/disable the ui
			// but this is up to you (the developer of apps) to prove your cocoa skills :)
			viewController.trackNameField.enabled = YES;
			break;
		case SCAuthenticationStatusNotAuthenticated:
			viewController.postButton.enabled = NO;
			viewController.trackNameField.enabled = NO;
			[_scAPI requestAuthentication];
			break;
		case SCAuthenticationStatusGettingToken:
			viewController.postButton.enabled = NO;
			viewController.trackNameField.enabled = NO;
			// should not send requests to the api while it is in this state.
			break;
		case SCAuthenticationStatusWillAuthorizeRequestToken:
			viewController.postButton.enabled = NO;
			viewController.trackNameField.enabled = NO;
			[_scAPI authorizeRequestToken];
			break;
		default:
			break;
	}
}

#pragma mark -

- (void)modalViewCancel:(UIAlertView *)alertView
{
    [alertView release];
}

- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != -1 && authURL) {
       	[[UIApplication sharedApplication] openURL:authURL];
    }
    [alertView release];
}


@end