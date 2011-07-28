//
//  SCRecordingSaveViewControllerHeaderView.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 27.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRecordingSaveViewControllerHeaderView : UIView

#pragma mark Accessors

@property (nonatomic, readonly, assign) UIButton *logoutButton;
@property (nonatomic, readonly, assign) UIButton *coverImageButton;
@property (nonatomic, readonly, assign) UIButton *disclosureButton;

@property (nonatomic, readonly, assign) SCSwitch *privateSwitch;

@property (nonatomic, readonly, assign) UITextField *whatTextField;
@property (nonatomic, readonly, assign) UITextField *whereTextField;

- (void)setAvatarImage:(UIImage *)anImage;
- (void)setUserName:(NSString *)aUserName;
- (void)setCoverImage:(UIImage *)aCoverImage;

@end
