//
//  FolderViewController.h
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolderViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
{
	EventFolder *rootFolder;
}

@property (nonatomic, strong) EventFolder *rootFolder;
@property (strong, nonatomic) IBOutlet UITableView *folderTableView;


- (IBAction)addNewItem:(id)sender;

@end
