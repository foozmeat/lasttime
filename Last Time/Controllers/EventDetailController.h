//
//  EventDetailController.h
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"
#import "DurationPickerCell.h"
#import "ReminderDurationCell.h"

@class Event;
@class LogEntry;

enum Sections {
	kMainSection = 0,
	kReminderSection,
	kFolderSection,
	NUM_SECTIONS
};

enum MainSection {
	kEventName = 0,
	kEventNote,
	kEventNumber,
	kEventDate,
	kEventLocation
};

enum ReminderSection {
	kEventReminderSwitch = 0,
	kEventReminderDuration,
	kEventReminderScheduledFor,
	NUM_REMINDER_ROWS
};

enum FolderSection {
  kEventFolder = 0
};

@interface EventDetailController : CustomTableViewController <ReminderSwitchCellDelegate, DurationPickerCellDelegate>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) LogEntry *logEntry;
@property (strong, nonatomic) EventFolder *folder;

@property (nonatomic, strong) EditableTableCell *noteCell;
@property (nonatomic, strong) DatePickerCell *dateCell;
@property (nonatomic, strong) DurationPickerCell *durationCell;
@property (nonatomic, strong) FolderPickerCell *folderCell;
@property (nonatomic, strong) ReminderSwitchCell *reminderCell;
@property (nonatomic, strong) ReminderDurationCell *reminderDurationCell;

@end

