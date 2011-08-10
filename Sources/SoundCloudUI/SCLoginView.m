//
//  SCLoginView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 05.08.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCSoundCloud.h"
#import "SCSoundCloud+Private.h"
#import "SCConstants.h"
#import "SCBundle.h"

#import "SCLoginView.h"


@interface SCLoginView () <UIWebViewDelegate>
@property (nonatomic, readwrite, assign) UIWebView *webView;
@property (nonatomic, readwrite, assign) UIActivityIndicatorView *activityIndicator;
- (void)commonAwake;
@end

@implementation SCLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonAwake];
    }
    return self;
}

- (void)commonAwake;
{    
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	self.activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin);
	self.activityIndicator.hidesWhenStopped = YES;
	[self addSubview:self.activityIndicator];
 
    self.webView = [[[UIWebView alloc] initWithFrame:self.bounds] autorelease];
    self.webView.delegate = self;
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.webView.backgroundColor = nil;
    self.webView.opaque = NO;
    [self addSubview:self.webView];
    
    self.backgroundColor = [UIColor colorWithPatternImage:[SCBundle imageFromPNGWithName:@"darkTexturedBackgroundPattern"]];
}

- (void)dealloc;
{
    [super dealloc];
}

#pragma mark View

- (void)layoutSubviews;
{
    self.webView.frame = self.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark Accessors

@synthesize delegate;
@synthesize webView;
@synthesize activityIndicator;

- (void)loadURL:(NSURL *)anURL;
{
    NSURL *URLToOpen = [NSURL URLWithString:[[anURL absoluteString] stringByAppendingString:@"&display_bar=false"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URLToOpen]];
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [self.activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *callbackURL = [[SCSoundCloud configuration] objectForKey:kSCConfigurationRedirectURL];
        
    if ([[request.URL absoluteString] hasPrefix:[callbackURL absoluteString]]) {
        return [SCSoundCloud handleRedirectURL:request.URL];
    }
    
    NSURL *authURL = [[SCSoundCloud configuration] objectForKey:kSCConfigurationAuthorizeURL];

    if (![[request.URL absoluteString] hasPrefix:[authURL absoluteString]]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    if ([[error domain] isEqualToString:NSURLErrorDomain]) {
        
        if ([error code] == NSURLErrorCancelled)
            return;
        
    } else if ([[error domain] isEqualToString:@"WebKitErrorDomain"]) {
        
        if ([error code] == 101)
            return;
        
        if ([error code] == 102)
            return;
    }
    
    if ([self.delegate respondsToSelector:@selector(loginView:didFailWithError:)]) {
        [self.delegate loginView:self didFailWithError:error];
    }
}

@end
