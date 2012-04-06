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

@dynamic sectionIdentifier, primitiveSectionIdentifier;
@dynamic latestDate, primitiveLatestDate;

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

#pragma mark - Transient properties

- (NSString *)sectionIdentifier {
	
    // Create and cache the section identifier on demand.
	
	[self willAccessValueForKey:@"sectionIdentifier"];
	NSString *tmp = [self primitiveSectionIdentifier];
	[self didAccessValueForKey:@"sectionIdentifier"];
	
	if (!tmp) {
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateStyle:NSDateFormatterFullStyle];
		tmp = [df stringFromDate:self.latestDate];
		
		[self setPrimitiveSectionIdentifier:tmp];
	}
	return tmp;
}

- (void)updateLatestDate
{
	LogEntry *le = [self latestEntry];
	if (!le) {
		self.latestDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
	} else {
		self.latestDate = [le logEntryDateOccured];
	}
}


- (void)setLatestDate:(NSDate *)newDate {
	
    // If the time stamp changes, the section identifier become invalid.
	[self willChangeValueForKey:@"latestDate"];
	[self setPrimitiveLatestDate:newDate];
	[self didChangeValueForKey:@"latestDate"];
	
	[self setPrimitiveSectionIdentifier:nil];
}

#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
    // If the value of timeStamp changes, the section identifier may change as well.
	return [NSSet setWithObject:@"latestDate"];
}

- (void)awakeFromFetch
{
	needsSorting = YES;
}

- (void)addLogEntry:(LogEntry *)entry
{
	self.needsSorting = YES;
	[[[EventStore defaultStore] context] refreshObject:self.folder mergeChanges:NO];
	[_logEntryCollection addObject:entry];
	[self addLogEntriesObject:entry];
	[self updateLatestDate];

}

- (void)removeLogEntry:(LogEntry *)logEntry
{
	self.needsSorting = YES;
	[[[EventStore defaultStore] context] refreshObject:self.folder mergeChanges:NO];
	[_logEntryCollection removeObjectIdenticalTo:logEntry];
	[[EventStore defaultStore] removeLogEntry:logEntry];
	[self updateLatestDate];

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

- (NSString *)subtitle
{
	return [[self latestEntry] subtitle];
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendFormat:@"\n%@", self.eventName];
	[output appendFormat:@"\n%@", [self subtitle]];
	[output appendFormat:@"\nLatest Entry: %@\n", [self latestEntry]];
	[output appendFormat:@"Average Interval: %f - %@\n", [self averageInterval], [self averageStringInterval]];
	[output appendFormat:@"Next Time: %@\n", [[self nextTime] descriptionWithLocale:[NSLocale currentLocale]]];
	
		//	[output appendFormat:@"%@", [self logEntryCollection]];
	
	return output;
}

@end
