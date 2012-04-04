//
//  Event.m
//  Last Time
//
//  Created by James Moore on 3/15/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Event.h"
#import "EventFolder.h"
#import "LogEntry.h"


@implementation Event

@dynamic eventName;
@dynamic folder;
@dynamic logEntries;
@synthesize logEntryCollection = _logEntryCollection;

@synthesize needsSorting;

//- (id)init
//{
//	return [self initWithEventName:@"" 
//											logEntries:[[NSMutableArray alloc] init]];
//}
//
//- (id)initWithEventName:(NSString *)name logEntries:(NSMutableArray *)entries
//{
//	if (!(self = [super init]))
//		return nil;
//	
//	[self setEventName:name];
//	[self setLogEntryCollection:entries];
//	needsSorting = YES;
//	
//	return self;
//}

//- (void)removeItem:(id)item
//{
//	[self.logEntryCollection removeObjectIdenticalTo:item];
//	needsSorting = YES;
//}


//+ (Event *)randomEvent
//{
//	NSMutableArray *lec = [[NSMutableArray alloc] init];
//	
//	for (int i = 0; i < 3; i++) {
//		LogEntry *le = [LogEntry randomLogEntry];
//		[lec insertObject:le atIndex:i];
//	}
//	
//	NSArray *randomEventList = [NSArray arrayWithObjects:@"Got a Massage", @"Took Vacation", @"Watered Plants", @"Bought Cat Food", @"Had Coffee", nil];
//	
//	long eventIndex = arc4random() % [randomEventList count];
//	NSString *name = [randomEventList objectAtIndex:eventIndex];
//	
//	Event *newEvent = [[self alloc] initWithEventName:(NSString *)name
//																				 logEntries:(NSMutableArray *)lec];
//	return newEvent;
//	
//}

- (void)awakeFromFetch
{
	needsSorting = YES;
}

- (void)addLogEntry:(LogEntry *)entry
{
	self.needsSorting = YES;
	[[[EventStore defaultStore] context] refreshObject:self.folder mergeChanges:NO];
	_logEntryCollection = nil;
	[self addLogEntriesObject:entry];

}

- (void)sortEntries
{
	if (needsSorting && [self.logEntryCollection count] > 0) {
		[_logEntryCollection sortUsingComparator:^(id a, id b) {
			NSDate *first = [(LogEntry*)a logEntryDateOccured];
			NSDate *second = [(LogEntry*)b logEntryDateOccured];
			return [second compare:first];
		}];
		
		needsSorting = NO;
	}
}

- (void)removeLogEntry:(LogEntry *)logEntry
{
	[_logEntryCollection removeObjectIdenticalTo:logEntry];
	[[EventStore defaultStore] removeLogEntry:logEntry];
	self.needsSorting = YES;
}

- (NSMutableArray *)logEntryCollection
{
	
	if (!_logEntryCollection) {
		_logEntryCollection = [[NSMutableArray alloc] initWithArray:[self.logEntries allObjects]];
		needsSorting = YES;
		[self sortEntries];
	}

	return _logEntryCollection;
}

- (BOOL)showAverage
{
	if ([self.logEntryCollection count] < 2) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Average

- (NSTimeInterval)averageInterval
{
	if ([self.logEntryCollection count] < 2) {
		return 0;
	}
	
	[self sortEntries];
	
	double runningTotal = 0.0;
	LogEntry *lastEntry = [self latestEntry];
	double count = [self.logEntryCollection count];
	
	@autoreleasepool {
		for(LogEntry *entry in self.logEntryCollection)
		{
			runningTotal += ABS([[entry logEntryDateOccured] timeIntervalSinceDate:[lastEntry logEntryDateOccured]]);
			lastEntry = entry;
		}
	}
	
	double average = ABS(runningTotal / (count - 1));
	return average;
	
}

- (NSString *)averageStringInterval;
{
	return [LogEntry stringFromInterval:[self averageInterval] withSuffix:NO withDays:NO];
}

- (float)averageValue
{
	if ([self.logEntryCollection count] < 2) {
		return 0.0;
	}
	
	float runningTotal = 0.0;
	double count = 0;
	
	@autoreleasepool {
		for(LogEntry *entry in self.logEntryCollection)
		{
			runningTotal += [[entry logEntryValue] floatValue];
			if ([[entry logEntryValue] floatValue] != 0.0) {
				count++;
			}
		}
	}
	
	if (count == 0.0) {
		return 0.0;
	}
	
	float average = runningTotal / count;
	return average;
	
}

- (NSString *)averageStringValue
{
	nf = [[NSNumberFormatter alloc] init];
	nf.numberStyle = NSNumberFormatterDecimalStyle;
	nf.roundingIncrement = [NSNumber numberWithDouble:0.1];
	NSString *value = [nf stringFromNumber:[NSNumber numberWithFloat:[self averageValue]]];
	
	return value;
	
}

#pragma mark - Last

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
	if ([self.logEntryCollection count] == 0) {
		return nil;
	}
	[self sortEntries];
	return [self.logEntryCollection objectAtIndex:0];
}

- (NSDate *)latestDate
{
	LogEntry *le = [self latestEntry];
	if (!le) {
		return [[NSDate alloc] initWithTimeIntervalSince1970:0];
	} else {
		return [le logEntryDateOccured];
	}
}

- (NSDate *)nextTime
{
	if ([self.logEntryCollection count] < 2) {
		return nil;
	}
	NSTimeInterval interval = [self averageInterval];
	NSDate *lastDate = [[self latestEntry] logEntryDateOccured];
	
	NSDate *nextDate = [[NSDate alloc] initWithTimeInterval:interval 
																								sinceDate:lastDate];
	return nextDate;
}

-(BOOL)showLatestValue
{
	return ([[self latestEntry] logEntryValue] != nil &&
					[[self latestEntry] logEntryValue] != NULL &&
					[[[self latestEntry] logEntryValue] floatValue] != 0.0);
}

-(BOOL)showLatestNote
{
	return (![[[self latestEntry] logEntryNote] isEqualToString:@""] &&
					[[self latestEntry] logEntryNote] != nil &&
					[[self latestEntry] logEntryNote] != NULL);
}

- (NSString *)subtitleForTimeline:(BOOL)forTimeline
{
	
	nf = [[NSNumberFormatter alloc] init];
	nf.numberStyle = NSNumberFormatterDecimalStyle;
	nf.roundingIncrement = [NSNumber numberWithDouble:0.001];
	
	if ([[self logEntryCollection] count] == 0) {
		return @"";
	}
	
	NSString *output = nil;
	
	if ([self showLatestNote]) {
		output =  [[NSString alloc] initWithFormat:@"%@", [[self latestEntry] logEntryNote]];
		if (!forTimeline) {
			output = [[NSString alloc] initWithFormat:@"%@ - %@", output, [self lastStringInterval]];
		}
	} else if ([self showLatestValue]) {
		NSString *value = [nf stringFromNumber:[NSNumber numberWithFloat:[[[self latestEntry] logEntryValue] floatValue]]];
		output = [[NSString alloc] initWithFormat:@"%@", value];

		if (!forTimeline) {
			output = [[NSString alloc] initWithFormat:@"%@ - %@", output, [self lastStringInterval]];
		}
	
	} else if (! forTimeline) {
		output = [[NSString alloc] initWithFormat:@"%@", [self lastStringInterval]];
	} else {
		output = @"";
	}
	
	return output;
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendFormat:@"\n%@", self.eventName];
	[output appendFormat:@"\n%@", [self subtitleForTimeline:NO]];
	[output appendFormat:@"\nLatest Entry: %@\n", [self latestEntry]];
	[output appendFormat:@"Average Interval: %f - %@\n", [self averageInterval], [self averageStringInterval]];
	[output appendFormat:@"Next Time: %@\n", [[self nextTime] descriptionWithLocale:[NSLocale currentLocale]]];
	
		//	[output appendFormat:@"%@", [self logEntryCollection]];
	
	return output;
}

@end
