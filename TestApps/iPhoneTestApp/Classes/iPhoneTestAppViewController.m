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

#import "iPhoneTestAppViewController.h"
#import "iPhoneTestAppAppDelegate.h"

#import "JSON.h"

@interface iPhoneTestAppViewController(private)
-(void)commonAwake;
-(void)requestUserInfo;
-(void)updateUserInfoFromData:(NSData *)data;
@end

@implementation iPhoneTestAppViewController

#pragma mark Lifecycle

-(id)init;
{
	if (self = [super init]) {
		[self commonAwake];
	}	
	return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self commonAwake];
	}
	return self;
}

-(void)viewDidLoad;
{
	[super viewDidLoad];
	[self commonAwake];
}

-(void)commonAwake;
{
	iPhoneTestAppAppDelegate *appDelegate = (iPhoneTestAppAppDelegate *)[[UIApplication sharedApplication] delegate];
	scAPI = [[SCSoundCloudAPI alloc] initWithAuthenticationDelegate:appDelegate];
	[scAPI setResponseFormat:SCResponseFormatJSON];
	[scAPI setDelegate:self];
	[self requestUserInfo];
}

-(void)dealloc;
{
	[scAPI dealloc];
	[super dealloc];
}

#pragma mark Accessors
@synthesize postButton, trackNameField;
	
#pragma mark Private
- (void)requestUserInfo;
{
	[scAPI performMethod:@"GET" onResource:@"me" withParameters:nil context:@"userInfo"];
}

-(void)updateUserInfoFromData:(NSData *)data;
{
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	SBJSON *json = [[SBJSON alloc] init];
	NSError *error;
	id object = [json objectWithString:dataString error:&error];
	[dataString release];
	[json release];
	if(object) {
		if([object isKindOfClass:[NSDictionary class]]) {
			NSDictionary *userInfoDictionary = (NSDictionary *)object;
			[usernameLabel setText:[userInfoDictionary objectForKey:@"username"]];
			[trackNumberLabel setText:[userInfoDictionary objectForKey:@"track_count"]];
		}
	} else {
		NSLog(@"Error: %@", [error localizedDescription]);
	}
}


#pragma mark Actions

-(IBAction)sendRequest:(id)sender;
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[trackNameField text] forKey:@"track[title]"];
	[parameters setObject:@"private" forKey:@"track[sharing]"];
	
	// sample from http://www.freesound.org/samplesViewSingle.php?id=1375
	NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"wav"];
	NSURL *dataURL = [NSURL fileURLWithPath:dataPath];
	[parameters setObject:dataURL forKey:@"track[asset_data]"];
	
	[progresBar setProgress:0];
	[scAPI performMethod:@"POST" onResource:@"tracks" withParameters:parameters context:@"upload"];
}

-(void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Release anything that's not essential, such as cached data
}


#pragma mark SCSoundCloudAPIDelegate
-(void)soundCloudAPI:(SCSoundCloudAPI *)api didFinishWithData:(NSData *)data context:(id)context;
{
	if([context isEqualToString:@"userInfo"]) {
		[self updateUserInfoFromData:data];
	}
	if([context isEqualToString:@"upload"]) {
		[self requestUserInfo];
	}
}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didFailWithError:(NSError *)error context:(id)context;
{}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveData:(NSData *)data context:(id)context;
{}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didReceiveBytes:(UInt32)loadedBytes total:(UInt32)totalBytes context:(id)context;
{}

-(void)soundCloudAPI:(SCSoundCloudAPI *)api didSendBytes:(UInt32)sendBytes total:(UInt32)totalBytes context:(id)context;
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
