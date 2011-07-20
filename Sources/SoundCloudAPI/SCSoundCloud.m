//
//  SCSoundCloud.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "SCAccount.h"
#import "SCAccount+Private.h"
#import "SCRequest.h"
#import "SCConstants.h"

#if TARGET_OS_IPHONE
#import "SCLoginViewController.h"
#else

#endif

#import "SCSoundCloud.h"

#define kSoundCloudAPIURL					@"https://api.soundcloud.com/"
#define kSoundCloudAPIAccessTokenURL		@"https://api.soundcloud.com/oauth2/token"
#define kSoundCloudAuthURL					@"https://soundcloud.com/connect"

#define kSoundCloudSandboxAPIURL			@"https://api.sandbox-soundcloud.com/"
#define kSoundCloudSandboxAPIAccessTokenURL	@"https://api.sandbox-soundcloud.com/oauth2/token"
#define kSoundCloudSandboxAuthURL			@"https://sandbox-soundcloud.com/connect"


#pragma mark Notifications

NSString * const SCSoundCloudDidCreateAccountNotification = @"SCSoundCloudDidCreateAccountNotification";
NSString * const SCSoundCloudDidRemoveAccountNotification = @"SCSoundCloudDidRemoveAccountNotification";

NSString * const SCSoundCloudDidFailToRequestAccessNotification = @"SCSoundCloudDidFailToRequestAccessNotification";

#pragma mark -


@interface SCSoundCloud ()
@property (nonatomic, assign) id accountStoreDidCreateAccountObserver;
@property (nonatomic, assign) id accountDidFailToGetAccessTokenObserver;
@end

@implementation SCSoundCloud

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

- (id)init;
{
    self = [super init];
    if (self) {
        self.accountStoreDidCreateAccountObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidCreateAccountNotification
                                                                                                      object:nil
                                                                                                       queue:nil
                                                                                                  usingBlock:^(NSNotification *notification){
                                                                                                      NXOAuth2Account *oauthAccount = [notification object];
                                                                                                      if ([oauthAccount.accountType isEqualToString:kSCAccountType]) {
                                                                                                          
                                                                                                          SCAccount *scAccount = [[SCAccount alloc] initWithOAuthAccount:oauthAccount];
                                                                                                          [[NSNotificationCenter defaultCenter] postNotificationName:SCSoundCloudDidCreateAccountNotification object:scAccount];
                                                                                                          
                                                                                                      }
                                                                                                  }];
        
        self.accountDidFailToGetAccessTokenObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountDidFailToGetAccessTokenNotification
                                                                                                        object:nil
                                                                                                         queue:nil
                                                                                                    usingBlock:^(NSNotification *notification){
                                                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:SCAccountDidFailToGetAccessToken
                                                                                                                                                            object:notification.object];
                                                                                                    }];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.accountStoreDidCreateAccountObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.accountDidFailToGetAccessTokenObserver];
    [super dealloc];
}

#pragma mark Accessors

@synthesize accountStoreDidCreateAccountObserver;
@synthesize accountDidFailToGetAccessTokenObserver;

- (NSArray *)accounts;
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *oauthAccounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kSCAccountType];
    for (NXOAuth2Account *oauthAccount in oauthAccounts) {
        SCAccount *account = [[SCAccount alloc] initWithOAuthAccount:oauthAccount];
        [result addObject:account];
        [account release];
    }
    return result;
}

- (SCAccount *)accountWithIdentifier:(NSString *)identifier;
{
    NXOAuth2Account *oauthAccount = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:identifier];
    SCAccount *account = [[SCAccount alloc] initWithOAuthAccount:oauthAccount];
    return [account autorelease];
}


#pragma mark Manage Accounts

- (void)requestAccess;
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kSCAccountType];
}

- (void)removeAccount:(SCAccount *)account;
{
    [[NXOAuth2AccountStore sharedStore] removeAccount:account.oauthAccount];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSoundCloudDidRemoveAccountNotification object:account];
}

#pragma mark Configuration

- (void)setClientID:(NSString *)aClientID
             secret:(NSString *)aSecret
        redirectURL:(NSURL *)aRedirectURL;
{
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    [config setObject:aClientID forKey:kNXOAuth2AccountStoreConfigurationClientID];
    [config setObject:aSecret forKey:kNXOAuth2AccountStoreConfigurationSecret];
    [config setObject:aRedirectURL forKey:kNXOAuth2AccountStoreConfigurationRedirectURL];

    [config setObject:[NSURL URLWithString:kSoundCloudAuthURL] forKey:kNXOAuth2AccountStoreConfigurationAuthorizeURL];
    [config setObject:[NSURL URLWithString:kSoundCloudAPIAccessTokenURL] forKey:kNXOAuth2AccountStoreConfigurationTokenURL];
    [config setObject:[NSURL URLWithString:kSoundCloudAPIURL] forKey:kSCConfigurationAPIURL];
    
    [[NXOAuth2AccountStore sharedStore] setConfiguration:config forAccountType:kSCAccountType];
}

- (NSDictionary *)configuration;
{
    NSDictionary *configuration = [[NXOAuth2AccountStore sharedStore] configurationForAccountType:kSCAccountType];
    
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationClientID] forKey:kSCConfigurationClientID];
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationSecret] forKey:kSCConfigurationSecret];
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationRedirectURL] forKey:kSCConfigurationRedirectURL];
    
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationAuthorizeURL] forKey:kSCConfigurationAuthorizeURL];
    
    if ([[configuration objectForKey:kNXOAuth2AccountStoreConfigurationTokenURL] isEqual:[NSURL URLWithString:kSoundCloudSandboxAPIAccessTokenURL]]) {
        [config setObject:[NSNumber numberWithBool:YES] forKey:kSCConfigurationSandbox];
    } else {
        [config setObject:[NSNumber numberWithBool:NO] forKey:kSCConfigurationSandbox];
    }
    
    [config setObject:[configuration objectForKey:kSCConfigurationAPIURL] forKey:kSCConfigurationAPIURL];
    
    return config;
}

#pragma mark Prepared Authorization URL Handler

- (void)setPreparedAuthorizationURLHandler:(SCPreparedAuthorizationURLHandler)handler;
{
    [[NXOAuth2AccountStore sharedStore] setPreparedAuthorizationURLHandlerForAccountType:kSCAccountType block:handler];
}

- (SCPreparedAuthorizationURLHandler)preparedAuthorizationURLHandler;
{
    return [[NXOAuth2AccountStore sharedStore] preparedAuthorizationURLHandlerForAccountType:kSCAccountType];
}


#pragma mark OAuth2 Flow

- (BOOL)handleRedirectURL:(NSURL *)URL;
{
    return [[NXOAuth2AccountStore sharedStore] handleRedirectURL:URL];
}

@end
