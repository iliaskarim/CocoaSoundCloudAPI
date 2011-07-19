//
//  SCLoginViewController.m
//  SCTestApp
//
//  Created by Gernot Poetsch on 16.09.10.
//  Copyright 2010 Gernot Poetsch. All rights reserved.
//

#if TARGET_OS_IPHONE

#import "SCSoundCloudAPIAuthentication.h"
#import "SCSoundCloudAPIConfiguration.h"

#import "SCLoginViewController.h"
#import "SCSoundCloud.h"
#import "SCConstants.h"

@interface SCLoginTitleBar: UIView {
}
@end

@interface SCLoginSectionBar : UIControl {
}
@end


@interface SCLoginViewController ()
- (void)sectionAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (IBAction)didSelectSectionbar:(SCLoginSectionBar *)sectionBar;
@end

#pragma mark -

@implementation SCLoginViewController


#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)anURL authentication:(SCSoundCloudAPIAuthentication *)anAuthentication;
{
    if (!anURL) return nil;
    
    if (self = [super init]) {
        
        numberOfSections = 1;
        currentSection = 0;
		
		showReloadButton = NO;
        
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
	[titleBarButton release];
    [resourceBundle release];
    [titleBarView release];
    [authentication release];
    [activityIndicator release];
    [URL release];
    [webViews release];
    [sectionBars release];
    [super dealloc];
}


#pragma mark Accessors

@synthesize showReloadButton;

- (void)setShowReloadButton:(BOOL)value;
{
	showReloadButton = value;
	[self updateInterface:NO];
}


#pragma mark UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    titleBarView = [[SCLoginTitleBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 28.0)];
    titleBarView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:titleBarView];
    
    CGRect logoRect;
    CGRect connectRect;
    CGRect closeRect;
    CGRectDivide(titleBarView.bounds, &logoRect, &connectRect, 45.0, CGRectMinXEdge);
    CGRectDivide(connectRect, &closeRect, &connectRect, connectRect.size.height, CGRectMaxXEdge);
    
    logoRect.origin.x += 6.0;
    logoRect.origin.y += 4.0;
    connectRect.origin.y += 9.0;
    
    UIImageView *cloudImageView = [[UIImageView alloc] initWithFrame:logoRect];
    UIImage *cloudImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"cloud" ofType:@"png"]];
    cloudImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    cloudImageView.image = cloudImage;
    [cloudImageView sizeToFit];
    [titleBarView addSubview:cloudImageView];
    [cloudImageView release];
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:connectRect];
    UIImage *titleImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"cwsc" ofType:@"png"]];
    titleImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    titleImageView.image = titleImage;
    [titleImageView sizeToFit];
    [titleBarView addSubview:titleImageView];
    [titleImageView release];
    
	titleBarButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	titleBarButton.frame = closeRect;
	titleBarButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
	titleBarButton.showsTouchWhenHighlighted = YES;
	[titleBarButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	UIImage *closeImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"close" ofType:@"png"]];
	[titleBarButton setImage:closeImage forState:UIControlStateNormal];
	titleBarButton.imageView.contentMode = UIViewContentModeCenter;
	[titleBarView addSubview:titleBarButton];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin);
	activityIndicator.hidesWhenStopped = YES;
	[self.view addSubview:activityIndicator];
	
    NSMutableArray *mutableWebViews = [NSMutableArray arrayWithCapacity:numberOfSections];
    NSMutableArray *mutableSectionBars = [NSMutableArray arrayWithCapacity:numberOfSections];
    for (int section = 0; section < numberOfSections; section++) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        webView.backgroundColor = nil;
        webView.opaque = NO;
        webView.delegate = self;
        [mutableWebViews addObject:webView];
        if (section == 0) {
            [webView loadRequest:[NSURLRequest requestWithURL:URL]];
        } else {
            [webView loadHTMLString:@"<body height=100%><h1>Test</h1>This is just some test content</body>" baseURL:nil];
        }

        [webView release];
        
        SCLoginSectionBar *bar = [[SCLoginSectionBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 28.0)];
        [bar addTarget:self action:@selector(didSelectSectionbar:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bar];
        [mutableSectionBars addObject:bar];
        [bar release];
    }
    [webViews release]; webViews = [mutableWebViews retain];
    [sectionBars release]; sectionBars = [mutableSectionBars retain];
    
    [self updateInterface:NO];
}

- (void)viewDidUnload;
{
    [titleBarView release]; titleBarView = nil;
    [activityIndicator release]; activityIndicator = nil;
    [webViews release]; webViews = nil;
    [sectionBars release]; sectionBars = nil;
}

- (void)updateInterface:(BOOL)animated;
{
    CGFloat barHeight = 28.0;
    
    CGRect contentRect;
    
    CGRect titleBarRect;
    CGRectDivide(self.view.bounds, &titleBarRect, &contentRect, 27.0, CGRectMinYEdge);
    titleBarView.frame = titleBarRect;
    
    if (animated) {
        [UIView beginAnimations:@"sectionAnimation" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(sectionAnimationDidStop:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
    }
        
    for (int section = 0; section < numberOfSections; section++) {
        SCLoginSectionBar *bar = [sectionBars objectAtIndex:section];
        UIWebView *webView = [webViews objectAtIndex:section];
        
        if (section == currentSection) {
            bar.frame = CGRectMake(contentRect.origin.x,
                                 contentRect.origin.y + section * barHeight,
                                 contentRect.size.width,
                                 barHeight);
            bar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
            webView.frame = CGRectMake(contentRect.origin.x,
                                       contentRect.origin.y + section * barHeight,
                                       contentRect.size.width,
                                       contentRect.size.height - (numberOfSections-1) * barHeight);
            webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            [self.view insertSubview:webView belowSubview:bar];
            //activityIndicator.center = CGPointMake(CGRectGetMidX(webView.bounds), CGRectGetMidY(webView.bounds));
            if (webView.loading) {
                [activityIndicator startAnimating];
            } else {
                [activityIndicator stopAnimating];
            }
            //[webView addSubview:activityIndicator];
            
            if (!animated)[bar removeFromSuperview];
            bar.alpha = 0.0;
        } else {
            if (section < currentSection) {
                bar.frame = CGRectMake(contentRect.origin.x,
                                       contentRect.origin.y + section * barHeight,
                                       contentRect.size.width,
                                       barHeight);
                bar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
            } else {
                bar.frame = CGRectMake(contentRect.origin.x,
                                       CGRectGetMaxY(contentRect) - (numberOfSections-section)*barHeight,
                                       contentRect.size.width,
                                       barHeight);
                bar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
            }
            webView.frame = bar.frame;
            webView.autoresizingMask = bar.autoresizingMask;
            [self.view insertSubview:bar aboveSubview:webView];
            bar.alpha = 1.0;
            if (!animated)[webView removeFromSuperview];
        }
        bar.userInteractionEnabled = !animated; //We don't want no userInteraction during the animation
    }
	
	[titleBarButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	if (!showReloadButton) {
		[titleBarButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
		UIImage *closeImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"close" ofType:@"png"]];
		[titleBarButton setImage:closeImage forState:UIControlStateNormal];
	} else {
		[titleBarButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
		UIImage *reloadImage = [UIImage imageWithContentsOfFile:[resourceBundle pathForResource:@"reload" ofType:@"png"]];
		[titleBarButton setImage:reloadImage forState:UIControlStateNormal];
	}
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)sectionAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    for (int section = 0; section < numberOfSections; section++) {
        SCLoginSectionBar *bar = [sectionBars objectAtIndex:section];
        UIWebView *webView = [webViews objectAtIndex:section];
        
        if (section == currentSection) {
            [bar removeFromSuperview];
        } else {
            [webView removeFromSuperview];
        }
        bar.userInteractionEnabled = YES;
    }
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    if (webView == [webViews objectAtIndex:currentSection]) {
        [activityIndicator startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    if (webView == [webViews objectAtIndex:currentSection]) {
        [activityIndicator stopAnimating];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    // Use either the authentication delegate if present
    // or the shared sound cloud singleton (SCSoundCLoud).
    
    if (![request.URL isEqual:URL]) {
		BOOL hasBeenHandled = NO;
		        
        NSURL *callbackURL = authentication.configuration.callbackURL;
        
        if ([[request.URL absoluteString] hasPrefix:[callbackURL absoluteString]]) {
            
            if (authentication) {
                hasBeenHandled = [authentication handleRedirectURL:request.URL];
            } else {
                hasBeenHandled = [[SCSoundCloud shared] handleRedirectURL:request.URL];
            }
            

            if (hasBeenHandled) {
                [self close];
            }
            return NO;
        }
	}
    
    NSURL *authURL = nil;
    if (authentication) {
        authURL = authentication.configuration.authURL;
    } else {
        authURL = [[[SCSoundCloud shared] configuration] objectForKey:kSCConfigurationAuthorizeURL];
    }
    
    if (![[request.URL absoluteString] hasPrefix:[authURL absoluteString]]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
	
	return YES;
}

#pragma mark Private

- (IBAction)close;
{
    // Use either the authentication delegate if present
    // or the shared sound cloud singleton (SCSoundCLoud).
    
    if (authentication) {
        [authentication performSelector:@selector(dismissLoginViewController:) withObject:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)reload;
{
	for (UIWebView *webView in webViews) {
		[webView reload];
	}
}

- (IBAction)didSelectSectionbar:(SCLoginSectionBar *)sectionBar;
{
    currentSection = [sectionBars indexOfObject:sectionBar];
    [self updateInterface:YES];
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

@implementation SCLoginSectionBar

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
                                                                 (CGFloat[]){0.40,0.40,0.40,1.0,  0.33,0.33,0.33,1.0},
                                                                 (CGFloat[]){0.0, 1.0},
                                                                 2);
    CGContextDrawLinearGradient(context, gradient, gradientRect.origin, CGPointMake(gradientRect.origin.x, CGRectGetMaxY(gradientRect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetFillColor(context, (CGFloat[]){0.20,0.20,0.20,1.0});
    CGContextFillRect(context, topLineRect);
    
    CGContextSetFillColor(context, (CGFloat[]){0.20,0.20,0.20,1.0});
    CGContextFillRect(context, bottomLineRect);
}

@end


#endif
