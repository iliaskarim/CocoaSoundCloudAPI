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

#import "SCSoundCloudAPIConfiguration.h"

#import "NSURL+SoundCloudAPI.h"
#import "NSMutableURLRequest+SoundCloudAPI.h"


@implementation SCSoundCloudAPIConfiguration

#pragma mark Lifecycle

+ (id)configurationForProductionWithConsumerKey:(NSString *)inConsumerKey
								 consumerSecret:(NSString *)inConsumerSecret
									callbackURL:(NSURL *)inCallbackURL;
{
	return [[[self alloc] initForProductionWithConsumerKey:inConsumerKey
											consumerSecret:inConsumerSecret
											   callbackURL:inCallbackURL] autorelease];
}

+ (id)configurationForSandboxWithConsumerKey:(NSString *)inConsumerKey
							  consumerSecret:(NSString *)inConsumerSecret
								 callbackURL:(NSURL *)inCallbackURL;
{
	return [[[self alloc] initForSandboxWithConsumerKey:inConsumerKey
										 consumerSecret:inConsumerSecret
											callbackURL:inCallbackURL] autorelease];
}

- (id)initForProductionWithConsumerKey:(NSString *)inConsumerKey
						consumerSecret:(NSString *)inConsumerSecret
						   callbackURL:(NSURL *)inCallbackURL;
{
	return [self initWithConsumerKey:inConsumerKey
					  consumerSecret:inConsumerSecret
						 callbackURL:inCallbackURL
						  apiBaseURL:[NSURL URLWithString:kSoundCloudAPIURL]
					 requestTokenURL:[NSURL URLWithString:kSoundCloudAPIRequestTokenURL]
					  accessTokenURL:[NSURL URLWithString:kSoundCloudAPIAccesTokenURL]
							 authURL:[NSURL URLWithString:kSoundCloudAuthURL]];
}


- (id)initForSandboxWithConsumerKey:(NSString *)inConsumerKey
					 consumerSecret:(NSString *)inConsumerSecret
						callbackURL:(NSURL *)inCallbackURL;
{
	return [self initWithConsumerKey:inConsumerKey
					  consumerSecret:inConsumerSecret
						 callbackURL:inCallbackURL
						  apiBaseURL:[NSURL URLWithString:kSoundCloudSandboxAPIURL]
					 requestTokenURL:[NSURL URLWithString:kSoundCloudSandboxAPIRequestTokenURL]
					  accessTokenURL:[NSURL URLWithString:kSoundCloudSandboxAPIAccesTokenURL]
							 authURL:[NSURL URLWithString:kSoundCloudSandboxAuthURL]];
}

- (id)initWithConsumerKey:(NSString *)inConsumerKey
		   consumerSecret:(NSString *)inConsumerSecret
			  callbackURL:(NSURL *)inCallbackURL
			   apiBaseURL:(NSURL *)inApiBaseURL
		  requestTokenURL:(NSURL *)inRequestTokenURL
		   accessTokenURL:(NSURL *)inAccessTokenURL
				  authURL:(NSURL *)inAuthURL;
{
	if (!inConsumerKey){
		NSLog(@"No ConsumerKey supplied");
		return nil;
	}
	if (!inConsumerSecret){
		NSLog(@"No ConsumerSecret supplied");
		return nil;
	}	
	if (!inCallbackURL){
		NSLog(@"No CallbackURL supplied");
		return nil;
	}
	if (!inApiBaseURL){
		NSLog(@"No ApiBaseURL supplied");
		return nil;
	}
	if (!inRequestTokenURL){
		NSLog(@"No RequestTokenURL supplied");
		return nil;
	}
	if (!inAccessTokenURL){
		NSLog(@"No AccessTokenURL supplied");
		return nil;
	}
	if (!inAuthURL){
		NSLog(@"No AuthURL supplied");
		return nil;
	}
	
	if (self = [super init]) {
		apiBaseURL = [inApiBaseURL retain];
		requestTokenURL = [inRequestTokenURL retain];
		accessTokenURL = [inAccessTokenURL retain];
		authURL = [inAuthURL retain];
		
		consumerKey = [inConsumerKey retain];
		consumerSecret = [inConsumerSecret retain];
		callbackURL = [inCallbackURL retain];
	}
	return self;	
}

-(void)dealloc;
{
	[apiBaseURL release]; apiBaseURL = nil;
	[requestTokenURL release]; requestTokenURL = nil;
	[accessTokenURL release]; accessTokenURL = nil;
	[authURL release]; authURL = nil;
	
	[consumerKey release]; consumerKey = nil;
	[consumerSecret release]; consumerSecret = nil;
	[callbackURL release]; callbackURL = nil;
	[super dealloc];
}

#pragma mark Accessors

@synthesize apiBaseURL, requestTokenURL, accessTokenURL, authURL;
@synthesize consumerKey, consumerSecret;
@synthesize callbackURL;


@end
