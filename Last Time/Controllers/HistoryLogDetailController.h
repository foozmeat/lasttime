//
//  HistoryLogDetailController.h
//  Last Time
//
//  Created by James Moore on 1/25/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LogEntry;

@interface HistoryLogDetailController : UITableViewController
{
	LogEntry *logEntry;
}

@property (nonatomic, strong) LogEntry *logEntry;

- (id)initForNewItem:(BOOL)isNew;

@end
