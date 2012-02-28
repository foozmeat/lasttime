//
//  HistoryLogDetailController.h
//  Last Time
//
//  Created by James Moore on 1/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"

@class LogEntry;
@class Event;

enum {
	kEventNote = 0,
	kEventNumber,
	kEventDate,
	kEventLocationSwitch,
	kEventLocation
};

@interface HistoryLogDetailController : CustomTableViewController

@property (nonatomic, strong) LogEntry *logEntry;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EditableTableCell *noteCell;
@property (nonatomic, strong) DatePickerCell *dateCell;
@property (nonatomic, strong) LocationSwitchCell *locationSwitchCell;
@end
