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

#define kSoundCloudAPIURL					@"https://api.soundcloud.com"
#define kSoundCloudAPIAccesTokenURL			@"https://api.soundcloud.com/oauth2/token"
#define kSoundCloudAuthURL					@"https://soundcloud.com/oauth2/authorize"

#define kSoundCloudSandboxAPIURL			@"https://api.sandbox-soundcloud.com"
#define kSoundCloudSandboxAPIAccesTokenURL	@"https://api.sandbox-soundcloud.com/oauth2/token"
#define kSoundCloudSandboxAuthURL			@"https://sandbox-soundcloud.com/oauth2/authorize"


@interface SCSoundCloudAPIConfiguration : NSObject {
	NSURL *apiBaseURL;
	NSURL *accessTokenURL;
	NSURL *authURL;
	
	NSString *consumerKey;
	NSString *consumerSecret;
	NSURL *callbackURL;
}

+ (id)configurationForProductionWithConsumerKey:(NSString *)inConsumerKey
								 consumerSecret:(NSString *)inConsumerSecret
									callbackURL:(NSURL *)inCallbackURL;

+ (id)configurationForSandboxWithConsumerKey:(NSString *)consumerKey
							  consumerSecret:(NSString *)consumerSecret
								 callbackURL:(NSURL *)callbackURL;

- (id)initForProductionWithConsumerKey:(NSString *)inConsumerKey
						consumerSecret:(NSString *)inConsumerSecret
						   callbackURL:(NSURL *)inCallbackURL;

- (id)initForSandboxWithConsumerKey:(NSString *)inConsumerKey
					 consumerSecret:(NSString *)inConsumerSecret
						callbackURL:(NSURL *)inCallbackURL;

- (id)initWithConsumerKey:(NSString *)consumerKey
		   consumerSecret:(NSString *)consumerSecret
			  callbackURL:(NSURL *)callbackURL
			   apiBaseURL:(NSURL *)apiBaseURL
		   accessTokenURL:(NSURL *)accessTokenURL
				  authURL:(NSURL *)authURL;


@property (nonatomic, retain) NSURL *apiBaseURL;
@property (nonatomic, retain) NSURL *accessTokenURL;
@property (nonatomic, retain) NSURL *authURL;
@property (nonatomic, retain) NSString *consumerKey;
@property (nonatomic, retain) NSString *consumerSecret;
@property (nonatomic, retain) NSURL *callbackURL;

@end

