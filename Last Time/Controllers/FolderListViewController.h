//
//  FolderViewController.h
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEPopoverController.h"

@interface FolderListViewController : UIViewController 
<UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, WEPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *folderTableView;
@property (nonatomic, strong) WEPopoverController *addPopover;


- (void)addNewItem:(id)sender;
- (void)showAddPopup;

@end
