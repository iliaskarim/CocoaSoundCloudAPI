//
//  SCLoginView.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 05.08.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -

@interface SCLoginView : UIView
@property (nonatomic, assign) id delegate;
- (void)loadURL:(NSURL *)aURL;
@end

@protocol SCLoginViewProtocol <NSObject>
- (void)loginView:(SCLoginView *)aLoginView didFailWithError:(NSError *)anError;
@end
