//
//  Event.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

@class EventFolder;

@interface Event : NSObject <NSCoding>
{
	NSNumberFormatter *nf;
}
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSMutableArray *logEntryCollection;
@property (nonatomic, strong) EventFolder *parentFolder;

@property (nonatomic) BOOL needsSorting;

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
- (BOOL)showAverage;

- (float)averageValue;
- (NSString *)averageStringValue;

+ (Event *)randomEvent;
- (void)addLogEntry:(LogEntry *)entry;
- (void)removeItem:(id)item;

@end

