//
//  FolderViewController.h
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEPopoverController.h"
#import "CustomTableViewController.h"

@class EventController;
@class FolderListCell;

@interface FolderListViewController : UITableViewController 
<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ItemDetailViewControllerDelegate, NSFetchedResultsControllerDelegate>
{
	bool userDrivenDataModelChange;
	NSIndexPath *newCell;
}
@property (strong, nonatomic) EventController *detailViewController;
@property (strong, nonatomic) FolderListCell *activeCell;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIViewController * managingViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController detailViewController:dViewController;
@end
