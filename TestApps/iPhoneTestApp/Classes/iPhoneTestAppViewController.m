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
 */

#import "iPhoneTestAppViewController.h"
#import "iPhoneTestAppAppDelegate.h"
#import "iPhoneTestAppSoundCloudController.h"

#import "JSON/JSON.h"


@interface iPhoneTestAppViewController(private)
-(void)commonAwake;
-(void)updateUserInfoFromData:(NSData *)data;
@end


@implementation iPhoneTestAppViewController


#pragma mark Accessors

@synthesize postButton, trackNameField;
	
#pragma mark Private
- (void)requestUserInfo;
{
	[appDelegate.soundCloudController meWithContext:@"userInfo" delegate:self];
}

-(void)updateUserInfoFromData:(NSData *)data;
{
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	id object = [dataString JSONValue];
	[dataString release];
	if([object isKindOfClass:[NSDictionary class]]) {
		NSDictionary *userInfoDictionary = (NSDictionary *)object;
		[usernameLabel setText:[userInfoDictionary objectForKey:@"username"]];
		[trackNumberLabel setText:[NSString stringWithFormat:@"%d", [[userInfoDictionary objectForKey:@"private_tracks_count"] integerValue]]];
	}
}


#pragma mark Actions

-(IBAction)sendRequest:(id)sender;
{
	// sample from http://www.freesound.org/samplesViewSingle.php?id=1375
	NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"wav"];
	NSURL *dataURL = [NSURL fileURLWithPath:dataPath];
	
	[progresBar setProgress:0];
	[appDelegate.soundCloudController postTrackWithTitle:[trackNameField text]
												 fileURL:dataURL
												isPublic:NO
												 context:@"upload"
												delegate:self];
}

-(void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Release anything that's not essential, such as cached data
}


#pragma mark SCSoundCloudConnectionDelegate

-(void)soundCloudConnection:(SCSoundCloudConnection *)connection didFinishWithData:(NSData *)data context:(id)context;
{
	if([context isEqualToString:@"userInfo"]) {
		[self updateUserInfoFromData:data];
	}
	if([context isEqualToString:@"upload"]) {
		[self requestUserInfo];
	}
}

-(void)soundCloudConnection:(SCSoundCloudConnection *)connection didFailWithError:(NSError *)error context:(id)context;
{
	// check error code. if it's a http error get it from the userdict (see SCAPIErrors.h)
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"Ignore"
										  otherButtonTitles:@"Retry (dummy)", nil];
	[alert show];
	[alert release];
}

-(void)soundCloudConnection:(SCSoundCloudConnection *)connection didReceiveData:(NSData *)data context:(id)context;
{}

-(void)soundCloudConnection:(SCSoundCloudConnection *)connection didReceiveBytes:(unsigned long long)loadedBytes total:(unsigned long long)totalBytes context:(id)context;
{}

-(void)soundCloudConnection:(SCSoundCloudConnection *)connection didSendBytes:(unsigned long long)sendBytes total:(unsigned long long)totalBytes context:(id)context;
{
	if([context isEqual:@"upload"]) {
		[progresBar setProgress: ((float)sendBytes) / totalBytes];
	}
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

@end
