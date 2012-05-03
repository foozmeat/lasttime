//
//  EventListViewController.h
//  Last Time
//
//  Created by James Moore on 2/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"

@class EventController;

@interface EventListViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, ItemDetailViewControllerDelegate,NSFetchedResultsControllerDelegate>
{
	bool userDrivenDataModelChange;

}
@property (nonatomic, strong) EventFolder *folder;
@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) EventController *detailViewController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


- (IBAction)addNewEvent:(id)sender;
//- (void)showAddPopup;

@end
