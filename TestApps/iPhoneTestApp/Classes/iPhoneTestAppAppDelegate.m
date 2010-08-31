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
 *
 *  DISCLAIMER:
 *    This is just sample code. Please make sure to understand the concepts described
 *    in the documentation of the api wrapper.
 *    The implementation of this class is just for illustration.
 * 
 */

#import "iPhoneTestAppAppDelegate.h"
#import "iPhoneTestAppViewController.h"


@implementation iPhoneTestAppAppDelegate

#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
	// global accessible api configuration through application delegate
	// set appDelegate as auth delegate on every api instantiation
	// make shure to register the myapp url scheme to your app :)
#ifdef kUseProduction
	scAPIConfig = [[SCSoundCloudAPIConfiguration alloc] initForProductionWithConsumerKey:kTestAppConsumerKey
																		  consumerSecret:kTestAppConsumerSecret
																			 callbackURL:[NSURL URLWithString:kCallbackURL]];
#else
	scAPIConfig = [[SCSoundCloudAPIConfiguration alloc] initForSandboxWithConsumerKey:kTestAppConsumerKey
																	   consumerSecret:kTestAppConsumerSecret
																		  callbackURL:[NSURL URLWithString:kCallbackURL]];
#endif
	[window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];	
	[viewController.scAPI handleOpenRedirectURL:launchURL]; 
	
	return YES;
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
@synthesize oauthVerifier;

#pragma mark -

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	return [viewController.scAPI handleOpenRedirectURL:url];
}

#pragma mark SCSoundCloudAPIAuthenticationDelegate

- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI preparedAuthorizationURL:(NSURL *)authorizationURL;
{
	authURL = [authorizationURL retain];
	safariAlertView = [[UIAlertView alloc] initWithTitle:@"OAuth Authentication"
												 message:@"The application will launch the SoundCloud website in Safari to allow you to authorize it."
												delegate:self
									   cancelButtonTitle:@"Launch Safari"
									   otherButtonTitles:nil];
	[safariAlertView show];
}

- (void)soundCloudAPIDidGetAccessToken:(SCSoundCloudAPI *)scAPI;
{
	viewController.postButton.enabled = YES;
	viewController.trackNameField.enabled = YES;
	// not the most elegant way to enable/disable the ui
	// but this is up to you (the developer of apps) to prove your cocoa skills :)
	
	[viewController requestUserInfo];
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI didFailToGetAccessTokenWithError:(NSError *)error;
{
	viewController.postButton.enabled = NO;
	viewController.trackNameField.enabled = NO;
	if ([[error domain] isEqualToString:SCAPIErrorDomain]) {
		if ([error code] == SCAPIErrorHttpResponseError) {
			// inform the user and offer him to retry.
			NSError *httpError = [[error userInfo] objectForKey:SCAPIHttpResponseErrorStatusKey];
			if ([httpError code] == NSURLErrorNotConnectedToInternet) {
				[viewController.postButton setTitle:@"No internet connection" forState:UIControlStateDisabled];
				[viewController.postButton setEnabled:NO];
			} else {
				NSLog(@"error: %@", [httpError localizedDescription]);
			}
		} else if ([error code] == SCAPIErrorNotAuthenticted) {
//			[_scAPI requestAuthentication];
		}
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