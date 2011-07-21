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

#import "SCSoundCloud+Private.h"
#import "SCSoundCloud.h"


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

+ (void)initialize;
{
    [SCSoundCloud shared];
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

+ (NSArray *)accounts;
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

+ (SCAccount *)accountWithIdentifier:(NSString *)identifier;
{
    NXOAuth2Account *oauthAccount = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:identifier];
    SCAccount *account = [[SCAccount alloc] initWithOAuthAccount:oauthAccount];
    return [account autorelease];
}


#pragma mark Manage Accounts

+ (void)requestAccess;
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kSCAccountType];
}

+ (void)removeAccount:(SCAccount *)account;
{
    [[NXOAuth2AccountStore sharedStore] removeAccount:account.oauthAccount];
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSoundCloudDidRemoveAccountNotification object:account];
}

#pragma mark Configuration

+ (void)setClientID:(NSString *)aClientID
             secret:(NSString *)aSecret
        redirectURL:(NSURL *)aRedirectURL;
{
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    [config setObject:aClientID forKey:kNXOAuth2AccountStoreConfigurationClientID];
    [config setObject:aSecret forKey:kNXOAuth2AccountStoreConfigurationSecret];
    [config setObject:aRedirectURL forKey:kNXOAuth2AccountStoreConfigurationRedirectURL];

    [config setObject:[NSURL URLWithString:kSCSoundCloudAuthURL] forKey:kNXOAuth2AccountStoreConfigurationAuthorizeURL];
    [config setObject:[NSURL URLWithString:kSCSoundCloudAccessTokenURL] forKey:kNXOAuth2AccountStoreConfigurationTokenURL];
    [config setObject:[NSURL URLWithString:kSCSoundCloudAPIURL] forKey:kSCConfigurationAPIURL];
    
    [[NXOAuth2AccountStore sharedStore] setConfiguration:config forAccountType:kSCAccountType];
}


#pragma mark Prepared Authorization URL Handler

+ (void)setPreparedAuthorizationURLHandler:(SCPreparedAuthorizationURLHandler)handler;
{
    [[NXOAuth2AccountStore sharedStore] setPreparedAuthorizationURLHandlerForAccountType:kSCAccountType block:handler];
}

+ (SCPreparedAuthorizationURLHandler)preparedAuthorizationURLHandler;
{
    return [[NXOAuth2AccountStore sharedStore] preparedAuthorizationURLHandlerForAccountType:kSCAccountType];
}


#pragma mark OAuth2 Flow

+ (BOOL)handleRedirectURL:(NSURL *)URL;
{
    return [[NXOAuth2AccountStore sharedStore] handleRedirectURL:URL];
}

@end
