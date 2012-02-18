//
//  EventDetailController.h
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"

@class Event;
@class LogEntry;

enum Sections {
	kMainSection = 0,
	kFolderSection,
	NUM_SECTIONS
};

enum MainSection {
	kEventName = 0,
	kEventNote,
	kEventDate,
	kEventLocation
};

enum FolderSection {
  kEventFolder = 0
};

@interface EventDetailController : CustomTableViewController

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) EventFolder *folder;

@property (nonatomic, strong) EditableTableCell *nameCell;
@property (nonatomic, strong) EditableTableCell *noteCell;
@property (nonatomic, strong) DatePickerCell *dateCell;
@property (nonatomic, strong) FolderPickerCell *folderCell;
@property (nonatomic, strong) LocationSwitchCell *locationCell;

@end

