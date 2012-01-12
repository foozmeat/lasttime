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
@synthesize avgTime, meanTime, nextTime;

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
			
			for (int i = 0; i <= 10; i++) {
				LogEntry *le = [LogEntry randomLogEntry];
				[logEntries insertObject:le atIndex:i];
			}
			needsSorting = YES;
			nextTime = [[NSDate alloc] init];

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

//- (NSTimeInterval)getAvgTime
//{
//	double runningTotal = 0.0;
	
//	for(NSNumber *number in array)
//	{
//		runningTotal += [number doubleValue];
//	}
//	
//	return [NSNumber numberWithDouble:(runningTotal / [array count])];
	
//}

- (NSTimeInterval)lastDuration
{
	return [[[self latestEntry] logEntryDateOccured] timeIntervalSinceNow];
}

- (LogEntry *)latestEntry
{
	[self sortEntries];
	return [logEntries objectAtIndex:0];
}

- (NSString *)description
{
	NSMutableString *d = [[NSMutableString alloc] initWithFormat:@"\nAverage Time: %d\n", avgTime];

	[d appendFormat:@"Mean Time: %d\n", meanTime];
	[d appendFormat:@"Last Duration: %d\n", [self lastDuration]];
	[d appendFormat:@"Next Time: %@\n", nextTime];
	[d appendFormat:@"Latest Entry: %@\n", [self latestEntry]];

	[d appendFormat:@"All Entries:\n"];
	
	@autoreleasepool {
		for (LogEntry *entry in logEntries) {
			[d appendFormat:@"-> %@\n", [entry description]];
		}
	}
	return d;
}

- (NSArray *)allLogEntries
{
	return logEntries;
}

@end
