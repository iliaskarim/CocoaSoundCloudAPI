/*
 * Copyright 2010 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
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

#import "SCAPI.h"

#import "iPhoneTestAppAppDelegate.h"
#import "iPhoneTestAppViewController.h"


@implementation iPhoneTestAppAppDelegate

+ (void)initialize;
{
    // Configure NXOAuth2AccountStore for 'com.soundcloud.api'
    // -------------------------------------------------------

#if SANDBOX
    [[SCSoundCloud shared] setConfiguration:[NSDictionary dictionaryWithObjectsAndKeys:
                                             @"3f1259d2066b28f2f01573640617f6aa", kSCConfigurationClientID,
                                             @"07682dc23ef6b7f2e96ce9b89798fe3a", kSCConfigurationSecret,
                                             [NSURL URLWithString:@"x-oauth2-test://soundcloud"], kSCConfigurationRedirectURL,
                                             [NSNumber numberWithBool:YES], kSCConfigurationSandbox, nil]];
#else
    [[SCSoundCloud shared] setConfiguration:[NSDictionary dictionaryWithObjectsAndKeys:
                                             @"3f1259d2066b28f2f01573640617f6aa", kSCConfigurationClientID,
                                             @"07682dc23ef6b7f2e96ce9b89798fe3a", kSCConfigurationSecret,
                                             [NSURL URLWithString:@"x-oauth2-test://soundcloud"], kSCConfigurationRedirectURL, nil]];
#endif
    
}

#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
	NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];	
	BOOL didHandleURL = NO;
	if (launchURL) {
		didHandleURL = [[SCSoundCloud shared] handleRedirectURL:launchURL];	
	}
	
    if ([[[SCSoundCloud shared] accounts] count] < 1) {
        [[SCSoundCloud shared] requestAccess];
    }
    
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];
    
	return didHandleURL; 
}

- (void)dealloc;
{
    [viewController release];
    [window release];
    [super dealloc];
}


#pragma mark Accessors

@synthesize window;
@synthesize viewController;

#pragma mark -

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	return [[SCSoundCloud shared] handleRedirectURL:url];
}

@end