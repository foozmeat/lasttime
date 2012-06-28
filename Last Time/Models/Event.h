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

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *lastTimeDisplayFormat;
@property (nonatomic, strong) EventFolder *folder;
@property (nonatomic, strong) NSSet *logEntries;

@property (nonatomic, strong) NSMutableArray *logEntryCollection;
@property (nonatomic) BOOL needsSorting;

@property (nonatomic, strong) NSString *sectionIdentifier;
@property (nonatomic, strong) NSString *primitiveSectionIdentifier;

@property (nonatomic, strong) NSDate *latestDate;
@property (nonatomic, strong) NSDate *primitiveLatestDate;

@property (nonatomic, strong) NSNumber *averageValue;
@property (nonatomic, strong) NSNumber *averageInterval;

@property (nonatomic) NSInteger reminderDuration;
//- (id)initWithEventName:(NSString *)name
//						 logEntries:(NSMutableArray *)entries;
- (NSString *)subtitle;

- (LogEntry *)latestEntry;
- (void)updateLatestDate;

- (NSString *)averageStringInterval;

- (NSDate *)nextTime;
- (NSString *)lastStringInterval;
- (BOOL)showAverage;
- (BOOL)showAverageValue;

- (NSString *)averageStringValue;

- (void)cycleLastTimeDisplayFormat;

//+ (Event *)randomEvent;
- (void)addLogEntry:(LogEntry *)entry;
- (void)removeLogEntry:(LogEntry *)logEntry;

- (void)refreshItems;

- (NSString *)reminderDateString;

@end


@interface Event (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;

@end
