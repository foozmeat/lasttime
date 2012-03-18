//
//  Event.h
//  Last Time
//
//  Created by James Moore on 3/15/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventFolder, LogEntry;

@interface Event : NSManagedObject
{
	NSNumberFormatter *nf;
}

@property (nonatomic, strong) NSString * eventName;
@property (nonatomic, strong) EventFolder *folder;
@property (nonatomic, strong) NSSet *logEntries;

@property (nonatomic, strong) NSMutableArray *logEntryCollection;
@property (nonatomic) BOOL needsSorting;

//- (id)initWithEventName:(NSString *)name
//						 logEntries:(NSMutableArray *)entries;
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

//+ (Event *)randomEvent;
- (void)addLogEntry:(LogEntry *)entry;
//- (void)removeItem:(id)item;
@end


@interface Event (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;

@end
