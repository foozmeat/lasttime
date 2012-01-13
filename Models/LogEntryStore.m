//
//  LogEntryStore.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LogEntryStore.h"
#import "LogEntry.h"

@implementation LogEntryStore

- (id)init
{
	self = [super init];
	
	if (self) {
		logEntries = [[NSMutableArray alloc] init];
		needsSorting = YES;
	}
	return self;
}

- (id)initWithRandomData
{
	self = [super init];
	
	@autoreleasepool {
    
		if (self) {
			logEntries = [[NSMutableArray alloc] init];
			
			for (int i = 0; i < 10; i++) {
				LogEntry *le = [LogEntry randomLogEntry];
				[logEntries insertObject:le atIndex:i];
			}
			needsSorting = YES;

		}
		
	}
	return self;
}

- (void)sortEntries
{
	if (needsSorting) {
		[logEntries sortUsingComparator:^(id a, id b) {
			NSDate *first = [(LogEntry*)a logEntryDateOccured];
			NSDate *second = [(LogEntry*)b logEntryDateOccured];
			return [second compare:first];
		}];

		needsSorting = NO;
	}
}

#pragma mark Average
#pragma mark -
- (NSTimeInterval)averageInterval
{
	if ([logEntries count] == 0.0) {
		return 0;
	}
	
	[self sortEntries];

	double runningTotal = 0.0;
	LogEntry *lastEntry = [logEntries objectAtIndex:0];
	double count = [logEntries count];
	
	@autoreleasepool {
		for(LogEntry *entry in logEntries)
		{
			runningTotal += ABS([[entry logEntryDateOccured] timeIntervalSinceDate:[lastEntry logEntryDateOccured]]);
			lastEntry = entry;
		}
	}
	
	double average = ABS(runningTotal / count);
	return average;
	
}

- (NSString *)averageStringInterval
{
	return [LogEntry stringFromInterval:[self averageInterval]];
}

#pragma mark Last
#pragma mark -

- (NSTimeInterval)lastDuration
{
	return [[self latestEntry] secondsSinceNow];
}

- (NSString *)lastStringInterval
{
	return [[self latestEntry] stringFromLogEntryInterval];
}


- (LogEntry *)latestEntry
{
	[self sortEntries];
	return [logEntries objectAtIndex:0];
}

- (NSDate *)nextTime
{
	NSTimeInterval interval = [self averageInterval];
	NSDate *lastDate = [[self latestEntry] logEntryDateOccured];
	
	NSDate *nextDate = [[NSDate alloc] initWithTimeInterval:interval 
																								sinceDate:lastDate];
	return nextDate;
}


- (NSString *)description
{
	NSMutableString *d = [[NSMutableString alloc] init];

	[d appendFormat:@"\nLatest Entry: %@\n", [self latestEntry]];
	[d appendFormat:@"Average Interval: %f - %@\n", [self averageInterval], [self averageStringInterval]];
	[d appendFormat:@"Next Time: %@\n", [[self nextTime] descriptionWithLocale:[NSLocale currentLocale]]];

	[d appendFormat:@"All Entries:\n"];
	
	@autoreleasepool {
		for (LogEntry *entry in logEntries) {
			[d appendFormat:@"-> %@\n", [entry description]];
		}
	}
	return d;
}

@end
