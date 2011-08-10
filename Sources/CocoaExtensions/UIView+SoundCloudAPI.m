//
//  UIView+SoundCloudAPI.m
//
//  Created by Ullrich Schäfer on 28.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIView+SoundCloudAPI.h"


@implementation UIView (SoundCloudAPI)

- (void)resignFirstResponderOfAllSubviews;
{
	[self resignFirstResponder];
	for (UIView *subView in self.subviews) {
		[subView resignFirstResponderOfAllSubviews];
	}
}

- (UIView *)firstResponderFromSubviews;
{
	if ([self isFirstResponder])
		return self;
	for (UIView *subView in self.subviews) {
		UIView *childFirstResponder = [subView firstResponderFromSubviews];
		if (childFirstResponder)
			return childFirstResponder;
	}
	return nil;
}

- (UIScrollView *)enclosingScrollView;
{
	UIView *superView = self.superview;
	if (superView) {
		if ([superView isKindOfClass:[UIScrollView class]]) {
			return (UIScrollView *)superView;
		} else {
			return superView.enclosingScrollView;
		}
	}
	return nil;
}

@end
