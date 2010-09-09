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

#import <Foundation/Foundation.h>

#import "SCAPI.h"


@interface iPhoneTestAppSoundCloudController : NSObject {
	SCSoundCloudAPI *scAPI;
}
@property (readonly) SCSoundCloudAPI *scAPI;
- (id)initWithAuthenticationDelegate:(NSObject<SCSoundCloudAPIAuthenticationDelegate> *)authDelegate
					   configuration:(SCSoundCloudAPIConfiguration *)configuration;

- (void)requestAuthentication;

#pragma mark API methods

- (SCSoundCloudConnection *)meWithContext:(id)context
								 delegate:(NSObject<SCSoundCloudConnectionDelegate> *)delegate;

- (SCSoundCloudConnection *)postTrackWithTitle:(NSString *)title
									   fileURL:(NSURL *)fileURL
									  isPublic:(BOOL)isPublic
									   context:(id)context
									  delegate:(NSObject<SCSoundCloudConnectionDelegate> *)delegate;
@end
