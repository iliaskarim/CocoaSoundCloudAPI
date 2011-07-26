//
//  SCAddConnectionViewController.m
//  Soundcloud
//
//  Created by Gernot Poetsch on 30.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import "NSData+SCKit.h"

#import "NSString_GPKit.h"
#import "GPNetworkActivityController.h"

//#import "SCAppDelegate.h"
#import "SCSoundCloudAPI.h"
#import "SCAccount.h"
#import "SCRequest.h"

#import "SCAddConnectionViewController.h"

@interface SCAddConnectionViewController ()
@property (nonatomic, retain) NSURL *authorizeURL;
@property (nonatomic, assign) BOOL loading;
@end



@implementation SCAddConnectionViewController

#pragma mark Lifecycle

- (id)initWithService:(NSString *)aService account:(SCAccount *)anAccount delegate:(id<SCAddConnectionViewControllerDelegate>)aDelegate;
{
    if (!aService) return nil;
    
    self = [super init];
    if (self) {
        loading = NO;        
        delegate = aDelegate;
        service = [aService retain];
        account = [anAccount retain];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    service, @"service",
                                    @"x-soundcloud://connection", @"redirect_uri",
                                    @"touch", @"display",
                                    nil];
        
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/connections.json"]
                 usingParameters:parameters
                     withAccount:anAccount
          sendingProgressHandler:nil
                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                     
                     if (data) {
                         
                         id result = [data JSONObject];
                         
                         if (![result isKindOfClass:[NSDictionary class]]) return;
                         
                         NSString *URLString = [result objectForKey:@"authorize_url"];
                         
                         if (URLString) self.authorizeURL = [NSURL URLWithString:URLString];
                         
                     } else {
                         
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed"
                                                                         message:[error localizedDescription]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
                         [alert release];

                     }
                 }];
    }
    return self;
}

- (id)initWithService:(NSString *)aService delegate:(id<SCAddConnectionViewControllerDelegate>)aDelegate;
{
    if (!aService) return nil;
    
    if ((self = [super init])) {
        
        loading = NO;        

        delegate = aDelegate;
        service = [aService retain];
        
//        api = [appDelegate.api copyWithAPIDelegate:self];
//        [api performMethod:@"POST"
//                onResource:@"connections"
//            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                              service, @"service",
//                                                              @"x-soundcloud://connection", @"redirect_uri",
//                                                              @"touch", @"display",
//                                                              nil]
//                   context:nil
//                  userInfo:nil];
    }
    return self;
}

- (void)dealloc;
{
    delegate = nil;
    webView.delegate = nil;
    [authorizeURL release];
    [api release];
    [service release];
    self.loading = NO;
    [super dealloc];
}

#pragma mark Accessors

@synthesize authorizeURL;
@synthesize loading;

- (void)setAuthorizeURL:(NSURL *)value;
{
    //NSLog(@"Authorizing %@", value);
    
    [value retain]; [authorizeURL release]; authorizeURL = value;
    
    if (webView) {
        [webView loadRequest:[NSURLRequest requestWithURL:authorizeURL]];
    }
}

- (void)setLoading:(BOOL)value;
{
    if (loading == value) return;
    
    loading = value;
    
    if (loading) {
        [[GPNetworkActivityController sharedActivityController] increaseNumberOfActiveTransmissions];
    } else {
        [[GPNetworkActivityController sharedActivityController] decreaseNumberOfActiveTransmissions];
    }

}

#pragma mark Views

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    if (self.authorizeURL) {
        [webView loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];
    }
}

- (void)viewDidUnload;
{
    webView.delegate = nil;
    webView = nil;
    [super viewDidUnload];
}


#pragma mark WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if ([request.URL.scheme isEqualToString:@"x-soundcloud"]) {
        
        //NSLog(@"We got an answer! %@", request.URL);
        NSDictionary *parameters = [request.URL.query dictionaryFromQuery];
        
        BOOL success = [[parameters objectForKey:@"success"] isEqualToString:@"1"];
        
        if ([delegate respondsToSelector:@selector(addConnectionController:didFinishWithService:success:)]) {
            [delegate addConnectionController:self
                         didFinishWithService:service
                                      success:success]; //TODO: We have to find out if we were successful
        }
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    self.loading = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    self.loading = NO;
}


#pragma mark API Delegate

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didFinishWithData:(NSData *)data context:(id)context userInfo:(id)userInfo;
{
	id result = [data JSONObject];
    
    if (![result isKindOfClass:[NSDictionary class]]) return;
    
    NSString *URLString = [result objectForKey:@"authorize_url"];
    
    if (URLString) self.authorizeURL = [NSURL URLWithString:URLString];
}

- (void)soundCloudAPI:(SCSoundCloudAPI *)soundCloudAPI didFailWithError:(NSError *)error context:(id)context userInfo:(id)userInfo;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
