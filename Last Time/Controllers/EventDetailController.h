//
//  EventDetailController.h
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface EventDetailController : UITableViewController
{
		
	Event *event;
}

@property (nonatomic, strong) Event *event;

- (IBAction)addNewItem:(id)sender;

@end
