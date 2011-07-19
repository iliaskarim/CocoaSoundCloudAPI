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

#import "JSONKit.h"

#import "iPhoneTestAppViewController.h"
#import "iPhoneTestAppAppDelegate.h"

#import "SCSoundCloudAPI+TestApp.h"


@interface iPhoneTestAppViewController(private)
-(void)commonAwake;
-(void)updateUserInfoFromData:(NSData *)data;
@end


@implementation iPhoneTestAppViewController


#pragma mark Lifecycle

- (void)awakeFromNib;
{
    [super awakeFromNib];
    if ([[[SCSoundCloud shared] accounts] count] > 0) {
        
        
        SCAccount *account = [[[SCSoundCloud shared] accounts] objectAtIndex:0];
        
        
        
        [account fetchUserInfoWithCompletionHandler:^(BOOL success, SCAccount *account, NSError *error){
            NSDictionary *userData = account.userInfo;
            [self.usernameLabel setText:[userData objectForKey:@"username"]];
            [self.trackNumberLabel setText:[NSString stringWithFormat:@"%d", [[userData objectForKey:@"private_tracks_count"] integerValue]]];
            
            self.trackNameField.enabled = YES;
            self.postButton.enabled = YES;
        }];
        
        [SCRequest performMethod:@"GET" onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/tracks.json"] usingParameters:nil withAccount:account responseHandler:^(NSData *data, NSError *error){
            if (data) {
                NSError *jsonError = nil;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (result) {
                    NSLog(@"tracks: %@", result);
                } else {
                    NSLog(@"tracks: ??? json error: %@", [jsonError localizedDescription]);
                }
            } else {
                NSLog(@"tracks: ??? error: %@", [error localizedDescription]);
            }
        }];
    }
}


- (void)dealloc;
{ 
	[uploadConnectionId release];
	[super dealloc];
}


#pragma mark Accessors

@synthesize postButton, trackNameField;
@synthesize progresBar;

@synthesize usernameLabel;
@synthesize trackNumberLabel;


#pragma mark Actions

-(IBAction)sendRequest:(id)sender;
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"wav"];
    NSURL *dataURL = [NSURL fileURLWithPath:dataPath];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setObject:[trackNameField text] forKey:@"track[title]"];
	[parameters setObject:@"private" forKey:@"track[sharing]"];
	[parameters setObject:dataURL forKey:@"track[asset_data]"];
    
    self.progresBar.progress = 0.0;
    if ([[[SCSoundCloud shared] accounts] count] > 0) {
        SCAccount *account = [[[SCSoundCloud shared] accounts] objectAtIndex:0];
        
        [SCRequest performMethod:@"POST"
                      onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks"]
                 usingParameters:parameters withAccount:account
             sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal){self.progresBar.progress = ((float)bytesSend)/bytesTotal;}
                 responseHandler:^(NSData *data, NSError *error){
                     if (data) {
                         self.progresBar.progress = 0.0;
                         [account fetchUserInfoWithCompletionHandler:^(BOOL success, SCAccount *account, NSError *error){
                             if (success) {
                                 NSDictionary *userData = account.userInfo;
                                 [self.usernameLabel setText:[userData objectForKey:@"username"]];
                                 [self.trackNumberLabel setText:[NSString stringWithFormat:@"%d", [[userData objectForKey:@"private_tracks_count"] integerValue]]];
                             }
                         }];
                     }
                 }];
    }
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

@end
