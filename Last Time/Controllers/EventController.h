//
//  EventController.h
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"

@class EventFolder;
@class Event;

enum EventSections {
	kAverageSection = 0,
	kHistorySection,
	NUM_EVENT_SECTIONS
};

enum AverageSection {
	kAverageTime = 0,
	kNextTime,
	kAverageValue,
	NUM_AVERAGE_SECTIONS
};

enum historyViewCellTags {
  logEntryNoteLabel = 0,
  logEntryNoteDate,
	logEntryNoteValue
};

@interface EventController : UIViewController <UITableViewDelegate, UITableViewDataSource, WEPopoverControllerDelegate>
{
	NSNumberFormatter *numberFormatter;
}

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EventFolder *folder;
@property (nonatomic, strong) EventFolder *rootFolder;
@property (nonatomic, strong) WEPopoverController *averagePopover;
@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
- (IBAction)addNewItem:(id)sender;
@end
