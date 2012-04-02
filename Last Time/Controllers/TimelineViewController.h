//
//  TimelineViewController.h
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineViewController : UITableViewController

@property (nonatomic, strong) UIViewController * managingViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController;

@end
