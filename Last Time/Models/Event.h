//
//  Event.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

@interface Event : NSObject
{
	NSString *eventName;
	NSMutableArray *logEntryCollection;
	BOOL needsSorting;
}

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSMutableArray *logEntryCollection;

- (id)initWithEventName:(NSString *)name
						 logEntries:(NSMutableArray *)entries;

- (NSString *)subtitle;

- (NSDate *)latestDate;
- (LogEntry *)latestEntry;

- (NSTimeInterval)averageInterval;
- (NSString *)averageStringInterval;

- (NSDate *)nextTime;
- (NSString *)lastStringInterval;
- (NSString *)objectName;

+ (Event *)randomEvent;

@end

