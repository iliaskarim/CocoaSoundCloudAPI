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

#import "SCTest_AppDelegate.h"

#import <JSON/JSON.h>

#import "SCParameterTableDataSource.h"

@interface SCTest_AppDelegate(private)
- (void)commonAwake;
- (void)_registerMyApp;
@end

@implementation SCTest_AppDelegate

#pragma mark Lifecycle

- (void)awakeFromNib;
{
	assert(fetchProgressIndicator != nil);
	assert(httpMethodCombo != nil);
	assert(newParameterAddButton != nil);
	assert(newParameterKeyField != nil);
	assert(newParameterRemoveButton != nil);
	assert(newParameterValueField != nil);
	assert(parametersTableView != nil);
	assert(resourceField != nil);
	assert(responseField != nil);
	assert(sendRequestButton != nil);
	[self commonAwake];
}

- (void)commonAwake;
{
	scAPIConfig = [[SCSoundCloudAPIConfiguration alloc] initForProductionWithConsumerKey:kTestAppConsumerKey
																		  consumerSecret:kTestAppConsumerSecret
																			 callbackURL:[NSURL URLWithString:kCallbackURL]];
	
	scAPI = [[SCSoundCloudAPI alloc] initWithAuthenticationDelegate:self];
	[scAPI setDelegate:self];
	[scAPI setResponseFormat:SCResponseFormatJSON];
	
	parametersDataSource = [[SCParameterTableDataSource alloc] init];
	[parametersTableView setDataSource:parametersDataSource];
	
	[self _registerMyApp];
}	

-(void)dealloc;
{
	[scAPIConfig release];
	[scAPI release];
	[parametersDataSource release];
	[super dealloc];
}

#pragma mark URL handling

- (void)_registerMyApp;
{
	NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
	[em setEventHandler:self 
			andSelector:@selector(getUrl:withReplyEvent:) 
		  forEventClass:kInternetEventClass 
			 andEventID:kAEGetURL];
	
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	OSStatus result = LSSetDefaultHandlerForURLScheme((CFStringRef)@"myapp", (CFStringRef)bundleID);
	if(result != noErr) {
		NSLog(@"could not register to \"myapp\" URL scheme");
	}
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	// Get the URL
	NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] 
						stringValue];

	if([urlStr hasPrefix:kCallbackURL]) {
		NSLog(@"handling oauth callback");
		[scAPI authorizeRequestToken]; 
	}
}

#pragma mark Actions

- (IBAction)addParameter:(id)sender {
	NSString *key = [newParameterKeyField stringValue];
	NSString *value = [newParameterValueField stringValue];
	[parametersDataSource addParameterWithKey:key
										value:value];
	[parametersTableView reloadData];
}

- (IBAction)removeParameter:(id)sender {
    [parametersDataSource removeParametersAtIndexes:[parametersTableView selectedRowIndexes]];
	[parametersTableView reloadData];
}

- (IBAction)sendRequest:(id)sender {
	[fetchProgressIndicator startAnimation:nil];
	
	[scAPI performMethod:[httpMethodCombo stringValue]
			  onResource:[resourceField stringValue]
		  withParameters:[parametersDataSource parameterDictionary]
				 context:nil];
}

- (IBAction)postTest:(id)sender;
{
	// sample from http://www.freesound.org/samplesViewSingle.php?id=1375
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"mp3"];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	
	NSMutableDictionary *parameters = [[parametersDataSource parameterDictionary] mutableCopy];
	[parameters setObject:fileURL forKey:@"track[asset_data]"];
	
	[fetchProgressIndicator startAnimation:nil];
	[scAPI performMethod:@"POST"
			  onResource:[resourceField stringValue]
		  withParameters:parameters
				 context:nil];
	[parameters release];
}

- (IBAction)deleteAllMyTracks:(id)sender;
{
	[scAPI performMethod:@"GET"
			  onResource:@"me/tracks"
		  withParameters:nil
				 context:@"deleteMyTracks"];
}

- (void)deleteTracks:(NSArray *)tracks;
{
	for(NSDictionary *track in tracks) {
		[scAPI performMethod:@"DELETE"
				  onResource:[NSString stringWithFormat:@"tracks/%@", [track objectForKey:@"id"]]
			  withParameters:nil
					 context:nil];
	}
}


#pragma mark request delegates

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didFinishWithData:(NSData *)data context:(id)context;
{
	[fetchProgressIndicator stopAnimation:nil];
	[postProgress setDoubleValue:0];
	
	NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *json = [[[SBJSON alloc] init] autorelease];
	[json setHumanReadable:YES];
	NSError *error;
	id object = [json objectWithString:dataStr error:&error];
	
	if([context isEqualToString:@"deleteMyTracks"]) {
		[self deleteTracks:object];
		[dataStr release];
		return;
	}
	
	if(object){
		[dataStr release]; dataStr = [json stringWithObject:object error:&error]; [dataStr retain];
	}
	[responseField setString:dataStr];
	[dataStr release];
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didFailWithError:(NSError *)error context:(id)context;
{
	[fetchProgressIndicator stopAnimation:nil];
	[postProgress setDoubleValue:0];
	
	NSString *message = [NSString stringWithFormat:@"Request finished with Error: \n%@", [error localizedDescription]];
	NSLog(message);
	[responseField setString:message];
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveData:(NSData *)data context:(id)context;
{
	NSLog(@"Did Recieve Data");
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveBytes:(UInt32)loadedBytes total:(UInt32)totalBytes context:(id)context;
{
	NSLog(@"Did receive Bytes %qu of %qu", loadedBytes, totalBytes);
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didSendBytes:(UInt32)sendBytes total:(UInt32)totalBytes context:(id)context;
{
	NSLog(@"Did send Bytes %qu of %qu", sendBytes, totalBytes);
	[postProgress setDoubleValue:100 * sendBytes / totalBytes];
}



#pragma mark SoundCloudAPI authorization delegate
- (SCSoundCloudAPIConfiguration *)configurationForSoundCloudAPI:(SCSoundCloudAPI *)scAPI;
{
	return scAPIConfig;
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI requestedAuthenticationWithURL:(NSURL *)authURL;
{
	[[NSWorkspace sharedWorkspace] openURL:authURL];
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)_scAPI didChangeAuthenticationStatus:(SCAuthenticationStatus)status;
{
	switch (status) {
		case SCAuthenticationStatusAuthenticated:
			// authenticated
			[sendRequestButton setEnabled:YES];
			// not the most elegant way to enable/disable the ui
			// but this is up to you (the developer of apps) to prove your cocoa skills :)
			[postTestButton setEnabled:YES];
			break;
		case SCAuthenticationStatusNotAuthenticated:
			[sendRequestButton setEnabled:NO];
			[postTestButton setEnabled:NO];
			[_scAPI requestAuthentication];
			break;
		case SCAuthenticationStatusGettingToken:
			[sendRequestButton setEnabled:NO];
			[postTestButton setEnabled:NO];
			// should not send requests to the api while it is in this state.
			break;
		case SCAuthenticationStatusWillAuthorizeRequestToken:
			[sendRequestButton setEnabled:NO];
			[postTestButton setEnabled:NO];
			[_scAPI authorizeRequestToken];
			break;
		default:
			break;
	}
}

@end
