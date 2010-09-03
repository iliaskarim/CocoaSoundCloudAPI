//
//  SCSoundCloudConnection.h
//  SoundCloudAPI
//
//  Created by Ullrich Schäfer on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NXOAuth2Client, NXOAuth2Connection;

@class SCSoundCloudAPI;
@protocol SCSoundCloudConnectionDelegate;


/*!
 * A wrapper arond NXOAuth2Connection
 */
@interface SCSoundCloudConnection : NSObject {
@private
	NXOAuth2Connection	*connection;
	NSObject<SCSoundCloudConnectionDelegate>*	delegate;
}

+ (SCSoundCloudConnection *)connectionWithRequest:(NSURLRequest *)request
									  oauthClient:(NXOAuth2Client *)oauthClient
										  context:(id)context
							   connectionDelegate:(NSObject<SCSoundCloudConnectionDelegate> *)connectionDelegate;

- (id)initWithRequest:(NSURLRequest *)request
		  oauthClient:(NXOAuth2Client *)oauthClient
			  context:(id)context
   connectionDelegate:(NSObject<SCSoundCloudConnectionDelegate> *)connectionDelegate;

- (void)cancel;

@end


@protocol SCSoundCloudConnectionDelegate <NSObject>
@optional
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didFinishWithData:(NSData *)data context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didFailWithError:(NSError *)error context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didCancelRequestWithContext:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didReceiveData:(NSData *)data context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
@end