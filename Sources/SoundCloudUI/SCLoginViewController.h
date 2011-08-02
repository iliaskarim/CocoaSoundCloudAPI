/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
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

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark Notifications

extern NSString * const SCLoginViewControllerCancelNotification;


@class SCSoundCloudAPIAuthentication;

@interface SCLoginViewController : UIViewController <UIWebViewDelegate> {
    SCSoundCloudAPIAuthentication *authentication;
    NSURL *URL;
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    UIView *titleBarView;
    NSBundle *resourceBundle;
	
	UIButton *titleBarButton;
	BOOL showReloadButton;
}

- (id)initWithURL:(NSURL *)anURL;
- (id)initWithURL:(NSURL *)anURL authentication:(SCSoundCloudAPIAuthentication *)authentication;

/*
 * Replaces the close ('X') button in the top bar with a reload button
 * Default - NO
 */
@property (nonatomic,assign) BOOL showReloadButton;

- (void)updateInterface;

- (IBAction)cancel;
- (IBAction)close;
- (IBAction)reload;

@end

#endif
