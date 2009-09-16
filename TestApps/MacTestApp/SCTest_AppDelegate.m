/*
 * Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
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
	
#ifdef kUseProduction
	scAPIConfig = [[SCSoundCloudAPIConfiguration alloc] initForProductionWithConsumerKey:kTestAppConsumerKey
																		  consumerSecret:kTestAppConsumerSecret
																			 callbackURL:[NSURL URLWithString:kCallbackURL]];
#else
	scAPIConfig = [[SCSoundCloudAPIConfiguration alloc] initForSandboxWithConsumerKey:kTestAppConsumerKey
																	   consumerSecret:kTestAppConsumerSecret
																		  callbackURL:[NSURL URLWithString:kCallbackURL]];
#endif
	
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
		NSURL *url = [NSURL URLWithString:urlStr];
		NSString *verifier = [url valueForQueryParameterKey:@"oauth_verifier"];
		[scAPI setRequestTokenVerifier:verifier];
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
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"wav"];
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
	NSString *message = nil;
	if ([error.domain isEqualToString:SCAPIErrorDomain] && error.code == SCAPIErrorHttpResponseError) {
		NSError *httpError = [[error userInfo] objectForKey:SCAPIHttpResponseErrorStatusKey];
		message = [NSString stringWithFormat:@"Request finished with Error: \n%@", [httpError localizedDescription]];
	} else {
		message = [NSString stringWithFormat:@"Request finished with Error: \n%@", [error localizedDescription]];
	}
	NSLog(@"%@", message);
	[responseField setString:message];
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveData:(NSData *)data context:(id)context;
{
	NSLog(@"Did Recieve Data");
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
{
	NSLog(@"Did receive Bytes %qu of %qu", loadedBytes, totalBytes);
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
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
	if (status == SCAuthenticationStatusAuthenticated) {
		// authenticated
		[sendRequestButton setEnabled:YES];
		// not the most elegant way to enable/disable the ui
		// but this is up to you (the developer of apps) to prove your cocoa skills :)
		[postTestButton setEnabled:YES];
	} else {
		[sendRequestButton setEnabled:NO];
		[postTestButton setEnabled:NO];
	}
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)_scAPI didEncounterError:(NSError *)error;
{
	if ([[error domain] isEqualToString:SCAPIErrorDomain]) {
		if ([error code] == SCAPIErrorHttpResponseError) {
			NSError *httpError = [[error userInfo] objectForKey:SCAPIHttpResponseErrorStatusKey];
			if (httpError.code == NSURLErrorNotConnectedToInternet) {
				// inform the user and offer him to retry
				[sendRequestButton setTitle:@"No internet"];
				[postTestButton setTitle:@"No internet"];
			}
		} else if ([error code] == SCAPIErrorNotAuthenticted) {
			[_scAPI requestAuthentication];
		}
	}
}

@end
