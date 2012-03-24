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
	NSFetchedResultsController *_fetchedResultsController;

}
@property (strong, nonatomic) EventController *detailViewController;
@property (strong, nonatomic) FolderListCell *activeCell;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end
