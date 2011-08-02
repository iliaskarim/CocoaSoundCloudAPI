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
#import "iPhoneTestAppDelegate.h"


@interface iPhoneTestAppViewController(private)
-(void)commonAwake;
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
    self.postButton.enabled = YES;
}

#pragma mark Accessors

@synthesize postButton;


#pragma mark Actions

-(IBAction)sendRequest:(id)sender;
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"1375_sleep_90_bpm_nylon2" ofType:@"wav"];
    NSURL *dataURL = [NSURL fileURLWithPath:dataPath];
    
    SCShareViewController *shareView = [SCShareViewController shareViewControllerWithFileURL:dataURL
                                                                           completionHandler:^(BOOL canceled, NSDictionary *trackInfo){
        if (canceled) {
            NSLog(@"Sharing sound with Soundcloud canceled.");
        } else {
            NSLog(@"Uploaded track: %@", trackInfo);
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }];
    [shareView setTitle:@"Foo Bar!"];
    [self presentModalViewController:shareView animated:YES];
}

@end
