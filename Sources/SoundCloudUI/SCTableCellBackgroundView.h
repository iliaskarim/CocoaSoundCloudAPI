//
//  GPTableCellBackgroundView.h
//  MANIAA
//
//  Created by Ullrich Schäfer on 03.08.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum  {
	GPTableCellBackgroundViewPositionTop, 
	GPTableCellBackgroundViewPositionMiddle, 
	GPTableCellBackgroundViewPositionBottom,
	GPTableCellBackgroundViewPositionSingle
} GPTableCellBackgroundViewPosition;


@interface SCTableCellBackgroundView : UIView {
	UIColor *borderColor;
    UIColor *backgroundColor;
	GPTableCellBackgroundViewPosition position;
}

@property(nonatomic, retain) UIColor *borderColor;
@property(nonatomic) GPTableCellBackgroundViewPosition position;

@end

@interface UITableView (GPTableCellBackgroundViewAdditions)
- (GPTableCellBackgroundViewPosition)cellPositionForIndexPath:(NSIndexPath *)indexPath;
@end

