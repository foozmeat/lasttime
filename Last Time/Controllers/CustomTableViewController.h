//
//  CustomTableViewController.h
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableTableCell.h"
#import "DatePickerCell.h"
#import "FolderPickerCell.h"

@interface CustomTableViewController : UITableViewController <UITextFieldDelegate, DatePickerCellDelegate, FolderPickerCellDelegate>

@property (strong, nonatomic) EventFolder *rootFolder;
@property (nonatomic) NSInteger requiredField;

- (BOOL)isModal;

- (void)viewFinishedLoading;

//  Action Methods
//
- (void)save;
- (void)cancel;

@end
