//
//  GPCellLoader.h
//  SoundCloud
//
//  Created by Gernot Poetsch on 16.02.09.
//  Copyright 2009 Gernot Poetsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GPCellLoader : NSObject {
	
	NSArray *nib;
	
	IBOutlet UITableViewCell *cell; //not retaines, because included in nib;
}

- (id)initWithNibNamed:(NSString *)nibName;

- (UITableViewCell *)cell;

@end
