//
//  EventController.h
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventFolder;

@interface EventController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EventFolder *folder;
@property (nonatomic, strong) EventFolder *rootFolder;

- (void)addNewItem:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
- (IBAction)addNewItem:(id)sender;
@end
