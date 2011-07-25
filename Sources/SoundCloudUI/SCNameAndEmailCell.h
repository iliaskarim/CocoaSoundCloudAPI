//
//  SCNameAndEmailCell.h
//  Soundcloud
//
//  Created by Ullrich Schäfer on 18.09.09.
//  Copyright 2009 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCCell.h"


@interface SCNameAndEmailCell : UITableViewCell {
@protected	
	IBOutlet UILabel	*nameLabel;
	IBOutlet UILabel	*emailLabel;
	IBOutlet UILabel	*mailTypeLabel;
}
@property (retain) NSString *name;
@property (retain) NSString *email;
@property (retain) NSString *mailType;

@end
