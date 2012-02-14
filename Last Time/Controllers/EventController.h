//
//  EventController.h
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventFolder;

enum EventSections {
	kAverageSection = 0,
	kHistorySection,
	NUM_EVENT_SECTIONS
};

enum AverageSection {
	kAverageTime = 0,
	kNextTime,
};

@interface EventController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EventFolder *folder;
@property (nonatomic, strong) EventFolder *rootFolder;

- (void)addNewItem:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
- (IBAction)addNewItem:(id)sender;
@end
