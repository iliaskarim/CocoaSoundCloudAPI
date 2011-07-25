//
//  SCShareViewController.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 25.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SCSharingViewControllerComletionHandler)(BOOL canceled, NSDictionary *trackInfo);

@class CLLocation;
@class SCAccount;

@interface SCShareViewController : UINavigationController

#pragma mark Class methods

+ (SCShareViewController *)shareViewControllerWithFileURL:(NSURL *)aFileURL completionHandler:(SCSharingViewControllerComletionHandler)aCompletionHandler;
+ (SCShareViewController *)shareViewControllerWithFileData:(NSData *)someData completionHandler:(SCSharingViewControllerComletionHandler)aCompletionHandler;

#pragma mark Accessors

- (void)setAccount:(SCAccount *)anAccount;
- (void)setPrivate:(BOOL)isPrivate;
- (void)setCoverImage:(UIImage *)aCoverImage;
- (void)setTitle:(NSString *)aTitle;

@end
