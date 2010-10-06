//
//  SCLoginViewController.h
//  SCTestApp
//
//  Created by Gernot Poetsch on 16.09.10.
//  Copyright 2010 Gernot Poetsch. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SCSoundCloudAPIAuthentication;

@interface SCLoginViewController : UIViewController <UIWebViewDelegate> {
    SCSoundCloudAPIAuthentication *authentication;
    NSURL *URL;
    NSArray *webViews;
    NSArray *sectionBars;
    UIActivityIndicatorView *activityIndicator;
    UIView *titleBarView;
    NSBundle *resourceBundle;
    
    NSInteger numberOfSections;
    NSInteger currentSection;
}

- (id)initWithURL:(NSURL *)anURL authentication:(SCSoundCloudAPIAuthentication *)authentication;

- (void)updateInterface:(BOOL)animated;

@end

#endif
