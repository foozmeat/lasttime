//
//  EventDetailController.h
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerCell.h"

@class Event;
@class LogEntry;
@class EditableTableCell;
@class DatePickerCell;

enum {
	EventName = 0,
	EventNote,
	EventDate
};

@interface EventDetailController : UITableViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, DatePickerCellDelegate>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) EventFolder *rootFolder;

@property (nonatomic, strong) EditableTableCell *nameCell;
@property (nonatomic, strong) EditableTableCell *noteCell;
@property (nonatomic, strong) DatePickerCell *dateCell;

- (BOOL)isModal;

//  Action Methods
//
- (void)save;
- (void)cancel;

@end

