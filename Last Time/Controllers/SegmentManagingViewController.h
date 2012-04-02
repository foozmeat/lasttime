//
//  SegmentManagingViewController.h
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventController;

@interface SegmentManagingViewController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, strong, readonly) UIViewController *activeViewController;
@property (nonatomic, strong, readonly) NSArray *segmentedViewControllers;
@property (strong, nonatomic) EventController *detailViewController;

- (void)didChangeSegmentControl:(UISegmentedControl *)control;
- (NSArray *)segmentedViewControllerContent;


@end
