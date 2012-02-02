//
//  LogEntryViewController.h
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolderViewController : UITableViewController <UIActionSheetDelegate>
{
	EventFolder *rootFolder;
}

@property (nonatomic, strong) EventFolder *rootFolder;

- (IBAction)addNewItem:(id)sender;

@end
