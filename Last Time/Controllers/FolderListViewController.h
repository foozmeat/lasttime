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

@interface FolderListViewController : UIViewController 
<UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, ItemDetailViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *folderTableView;
@property (strong, nonatomic) EventController *detailViewController;
@end
