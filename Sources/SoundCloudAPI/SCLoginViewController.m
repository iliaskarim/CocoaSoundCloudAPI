//
//  SCLoginViewController.m
//  SCTestApp
//
//  Created by Gernot Poetsch on 16.09.10.
//  Copyright 2010 Gernot Poetsch. All rights reserved.
//

#if TARGET_OS_IPHONE

#import "SCSoundCloudAPIAuthentication.h"

#import "SCLoginViewController.h"


@interface SCLoginViewController ()
- (void)close;
@end


@implementation SCLoginViewController


#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)anURL authentication:(SCSoundCloudAPIAuthentication *)anAuthentication;
{
    if (!anURL) return nil;
    
    if (self = [super init]) {
        authentication = [anAuthentication retain];
        URL = [anURL retain];
        self.title = @"SoundCloud";
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(close)] autorelease];
        
        
    }
    return self;
}

- (void)dealloc;
{
    [authentication release];
    [activityIndicator release];
    [URL release];
    [webView autorelease];
    [super dealloc];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.backgroundColor = nil;
    webView.opaque = NO;
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if (![request.URL isEqual:URL]) {
        BOOL hasBeenHandled = [authentication handleRedirectURL:request.URL];
        if (hasBeenHandled) {
            [self close];
            return NO;
        } else {
            return YES;
        }

    }
    
    return YES;
}

#pragma mark Private

- (void)close;
{
    [authentication performSelector:@selector(dismissLoginViewController:) withObject:self];
}

@end

#endif
