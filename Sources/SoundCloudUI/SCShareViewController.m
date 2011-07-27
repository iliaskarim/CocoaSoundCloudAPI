//
//  SCShareViewController.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 25.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//


#import "SCRecordingSaveViewController.h"


#import "SCShareViewController.h"

@interface SCShareViewController ()
- (SCRecordingSaveViewController *)recordSaveController;
@end


@implementation SCShareViewController

#pragma mark Class methods

+ (SCShareViewController *)shareViewControllerWithFileURL:(NSURL *)aFileURL
                                        completionHandler:(SCSharingViewControllerComletionHandler)aCompletionHandler;
{
    SCRecordingSaveViewController *recView = [[SCRecordingSaveViewController new] autorelease];
    if (!recView) return nil;
    
    [recView setFileURL:aFileURL];
    [recView setCompletionHandler:aCompletionHandler];
    
    SCShareViewController *shareViewController = [[SCShareViewController alloc] initWithRootViewController:recView];
    if (shareViewController) {
        shareViewController.navigationBarHidden = YES;
    }
    return [shareViewController autorelease];
}

+ (SCShareViewController *)shareViewControllerWithFileData:(NSData *)someData
                                         completionHandler:(SCSharingViewControllerComletionHandler)aCompletionHandler;
{
    SCRecordingSaveViewController *recView = [[SCRecordingSaveViewController new] autorelease];
    if (!recView) return nil;
    
    [recView setFileData:someData];
    [recView setCompletionHandler:aCompletionHandler];
    
    SCShareViewController *shareViewController = [[SCShareViewController alloc] initWithRootViewController:recView];
    if (shareViewController) {
        shareViewController.navigationBarHidden = YES;
    }
    return [shareViewController autorelease];
}


#pragma mark Accessors

- (void)setAccount:(SCAccount *)anAccount;
{
    [self.recordSaveController setAccount:anAccount];
}

- (void)setPrivate:(BOOL)isPrivate;
{
    [self.recordSaveController setPrivate:isPrivate];
}

- (void)setCoverImage:(UIImage *)aCoverImage;
{
    [self.recordSaveController setCoverImage:aCoverImage];
}

- (void)setTitle:(NSString *)aTitle;
{
    [self.recordSaveController setTitle:aTitle];
}

- (SCRecordingSaveViewController *)recordSaveController;
{
    return (SCRecordingSaveViewController *)self.topViewController;
}

#pragma mark Foursquare

- (void)setFoursquareClientID:(NSString *)aClientID
                 clientSecret:(NSString *)aClientSecret;
{
    [self.recordSaveController setFoursquareClientID:aClientID
                                        clientSecret:aClientSecret];
}

@end
