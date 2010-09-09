/*
 * Copyright 2010 nxtbgthng for SoundCloud Ltd.
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

#import "SCSoundCloudAPIConfiguration.h"


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
					  accessTokenURL:[NSURL URLWithString:kSoundCloudSandboxAPIAccesTokenURL]
							 authURL:[NSURL URLWithString:kSoundCloudSandboxAuthURL]];
}

- (id)initWithConsumerKey:(NSString *)inConsumerKey
		   consumerSecret:(NSString *)inConsumerSecret
			  callbackURL:(NSURL *)inCallbackURL
			   apiBaseURL:(NSURL *)inApiBaseURL
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
	[accessTokenURL release]; accessTokenURL = nil;
	[authURL release]; authURL = nil;
	
	[consumerKey release]; consumerKey = nil;
	[consumerSecret release]; consumerSecret = nil;
	[callbackURL release]; callbackURL = nil;
	[super dealloc];
}

#pragma mark Accessors

@synthesize apiBaseURL, accessTokenURL, authURL;
@synthesize consumerKey, consumerSecret;
@synthesize callbackURL;


@end
