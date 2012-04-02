//
//  TimelineViewController.h
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventController;

@interface TimelineViewController : UITableViewController

@property (nonatomic, strong) UIViewController * managingViewController;
@property (strong, nonatomic) EventController *detailViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController detailViewController:dViewController;

@end
