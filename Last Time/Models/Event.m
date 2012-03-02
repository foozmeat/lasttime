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
	return [self initWithEventName:@"" 
											logEntries:[[NSMutableArray alloc] init]];
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

- (void)removeItem:(id)item
{
	[logEntryCollection removeObjectIdenticalTo:item];
	needsSorting = YES;
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

- (void)addLogEntry:(LogEntry *)entry
{
	[[self logEntryCollection] addObject:entry];
	self.needsSorting = YES;
}

- (void)sortEntries
{
	if (needsSorting && [logEntryCollection count] > 0) {
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
	if ([logEntryCollection count] < 2) {
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
	
	double average = ABS(runningTotal / (count - 1));
	return average;
	
}

- (NSString *)averageStringInterval;
{
	return [LogEntry stringFromInterval:[self averageInterval] withSuffix:NO withDays:NO];
}

- (float)averageValue
{
	if ([logEntryCollection count] < 2) {
		return 0.0;
	}
	
	float runningTotal = 0.0;
	double count = 0;
	
	@autoreleasepool {
		for(LogEntry *entry in logEntryCollection)
		{
			runningTotal += [entry logEntryValue];
			if ([entry logEntryValue] != 0.0) {
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
	if ([logEntryCollection count] == 0) {
		return nil;
	}
	[self sortEntries];
	return [logEntryCollection objectAtIndex:0];
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
	if ([logEntryCollection count] < 2) {
		return nil;
	}
	NSTimeInterval interval = [self averageInterval];
	NSDate *lastDate = [[self latestEntry] logEntryDateOccured];
	
	NSDate *nextDate = [[NSDate alloc] initWithTimeInterval:interval 
																								sinceDate:lastDate];
	return nextDate;
}


-(NSString*)subtitle
{
	
	nf = [[NSNumberFormatter alloc] init];
	nf.numberStyle = NSNumberFormatterDecimalStyle;
	nf.roundingIncrement = [NSNumber numberWithDouble:0.001];

	if ([[self logEntryCollection] count] == 0) {
		return @"";
	}
	
	NSString *output = nil;
	
	if ([[[self latestEntry] logEntryNote] isEqualToString:@""]) {
		if ([[self latestEntry] logEntryValue] != 0) {
			NSString *value = [nf stringFromNumber:[NSNumber numberWithFloat:[[self latestEntry] logEntryValue]]];
			output = [[NSString alloc] initWithFormat:@"%@ - %@", value, [self lastStringInterval]];
		} else {
			output = [[NSString alloc] initWithFormat:@"%@", [self lastStringInterval]];
			
		}
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

#pragma mark - NSCoder
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:eventName forKey:@"eventName"];
	[aCoder encodeObject:logEntryCollection forKey:@"logEntryCollection"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setLogEntryCollection:[aDecoder decodeObjectForKey:@"logEntryCollection"]];
		[self setEventName:[aDecoder decodeObjectForKey:@"eventName"]];
		needsSorting = YES;
	}
	
	return self;
}

@end
