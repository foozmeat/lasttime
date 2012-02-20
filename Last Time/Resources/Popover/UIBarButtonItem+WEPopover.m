/*
 *  UIBarButtonItem+WEPopover.m
 *  WEPopover
 *
 *  Created by Werner Altewischer on 07/05/11.
 *  Copyright 2010 Werner IT Consultancy. All rights reserved.
 *
 */

#import "UIBarButtonItem+WEPopover.h" 

@implementation UIBarButtonItem(WEPopover)

- (CGRect)frameInView:(UIView *)v {
	
	BOOL hasCustomView = (self.customView != nil);
	
	if (!hasCustomView) {
		UIView *tempView = [[UIView alloc] initWithFrame:CGRectZero];
		self.customView = tempView;
	}
	
	UIView *parentView = self.customView.superview;
	NSUInteger indexOfView = [parentView.subviews indexOfObject:self.customView];
	
	UIView *button = [parentView.subviews objectAtIndex:indexOfView];
	if (!hasCustomView) {
		self.customView = nil;
	}
	return [parentView convertRect:button.frame toView:v];
}

- (UIView *)superview {
	
	BOOL hasCustomView = (self.customView != nil);
	
	if (!hasCustomView) {
		UIView *tempView = [[UIView alloc] initWithFrame:CGRectZero];
		self.customView = tempView;
	}
	
	UIView *parentView = self.customView.superview;
	
	if (!hasCustomView) {
		self.customView = nil;
	}
	return parentView;
}

@end
