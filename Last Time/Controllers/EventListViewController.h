//
//  EventListViewController.h
//  Last Time
//
//  Created by James Moore on 2/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"
#import "CustomTableViewController.h"

@interface EventListViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, WEPopoverControllerDelegate, ItemDetailViewControllerDelegate>

@property (nonatomic, strong) EventFolder *folder;
@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (nonatomic, strong) WEPopoverController *addPopover;


- (IBAction)addNewEvent:(id)sender;
- (void)showAddPopup;

@end
