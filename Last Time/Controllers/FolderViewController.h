//
//  LogEntryViewController.h
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventFolder.h"

@interface FolderViewController : UITableViewController
{
	EventFolder *rootFolder;
}

- (IBAction)addNewItem:(id)sender;
- (IBAction)toggleEditingMode:(id)sender;

@end
