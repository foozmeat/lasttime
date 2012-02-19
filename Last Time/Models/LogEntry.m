//
//  LogEntry.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LogEntry.h"

@implementation LogEntry
@synthesize logEntryDateOccured, logEntryNote, logEntryLocation;


- (id)init
{
	return [self initWithNote:@"" dateOccured:[[NSDate alloc] init]];
}

- (id)initWithNote:(NSString *)note
	 dateOccured:(NSDate *)dateOccured
{
	if (!(self = [super init]))
		return nil;

	[self setLogEntryNote:note];
	[self setLogEntryDateOccured:dateOccured];
	
	return self;

}

- (NSTimeInterval)secondsSinceNow
{
	return [logEntryDateOccured timeIntervalSinceNow];
}

+ (NSString *)suffixString:(NSTimeInterval) interval
{
	if (interval < 0) {
		return @"ago";
	} else {
		return @"from now";
	}

}

- (NSString *)stringFromLogEntryInterval
{
	return [LogEntry stringFromInterval:[self secondsSinceNow] withSuffix:YES];
}

+ (NSString *)stringFromInterval:(NSTimeInterval)interval withSuffix:(BOOL)suffix
{
	NSMutableString *result = [[NSMutableString alloc] init];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];  
	[dateFormatter setLocale: [NSLocale currentLocale]];
	
	// Get the system calendar
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	unsigned int unitFlags = NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSYearCalendarUnit | NSTimeZoneCalendarUnit;
	
	NSDate *now = [[NSDate alloc] init];
	NSDateComponents *nowComps = [sysCalendar components:unitFlags fromDate:now];

	NSDate *then = [[NSDate alloc] initWithTimeIntervalSinceNow:interval];	
	NSDateComponents *thenComps = [sysCalendar components:unitFlags fromDate:then];
	
	// Discard hours, minutes, and seconds
	nowComps.hour = 12;
	thenComps.hour = 12;
	nowComps.minute = 0;
	thenComps.minute = 0;
	nowComps.second = 0;
	thenComps.second = 0;
	
	now = [sysCalendar dateFromComponents:nowComps];
	then = [sysCalendar dateFromComponents:thenComps];
//	NSLog(@"\nNow:  %@\nThen: %@", now, then);
	
	int differenceInDays = abs(
														 [sysCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:then] -
														 [sysCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:now]);
//	NSLog(@"Difference in days: %i", differenceInDays);
	
	int differenceInWeeks = abs( [sysCalendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSEraCalendarUnit forDate:then] -
															[sysCalendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSEraCalendarUnit forDate:now]);
//	NSLog(@"Difference in weeks: %i", differenceInWeeks);
	
	int differenceInMonths = abs(	[sysCalendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSEraCalendarUnit forDate:then] -
															 [sysCalendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSEraCalendarUnit forDate:now]);
//	NSLog(@"Difference in months: %i", differenceInMonths);
	
//	int differenceInYears = abs(	[sysCalendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:then] -
//															[sysCalendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:now]);
//	NSLog(@"Difference in years: %i", differenceInYears);
	
	NSDateComponents *diffComps = [sysCalendar components:unitFlags fromDate:now  toDate:then  options:0];
	NSInteger year = ABS([diffComps year]);
	NSInteger month = ABS([diffComps month]);
	NSInteger week = ABS([diffComps week]);
	NSInteger day = ABS([diffComps day]);
	
	// Figure date string pieces
	NSString *nbyear = nil;
	if(year > 1)
		nbyear = @"years";
	else
		nbyear = @"year";
	
	NSString *nbmonth = nil;
	if(month > 1)
		nbmonth = @"months";
	else
		nbmonth = @"month";
	
	NSString *nbweek = nil;
	if(week > 1)
		nbweek = @"weeks";
	else
		nbweek = @"week";
	
	NSString *nbday = nil;
	if(day > 1)
		nbday = @"days";
	else
		nbday = @"day";
	
//	NSLog(@"\nDifference: %@", diffComps);
	
	if (differenceInDays == 0) {
		[result appendString:@"Today"];
		suffix = NO;
	} else if (differenceInDays == 1) {
		[result appendString:@"Yesterday"];
		suffix = NO;
	} else if (differenceInDays < 7) {
		[result appendString:[[dateFormatter weekdaySymbols] objectAtIndex:(thenComps.weekday - 1)]];
		suffix = NO;
	} else if (differenceInDays < 13) {
		[result appendFormat:@"Last %@", [[dateFormatter weekdaySymbols] objectAtIndex:(thenComps.weekday - 1)]];
		suffix = NO;
		
	} else if (differenceInWeeks <= 4 && day == 0) {
		[result appendFormat:@"%d %@", week, nbweek];
	} else if (differenceInWeeks <= 4) {
		[result appendFormat:@"%d %@, %d %@", week, nbweek, day, nbday];
		
	} else if (differenceInMonths < 12 && week == 0 && day == 0) {
		[result appendFormat:@"%d %@", month, nbmonth];
	} else if (differenceInMonths < 12 && week == 0 && day != 0) {
		[result appendFormat:@"%d %@, %d %@", month, nbmonth, day, nbday];
	} else if (differenceInMonths < 12 && week != 0) {
		[result appendFormat:@"%d %@, %d %@", month, nbmonth, week, nbweek];
		
	} else if (year > 0 && month == 0 && week == 0) {
		[result appendFormat:@"%d %@", year, nbyear];
	} else if (year > 0 && month == 0 && week != 0) {
		[result appendFormat:@"%d %@, %d %@", year, nbyear, week, nbweek];
	} else if (year > 0 && month != 0) {
		[result appendFormat:@"%d %@, %d %@", year, nbyear, month, nbmonth];
		
	} else {
		[result appendString:@"Date Error"];
	}
	
//	NSLog(@"Result: %@", result);
	if (suffix) {
		[result appendFormat:@" %@",[self suffixString:interval]];
	}
	return result;
}

- (NSString *)subtitle
{
	return [[NSString alloc] initWithFormat:@"%@", [self stringFromLogEntryInterval]];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: at %f,%f, recorded on %@, %@", 
					logEntryNote, 
					logEntryLocation.longitude, logEntryLocation.latitude, 
					[logEntryDateOccured descriptionWithLocale:[NSLocale currentLocale]], 
					[self stringFromLogEntryInterval]];
}

+ (id)randomLogEntry
{
	NSArray *randomAdjectiveList = [NSArray arrayWithObjects:@"Terrible", @"OK", @"Good", @"Great!", @"Fantastic", nil];

	long noteIndex = random() % [randomAdjectiveList count];

	NSString *randomNote = [NSString stringWithFormat:@"%@",
													[randomAdjectiveList objectAtIndex:noteIndex]];
	
	long randomDuration = arc4random_uniform(60 * 60 * 24 * 7);
	
	// Set to 3 for past and future values
	if (arc4random_uniform(2) > 1) {
		randomDuration = 0 - randomDuration;
	}
	
	NSDate *randomDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-randomDuration];

//	double latitude = 37.33168900 + (float) ((random() % 100) +1) / 1000000.0;
//	double longitude = -122.03073100 + (float) ((random() % 100) +1) / 1000000.0;
//	
//	CLLocationCoordinate2D randomLocation = CLLocationCoordinate2DMake(latitude,longitude);

	LogEntry *le = [[self alloc] initWithNote:randomNote dateOccured:randomDate];

	return le;
}

#pragma mark - NSCoder
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:logEntryNote forKey:@"logEntryNote"];
	[aCoder encodeObject:logEntryDateOccured forKey:@"logEntryDateOccured"];
	[aCoder encodeDouble:logEntryLocation.longitude forKey:@"logEntryLongitude"];
	[aCoder encodeDouble:logEntryLocation.latitude forKey:@"logEntryLatitude"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setLogEntryNote:[aDecoder decodeObjectForKey:@"logEntryNote"]];
		[self setLogEntryDateOccured:[aDecoder decodeObjectForKey:@"logEntryDateOccured"]];
		
		float longitude, latitude;
		longitude = [aDecoder decodeDoubleForKey:@"logEntryLongitude"];
		latitude = [aDecoder decodeDoubleForKey:@"logEntryLatitude"];
		
		CLLocationCoordinate2D new_coordinate = { latitude, longitude };
		
		[self setLogEntryLocation:new_coordinate];

	}
	
	return self;
}

@end
