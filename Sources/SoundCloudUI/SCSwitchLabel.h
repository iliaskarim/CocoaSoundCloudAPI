//
//  SCSwitchLabel.h
//  SCSwitch
//
//  Created by Ullrich Schäfer on 22.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SCSwitchLabel : UIView
{
	UILabel *label;
	UIImage	*background;
}
@property (nonatomic,copy) NSString *text;
@property (nonatomic,retain) UIImage *background;

@end

