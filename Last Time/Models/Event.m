//
//  Event.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Event.h"

@implementation Event
@synthesize eventName, logEntryCollection, needsSorting;


- (id)init
{
	return [self initWithEventName:@"" logEntries:[[NSMutableArray alloc] init]];
}

- (id)initWithEventName:(NSString *)name logEntries:(NSMutableArray *)entries
{
	if (!(self = [super init]))
		return nil;

	[self setEventName:name];
	[self setLogEntryCollection:entries];
	needsSorting = YES;

	return self;
}

+ (Event *)randomEvent
{
	NSMutableArray *lec = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < 3; i++) {
		LogEntry *le = [LogEntry randomLogEntry];
		[lec insertObject:le atIndex:i];
	}
	
	NSArray *randomEventList = [NSArray arrayWithObjects:@"Got a Massage", @"Took Vacation", @"Watered Plants", @"Bought Cat Food", @"Had Coffee", nil];
	
	long eventIndex = arc4random() % [randomEventList count];
	NSString *name = [randomEventList objectAtIndex:eventIndex];
			
	Event *newEvent = [[self alloc] initWithEventName:(NSString *)name
																				 logEntries:(NSMutableArray *)lec];
	return newEvent;

}

- (void)sortEntries
{
	if (needsSorting) {
		[logEntryCollection sortUsingComparator:^(id a, id b) {
			NSDate *first = [(LogEntry*)a logEntryDateOccured];
			NSDate *second = [(LogEntry*)b logEntryDateOccured];
			return [second compare:first];
		}];
		
		needsSorting = NO;
	}
}

- (NSString *)objectName
{
	return eventName;
}

- (BOOL)showAverage
{
	if ([logEntryCollection count] < 2) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark Average
#pragma mark -
- (NSTimeInterval)averageInterval
{
	if ([logEntryCollection count] == 0.0) {
		return 0;
	}
	
	[self sortEntries];
	
	double runningTotal = 0.0;
	LogEntry *lastEntry = [logEntryCollection objectAtIndex:0];
	double count = [logEntryCollection count];
	
	@autoreleasepool {
		for(LogEntry *entry in logEntryCollection)
		{
			runningTotal += ABS([[entry logEntryDateOccured] timeIntervalSinceDate:[lastEntry logEntryDateOccured]]);
			lastEntry = entry;
		}
	}
	
	double average = ABS(runningTotal / count);
	return average;
	
}

- (NSString *)averageStringInterval;
{
	return [LogEntry stringFromInterval:[self averageInterval] withSuffix:NO];
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
	return [logEntryCollection objectAtIndex:0];
}

- (NSDate *)latestDate
{
	LogEntry *le = [self latestEntry];
	return [le logEntryDateOccured];
}

- (NSDate *)nextTime
{
	NSTimeInterval interval = [self averageInterval];
	NSDate *lastDate = [[self latestEntry] logEntryDateOccured];
	
	NSDate *nextDate = [[NSDate alloc] initWithTimeInterval:interval 
																								sinceDate:lastDate];
	return nextDate;
}


-(NSString*)subtitle
{
	
	NSString *output = nil;
	
	if ([[[self latestEntry] logEntryNote] isEqualToString:@""]) {
		output = [[NSString alloc] initWithFormat:@"%@", [self lastStringInterval]];
	} else {
		output =  [[NSString alloc] initWithFormat:@"%@ - %@", 
						[[self latestEntry] logEntryNote], 
						[self lastStringInterval]];
	}
	
	return output;
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];

	[output appendFormat:@"\n%@", eventName];
	[output appendFormat:@"\n%@", [self subtitle]];
	[output appendFormat:@"\nLatest Entry: %@\n", [self latestEntry]];
	[output appendFormat:@"Average Interval: %f - %@\n", [self averageInterval], [self averageStringInterval]];
	[output appendFormat:@"Next Time: %@\n", [[self nextTime] descriptionWithLocale:[NSLocale currentLocale]]];
	
//	[output appendFormat:@"%@", [self logEntryCollection]];
	
	return output;
}

@end
