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

#import "SCSoundCloud.h"

#define kSoundCloudAPIURL					@"https://api.soundcloud.com/"
#define kSoundCloudAPIAccessTokenURL		@"https://api.soundcloud.com/oauth2/token"
#define kSoundCloudAuthURL					@"https://soundcloud.com/connect"

#define kSoundCloudSandboxAPIURL			@"https://api.sandbox-soundcloud.com/"
#define kSoundCloudSandboxAPIAccessTokenURL	@"https://api.sandbox-soundcloud.com/oauth2/token"
#define kSoundCloudSandboxAuthURL			@"https://sandbox-soundcloud.com/connect"


@interface SCSoundCloud ()
@property (nonatomic, assign) id accountAccountCreatedObserver;
@property (nonatomic, assign) id accountDidFailToGetAccessTokenObserver;
@end

@implementation SCSoundCloud

+ (id)shared;
{
    static SCSoundCloud *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SCSoundCloud new];
    });
    return shared;
}

- (id)init;
{
    self = [super init];
    if (self) {
        self.accountAccountCreatedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountCreated
                                                                                        object:nil
                                                                                         queue:nil
                                                                                    usingBlock:^(NSNotification *notification){
                                                                                        NXOAuth2Account *oauthAccount = [notification object];
                                                                                        if ([oauthAccount.accountType isEqualToString:kSCAccountType]) {
                                                                                            SCAccount *scAccount = [[SCAccount alloc] initWithOAuthAccount:oauthAccount];
                                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:SCAccountCreated object:scAccount];
                                                                                            [scAccount fetchUserInfoWithCompletionHandler:^(BOOL success, SCAccount *account, NSError *error){
                                                                                                if (!success) {
                                                                                                    NSLog(@"Could not fetch user info with account '%@': %@", oauthAccount, [error localizedDescription]);
                                                                                                }
                                                                                            }];
                                                                                            [scAccount release];
                                                                                        }
                                                                                    }];
        
        self.accountDidFailToGetAccessTokenObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountDidFailToGetAccessToken
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
    [[NSNotificationCenter defaultCenter] removeObserver:self.accountAccountCreatedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.accountDidFailToGetAccessTokenObserver];
    [super dealloc];
}

#pragma mark Accessors

@synthesize accountAccountCreatedObserver;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SCAccountRemoved object:account];
}

#pragma mark Configuration

- (NSDictionary *)configuration;
{
    NSDictionary *configuration = [[NXOAuth2AccountStore sharedStore] configurationForAccountType:kSCAccountType];
    
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationClientID] forKey:kSCConfigurationClientID];
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationSecret] forKey:kSCConfigurationSecret];
    [config setObject:[configuration objectForKey:kNXOAuth2AccountStoreConfigurationRedirectURL] forKey:kSCConfigurationRedirectURL];
    
    if ([[configuration objectForKey:kNXOAuth2AccountStoreConfigurationTokenURL] isEqual:[NSURL URLWithString:kSoundCloudSandboxAPIAccessTokenURL]]) {
        [config setObject:[NSNumber numberWithBool:YES] forKey:kSCConfigurationSandbox];
    } else {
        [config setObject:[NSNumber numberWithBool:NO] forKey:kSCConfigurationSandbox];
    }
    
    [config setObject:[configuration objectForKey:kSCConfigurationAPIURL] forKey:kSCConfigurationAPIURL];
    
    return config;
}

- (void)setConfiguration:(NSDictionary *)configuration;
{
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    [config setObject:[configuration objectForKey:kSCConfigurationClientID] forKey:kNXOAuth2AccountStoreConfigurationClientID];
    [config setObject:[configuration objectForKey:kSCConfigurationSecret] forKey:kNXOAuth2AccountStoreConfigurationSecret];
    [config setObject:[configuration objectForKey:kSCConfigurationRedirectURL] forKey:kNXOAuth2AccountStoreConfigurationRedirectURL];
    
    if ([[configuration objectForKey:kSCConfigurationSandbox] boolValue]) {
        [config setObject:[NSURL URLWithString:kSoundCloudSandboxAuthURL] forKey:kNXOAuth2AccountStoreConfigurationAuthorizeURL];
        [config setObject:[NSURL URLWithString:kSoundCloudSandboxAPIAccessTokenURL] forKey:kNXOAuth2AccountStoreConfigurationTokenURL];
        [config setObject:[NSURL URLWithString:kSoundCloudSandboxAPIURL] forKey:kSCConfigurationAPIURL];
    } else {
        [config setObject:[NSURL URLWithString:kSoundCloudAuthURL] forKey:kNXOAuth2AccountStoreConfigurationAuthorizeURL];
        [config setObject:[NSURL URLWithString:kSoundCloudAPIAccessTokenURL] forKey:kNXOAuth2AccountStoreConfigurationTokenURL];
        [config setObject:[NSURL URLWithString:kSoundCloudAPIURL] forKey:kSCConfigurationAPIURL];
    }
    
    [[NXOAuth2AccountStore sharedStore] setConfiguration:config forAccountType:kSCAccountType];
}


#pragma mark OAuth2 Flow

- (BOOL)handleRedirectURL:(NSURL *)URL;
{
    return [[NXOAuth2AccountStore sharedStore] handleRedirectURL:URL];
}

@end
