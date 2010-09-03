//
//  iPhoneTestAppSoundCloudController.h
//  iPhoneTestApp
//
//  Created by Ullrich Schäfer on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCAPI.h"


@interface iPhoneTestAppSoundCloudController : NSObject {
	SCSoundCloudAPI *scAPI;
}
@property (readonly) SCSoundCloudAPI *scAPI;
- (id)initWithAuthenticationDelegate:(NSObject<SCSoundCloudAPIAuthenticationDelegate> *)authDelegate
					   configuration:(SCSoundCloudAPIConfiguration *)configuration;


#pragma mark API methods

- (SCSoundCloudConnection *)meWithContext:(id)context
								 delegate:(NSObject<SCSoundCloudConnectionDelegate> *)delegate;

- (SCSoundCloudConnection *)postTrackWithTitle:(NSString *)title
									   fileURL:(NSURL *)fileURL
public:(BOOL)public
context:(id)context
delegate:(NSObject<SCSoundCloudConnectionDelegate> *)delegate;
@end
