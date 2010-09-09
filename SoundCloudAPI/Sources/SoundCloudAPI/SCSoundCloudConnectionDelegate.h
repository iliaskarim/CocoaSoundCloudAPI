//
//  SCSoundCloudConnectionDelegate.h
//  SoundCloudAPI
//
//  Created by Ullrich Schäfer on 09.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SCSoundCloudConnectionDelegate <NSObject>
@optional
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didFinishWithData:(NSData *)data context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didFailWithError:(NSError *)error context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didCancelRequestWithContext:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didReceiveData:(NSData *)data context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
- (void)soundCloudConnection:(SCSoundCloudConnection *)connection didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
@end