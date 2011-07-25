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

#import "iPhoneTestAppDelegate.h"
#import "iPhoneTestAppViewController.h"


@implementation iPhoneTestAppDelegate

#pragma marl SoundCloud

+ (void)initialize;
{
    // Configure NXOAuth2AccountStore for 'com.soundcloud.api'
    // -------------------------------------------------------
    
    [SCSoundCloud  setClientID:@"3f1259d2066b28f2f01573640617f6aa"
                        secret:@"07682dc23ef6b7f2e96ce9b89798fe3a"
                   redirectURL:[NSURL URLWithString:@"x-oauth2-test://soundcloud"]];
}

- (SCAccount *)scAccount;
{
    @synchronized (scAccount) {
        if (scAccount == nil) {
            NSArray *accounts = [SCSoundCloud accounts];
            if ([accounts count] == 0) {
                NSLog(@"Requesting access to SoundCloud.");
                [SCSoundCloud requestAccess];
            } else {
                scAccount = [[accounts objectAtIndex:0] retain];
            }
        }
        return scAccount;
    }
}


#pragma mark Lifecycle





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];
 
    
    // ---8<------8<------8<------8<------8<------8<------8<----
    
    void (^accountSetter)(NSNotification*) = ^(NSNotification *notification) {
        NSArray *accounts = [SCSoundCloud accounts];
        if (accounts.count < 1) {
            [SCSoundCloud requestAccess];
        } else {
            SCAccount *newAccount = [accounts objectAtIndex:0];
            if (![newAccount isEqual:self.scAccount]) {
                self.scAccount = newAccount;
            }
        }
    };    
    
    accountsChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SCSoundCloudAccountsDidChangeNotification
                                                                               object:nil
                                                                                queue:nil
                                                                           usingBlock:accountSetter];
    
    accountSetter(nil);
    
    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];	
	BOOL didHandleURL = NO;
	if (launchURL) {
		didHandleURL = [SCSoundCloud handleRedirectURL:launchURL];	
	}

    // ---8<------8<------8<------8<------8<------8<------8<----
    
	return didHandleURL;
}

- (void)dealloc;
{
    // ---8<------8<------8<------8<------8<------8<------8<----
    
    [[NSNotificationCenter defaultCenter] removeObserver:accountsChangeObserver];
    
    // ---8<------8<------8<------8<------8<------8<------8<----
    
    [viewController release];
    [window release];
    [super dealloc];
}


#pragma mark Accessors

@synthesize window;
@synthesize viewController;
@synthesize scAccount;

#pragma mark -

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	return [SCSoundCloud handleRedirectURL:url];
}

@end
