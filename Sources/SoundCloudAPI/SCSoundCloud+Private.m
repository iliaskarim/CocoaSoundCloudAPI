/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
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

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#import "SCLoginViewController.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#import <Cocoa/Cocoa.h>
#endif

#import "SCConstants.h"

#import "SCSoundCloud+Private.h"


@implementation SCSoundCloud (Private)

+ (id)shared;
{
    static SCSoundCloud *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SCSoundCloud new];
        
        // Set default handler for prepared authorization urls.
        
        [[NXOAuth2AccountStore sharedStore] setPreparedAuthorizationURLHandlerForAccountType:kSCAccountType
                                                                                       block:^(NSURL *preparedURL){
                                                                                           NSLog(@"Open prepared URL: %@", preparedURL);
#if TARGET_OS_IPHONE
                                                                                           NSArray *windows = [[UIApplication sharedApplication] windows];
                                                                                           UIWindow *window = nil;
                                                                                           if (windows.count > 0) window = [windows objectAtIndex:0];
                                                                                           if ([window respondsToSelector:@selector(rootViewController)]) {

                                                                                               UIViewController *topMostViewController = [window rootViewController];
                                                                                               
                                                                                               while (topMostViewController.modalViewController) {
                                                                                                   topMostViewController = topMostViewController.modalViewController;
                                                                                               }
                                                                                               
                                                                                               SCLoginViewController *loginViewController = [[SCLoginViewController alloc] initWithURL:preparedURL
                                                                                                                                                                        dismissHandler:^{
                                                                                                                                                                            [topMostViewController dismissModalViewControllerAnimated:YES];
                                                                                                                                                                        }];
                                                                                               
                                                                                               [topMostViewController presentModalViewController:loginViewController animated:YES];
                                    
                                                                                           } else {
                                                                                               NSAssert(NO, @"If you're not on iOS4 you need to implement -soundCloudAPIDisplayViewController: or show your own authentication controller in -soundCloudAPIPreparedAuthorizationURL:");
                                                                                           }
#else
                                                                                           [[NSWorkspace sharedWorkspace] openURL:preparedURL];
#endif
                                                                                       }];
    });
    return shared;
}

#pragma mark Configuration


+ (NSDictionary *)configuration;
{
    NSDictionary *configuration = [[NXOAuth2AccountStore sharedStore] configurationForAccountType:kSCAccountType];
    
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationClientID] forKey:kSCConfigurationClientID];
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationSecret] forKey:kSCConfigurationSecret];
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationRedirectURL] forKey:kSCConfigurationRedirectURL];
    
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationAuthorizeURL] forKey:kSCConfigurationAuthorizeURL];
    
    if ([[configuration objectForKey:kNXOAuth2AccountStoreConfigurationTokenURL] isEqual:[NSURL URLWithString:kSCSoundCloudSandboxAccessTokenURL]]) {
        [config setObject:[NSNumber numberWithBool:YES] forKey:kSCConfigurationSandbox];
    } else {
        [config setObject:[NSNumber numberWithBool:NO] forKey:kSCConfigurationSandbox];
    }
    
    [config setObject:[configuration objectForKey:kSCConfigurationAPIURL] forKey:kSCConfigurationAPIURL];
    
    return config;
}

#pragma mark Manage Accounts


- (void)requestAccessWithUsername:(NSString *)username password:(NSString *)password;
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kSCAccountType username:username password:password];
}

@end
