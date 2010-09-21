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

@interface SCLoginTitleBar: UIView {
}
@end

@interface SCLoginContentBar : UIView {
}
@end

@interface SCLoginViewController ()
- (void)close;
@end

#pragma mark -

@implementation SCLoginViewController


#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)anURL authentication:(SCSoundCloudAPIAuthentication *)anAuthentication;
{
    if (!anURL) return nil;
    
    if (self = [super init]) {
        
        if ([self respondsToSelector:@selector(setModalPresentationStyle:)]){
            [self setModalPresentationStyle:UIModalPresentationFormSheet];
        }
                
        authentication = [anAuthentication retain];
        URL = [anURL retain];
        resourceBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"SoundCloud" ofType:@"bundle"]];
        NSAssert(resourceBundle, @"Please move the SoundCloud.bundle into the Resource Directory of your Application!");
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
    [resourceBundle release];
    [titleBarView release];
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
    
    CGRect contentRect;
    CGRect titleBarRect;
    CGRectDivide(self.view.bounds, &titleBarRect, &contentRect, 27.0, CGRectMinYEdge);
    
    titleBarView = [[SCLoginTitleBar alloc] initWithFrame:titleBarRect];
    titleBarView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:titleBarView];
    
    CGRect logoRect;
    CGRect connectRect;
    CGRect closeRect;
    CGRectDivide(titleBarView.bounds, &logoRect, &connectRect, 40.0, CGRectMinXEdge);
    CGRectDivide(connectRect, &closeRect, &connectRect, 27.0, CGRectMaxXEdge);
    
    UIImageView *cloudImageView = [[UIImageView alloc] initWithFrame:logoRect];
    UIImage *cloudImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"cloud" ofType:@"png"]];
    cloudImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    cloudImageView.image = cloudImage;
    cloudImageView.contentMode = UIViewContentModeCenter;
    [titleBarView addSubview:cloudImageView];
    [cloudImageView release];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = closeRect;
    closeButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UIImage *closeImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"close" ofType:@"png"]];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.imageView.contentMode = UIViewContentModeCenter;
    [titleBarView addSubview:closeButton];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    
    webView = [[UIWebView alloc] initWithFrame:contentRect];
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


#pragma mark -

@implementation SCLoginTitleBar

- (void)drawRect:(CGRect)rect;
{
    CGRect topLineRect;
    CGRect gradientRect;
    CGRect bottomLineRect;
    CGRectDivide(self.bounds, &topLineRect, &gradientRect, 0.0, CGRectMinYEdge);
    CGRectDivide(gradientRect, &bottomLineRect, &gradientRect, 1.0, CGRectMaxYEdge);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 (CGFloat[]){1.0,0.40,0.0,1.0,  1.0,0.21,0.0,1.0},
                                                                 (CGFloat[]){0.0, 1.0},
                                                                 2);
    CGContextDrawLinearGradient(context, gradient, gradientRect.origin, CGPointMake(gradientRect.origin.x, CGRectGetMaxY(gradientRect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetFillColor(context, (CGFloat[]){0.0,0.0,0.0,1.0});
    CGContextFillRect(context, topLineRect);
    
    CGContextSetFillColor(context, (CGFloat[]){0.52,0.53,0.54,1.0});
    CGContextFillRect(context, bottomLineRect);
}

@end


#pragma mark -

@implementation SCLoginContentBar

@end


#endif
