//
//  SCSoundCloud+Private.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 19.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

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
                                                                                           
                                                                                           SCLoginViewController *loginViewController = [[SCLoginViewController alloc] initWithURL:preparedURL
                                                                                                                                                                    authentication:nil];
                                                                                           
                                                                                           NSArray *windows = [[UIApplication sharedApplication] windows];
                                                                                           UIWindow *window = nil;
                                                                                           if (windows.count > 0) window = [windows objectAtIndex:0];
                                                                                           if ([window respondsToSelector:@selector(rootViewController)]) {
                                                                                               UIViewController *rootViewController = [window rootViewController];
                                                                                               [rootViewController presentModalViewController: loginViewController animated:YES];
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
