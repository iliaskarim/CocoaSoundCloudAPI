//
//  SCShareViewController.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCShareViewController : UIViewController

@property (nonatomic, retain) NSData *sound;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, retain) UIImage *image;

@end
