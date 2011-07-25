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

#import "SCUI.h"

#import "JSONKit.h"

#import "iPhoneTestAppViewController.h"
#import "iPhoneTestAppDelegate.h"


@interface iPhoneTestAppViewController(private)
-(void)commonAwake;
-(void)updateUserInfoFromData:(NSData *)data;

- (void)updateUserInfo;
- (void)updateTrackNumber;
@end


@implementation iPhoneTestAppViewController


#pragma mark Lifecycle

- (void)awakeFromNib;
{
    [super awakeFromNib];
}


- (void)dealloc;
{ 
	[uploadConnectionId release];
	[super dealloc];
}

- (void)viewDidAppear:(BOOL)animated;
{   
    // Enable upload
    SCAccount *account = appDelegate.scAccount;
    if (account) {
        self.postButton.enabled = YES;
        self.trackNameField.enabled = YES;
    }
    
    [self updateUserInfo];
    [self updateTrackNumber];
}

- (void)updateUserInfo;
{
    SCAccount *account = appDelegate.scAccount;
    if (!account) return;
 
    // Fetch information about this account.
    [SCRequest performMethod:@"GET"
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 if (data) {
                     NSError *jsonError = nil;
                     NSDictionary *result = [data objectFromJSONData]; //[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                     if (result) {
                         self.usernameLabel.text = [result objectForKey:@"username"];
                     } else {
                         NSLog(@"me: ??? json error: %@", [jsonError localizedDescription]);
                     }
                 } else {
                     NSLog(@"me: ??? error: %@", [error localizedDescription]);
                 }
             }];
}

- (void)updateTrackNumber;
{
    SCAccount *account = appDelegate.scAccount;
    if (!account) return;
    
    // Fetch the tack list to get the numer of tracks of this account.
    [SCRequest performMethod:@"GET"
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/tracks.json"]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 if (data) {
                     NSError *jsonError = nil;
                     NSArray *result = [data objectFromJSONData]; //[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                     if (result) {
                         self.trackNumberLabel.text = [NSString stringWithFormat:@"%d", [result count]];
                     } else {
                         NSLog(@"tracks: ??? json error: %@", [jsonError localizedDescription]);
                     }
                 } else {
                     NSLog(@"tracks: ??? error: %@", [error localizedDescription]);
                 }
             }];
}

#pragma mark Accessors

@synthesize postButton, trackNameField;
@synthesize progresBar;

@synthesize usernameLabel;
@synthesize trackNumberLabel;


#pragma mark Actions

-(IBAction)sendRequest:(id)sender;
{
    SCAccount *account = appDelegate.scAccount;
    if (!account) return;
    
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"wav"];
    NSURL *dataURL = [NSURL fileURLWithPath:dataPath];
    
    SCShareViewController *shareView = [SCShareViewController shareViewControllerWithFileURL:dataURL completionHandler:^(BOOL canceled, NSDictionary *trackInfo){
        if (canceled) {
            NSLog(@"Sharing sound with Soundcloud canceled.");
        } else {
            NSLog(@"Uploaded track: %@", trackInfo);
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }];
    [shareView setTitle:@"Foo Bar!"];
    [shareView setAccount:account];
    [self presentModalViewController:shareView animated:YES];
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

@end
