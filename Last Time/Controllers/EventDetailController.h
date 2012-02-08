//
//  EventDetailController.h
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@class LogEntry;
@class EditableTableCell;

enum {
	EventName = 0,
	EventNote,
	EventDate
};

@interface EventDetailController : UITableViewController <UITextFieldDelegate>
{
	NSDateFormatter *df;
	IBOutlet UIDatePicker *datePicker;
}

@property (strong, nonatomic) Event *event;

@property (nonatomic, strong) EditableTableCell *nameCell;
@property (nonatomic, strong) EditableTableCell *noteCell;
@property (nonatomic, strong) EditableTableCell *dateCell;

- (IBAction)dateChanged:(id)sender;
- (BOOL)isModal;

- (EditableTableCell *)newDetailCellWithTag:(NSInteger)tag;

//  Action Methods
//
- (void)save;
- (void)cancel;

@end

