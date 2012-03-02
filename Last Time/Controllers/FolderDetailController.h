//
//  FolderDetailController.h
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"

@class EditableTableCell;
@class EventFolder;

enum {
	FolderName = 0
};

@interface FolderDetailController : CustomTableViewController

@property (strong, nonatomic) EventFolder *theNewFolder;

@end
