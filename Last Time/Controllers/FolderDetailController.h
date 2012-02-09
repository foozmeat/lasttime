//
//  FolderDetailController.h
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditableTableCell;
@class EventFolder;

enum {
	FolderName
};

@interface FolderDetailController : UITableViewController <UITextFieldDelegate>
{
	
}

@property (strong, nonatomic) EventFolder *folder;
@property (strong, nonatomic) EventFolder *rootFolder;
@property (nonatomic, retain) EditableTableCell *nameCell;

- (BOOL)isModal;

//  Action Methods
//
- (void)save;
- (void)cancel;

@end
