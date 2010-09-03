//
//  iPhoneTestAppSoundCloudController.m
//  iPhoneTestApp
//
//  Created by Ullrich Schäfer on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iPhoneTestAppSoundCloudController.h"


@implementation iPhoneTestAppSoundCloudController

#pragma mark Lifecycle

- (id)initWithAuthenticationDelegate:(NSObject<SCSoundCloudAPIAuthenticationDelegate> *)authDelegate configuration:(SCSoundCloudAPIConfiguration *)configuration;
{
	if (self = [super init]) {
		scAPI = [[SCSoundCloudAPI alloc] initWithAuthenticationDelegate:authDelegate
													   apiConfiguration:configuration];
		[scAPI setResponseFormat:SCResponseFormatJSON];
		
		[scAPI requestAuthentication];
	}
	return self;
}

- (void)dealloc;
{
	[scAPI release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize scAPI;


#pragma mark API Helper

- (SCSoundCloudConnection *)meWithContext:(id)context
								 delegate:(NSObject<SCSoundCloudConnectionDelegate> *)delegate;
{
	return [scAPI performMethod:@"GET"
					 onResource:@"/me"
				 withParameters:nil
						context:context
			 connectionDelegate:delegate];
}

- (SCSoundCloudConnection *)postTrackWithTitle:(NSString *)title
									   fileURL:(NSURL *)fileURL
										public:(BOOL)public
									   context:(id)context
									  delegate:(NSObject<SCSoundCloudConnectionDelegate> *)delegate;
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:title forKey:@"track[title]"];
	[parameters setObject:(public ? @"public" : @"private") forKey:@"track[sharing]"];
	[parameters setObject:fileURL forKey:@"track[asset_data]"];
	
	return [scAPI performMethod:@"POST"
					 onResource:@"tracks"
				 withParameters:parameters
						context:context
			 connectionDelegate:delegate];
}

@end
