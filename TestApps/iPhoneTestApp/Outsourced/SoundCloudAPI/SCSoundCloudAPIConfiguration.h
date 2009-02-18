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

#define kSoundCloudAPIURL				@"http://api.soundcloud.com"
#define kSoundCloudAPIRequestTokenURL	@"http://api.soundcloud.com/oauth/request_token"
#define kSoundCloudAPIAccesTokenURL		@"http://api.soundcloud.com/oauth/access_token"
#define kSoundCloudAuthURL				@"http://soundcloud.com/oauth/authorize"

#define kSoundCloudSandboxAPIURL				@"http://api.sandbox-soundcloud.com"
#define kSoundCloudSandboxAPIRequestTokenURL	@"http://api.sandbox-soundcloud.com/oauth/request_token"
#define kSoundCloudSandboxAPIAccesTokenURL		@"http://api.sandbox-soundcloud.com/oauth/access_token"
#define kSoundCloudSandboxAuthURL				@"http://sandbox-soundcloud.com/oauth/authorize"


@interface SCSoundCloudAPIConfiguration : NSObject {
	NSURL *apiBaseURL;
	NSURL *requestTokenURL;
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
		  requestTokenURL:(NSURL *)requestTokenURL
		   accessTokenURL:(NSURL *)accessTokenURL
				  authURL:(NSURL *)authURL;


@property (nonatomic, retain) NSURL *apiBaseURL;
@property (nonatomic, retain) NSURL *requestTokenURL;
@property (nonatomic, retain) NSURL *accessTokenURL;
@property (nonatomic, retain) NSURL *authURL;
@property (nonatomic, retain) NSString *consumerKey;
@property (nonatomic, retain) NSString *consumerSecret;
@property (nonatomic, retain) NSURL *callbackURL;

@end

