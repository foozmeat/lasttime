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

@property (nonatomic, strong) NSString *sectionIdentifier;
@property (nonatomic, strong) NSString *primitiveSectionIdentifier;

@property (nonatomic, strong) NSDate *latestDate;
@property (nonatomic, strong) NSDate *primitiveLatestDate;

//- (id)initWithEventName:(NSString *)name
//						 logEntries:(NSMutableArray *)entries;
- (NSString *)subtitle;

//- (NSDate *)latestDate;
- (LogEntry *)latestEntry;
- (void)updateLatestDate;

- (NSTimeInterval)averageInterval;
- (NSString *)averageStringInterval;

- (NSDate *)nextTime;
- (NSString *)lastStringInterval;
- (BOOL)showAverage;

- (float)averageValue;
- (NSString *)averageStringValue;

//+ (Event *)randomEvent;
- (void)addLogEntry:(LogEntry *)entry;
- (void)removeLogEntry:(LogEntry *)logEntry;
@end


@interface Event (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;

@end
