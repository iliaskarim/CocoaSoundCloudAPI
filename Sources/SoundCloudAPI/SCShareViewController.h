//
//  SCShareViewController.h
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCSoundCloudAPIAuthentication;

@interface SCShareViewController : UIViewController {
@private
    NSData *sound;
    
}

- (id)initWithSound:(NSData *)sound authentication:(SCSoundCloudAPIAuthentication *)authentication;

@end
