//
//  UIView+SoundCloudAPI.h
//
//  Created by Ullrich Schäfer on 28.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIView (SoundCloudAPI)

- (void)resignFirstResponderOfAllSubviews;
- (UIView *)firstResponderFromSubviews;

- (UIScrollView *)enclosingScrollView;

@end
