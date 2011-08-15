//
//  SCRecordingUploadProgressView.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 29.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRecordingUploadProgressView : UIView
@property (nonatomic, readonly, assign) UIProgressView *progressView;
@property (nonatomic, readonly, assign) UIButton *cancelButton;

- (void)setTitle:(NSString *)aTitle;
- (void)setCoverImage:(UIImage *)aCoverImage;
- (void)setSuccess:(BOOL)success;

@end
