//
//  LogEntry.m
//  Last Time
//
//  Created by James Moore on 3/14/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LogEntry.h"
#import "Event.h"


@implementation LogEntry

@dynamic latitude;
@dynamic logEntryDateOccured, primitiveLogEntryDateOccured;
@dynamic logEntryLocationString;
@dynamic logEntryNote;
@dynamic logEntryValue;
@dynamic longitude;
@dynamic event;
@dynamic sectionIdentifier, primitiveSectionIdentifier;

//- (id)init
//{
//	return [self initWithNote:@"" dateOccured:[[NSDate alloc] init]];
//}
//
//- (id)initWithNote:(NSString *)note
//			 dateOccured:(NSDate *)dateOccured
//{
//	if (!(self = [super init]))
//		return nil;
//	
//	[self setLogEntryNote:note];
//	[self setLogEntryDateOccured:dateOccured];
//	
//	return self;
//	
//}

- (void)awakeFromInsert
{
	self.logEntryDateOccured = [[NSDate alloc] init];
}

#pragma mark - Transient properties

- (NSString *)sectionIdentifier {
	
    // Create and cache the section identifier on demand.
	
	[self willAccessValueForKey:@"sectionIdentifier"];
	NSString *tmp = [self primitiveSectionIdentifier];
	[self didAccessValueForKey:@"sectionIdentifier"];
	
	if (!tmp) {

		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateStyle:NSDateFormatterFullStyle];
		tmp = [df stringFromDate:[self logEntryDateOccured]];
		
		[self setPrimitiveSectionIdentifier:tmp];
	}
	return tmp;
}

#pragma mark - Time stamp setter

- (void)setTimeStamp:(NSDate *)newDate {
	
    // If the time stamp changes, the section identifier become invalid.
	[self willChangeValueForKey:@"logEntryDateOccured"];
	[self setPrimitiveLogEntryDateOccured:newDate];
	[self didChangeValueForKey:@"logEntryDateOccured"];
	
	[self setPrimitiveSectionIdentifier:nil];
}


#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
    // If the value of timeStamp changes, the section identifier may change as well.
	return [NSSet setWithObject:@"logEntryDateOccured"];
}

#pragma mark - Durations

- (NSTimeInterval)secondsSinceNow
{
	return [self.logEntryDateOccured timeIntervalSinceNow];
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
	return [LogEntry stringFromInterval:[self secondsSinceNow] withSuffix:YES withDays:YES];
}

+ (NSString *)stringFromInterval:(NSTimeInterval)interval 
											withSuffix:(BOOL)suffix
												withDays:(BOOL)withDays
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
	
	int differenceInDays = abs(
														 [sysCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:then] -
														 [sysCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:now]);
		//	NSLog(@"Difference in days: %i", differenceInDays);
	
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
	
	if (differenceInDays == 0 && withDays) {
		[result appendString:@"Today"];
		suffix = NO;
	} else if (differenceInDays == 1 && withDays) {
		[result appendString:@"Yesterday"];
		suffix = NO;
	} else if (differenceInDays < 7 && withDays) {
		[result appendString:[[dateFormatter weekdaySymbols] objectAtIndex:(thenComps.weekday - 1)]];
		suffix = NO;
	} else if (differenceInDays < 13 && withDays) {
		[result appendFormat:@"Last %@", [[dateFormatter weekdaySymbols] objectAtIndex:(thenComps.weekday - 1)]];
		suffix = NO;
		
	} else if (year < 1 && month < 1 && week == 0 && day == 0) {
		[result appendFormat:@"0 days"];
	} else if (year < 1 && month < 1 && week == 0 && day != 0) {
		[result appendFormat:@"%d %@", day, nbday];
	} else if (year < 1 && month < 1 && week <= 4 && day == 0) {
		[result appendFormat:@"%d %@", week, nbweek];
	} else if (year < 1 && month < 1 && week <= 4 && day != 0) {
		[result appendFormat:@"%d %@, %d %@", week, nbweek, day, nbday];
		
	} else if (year < 1 && month < 12 && week == 0 && day == 0) {
		[result appendFormat:@"%d %@", month, nbmonth];
	} else if (year < 1 && month < 12 && week == 0 && day != 0) {
		[result appendFormat:@"%d %@, %d %@", month, nbmonth, day, nbday];
	} else if (year < 1 && month < 12 && week != 0) {
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
	return [NSString stringWithFormat:@"%@: at %@ (%f,%f), recorded on %@, %@, value: %f", 
					self.logEntryNote, 
					self.logEntryLocationString,
					self.logEntryLocation.longitude, self.logEntryLocation.latitude, 
					[self.logEntryDateOccured descriptionWithLocale:[NSLocale currentLocale]], 
					[self stringFromLogEntryInterval],
					self.logEntryValue];
}

//+ (id)randomLogEntry
//{
//	NSArray *randomAdjectiveList = [NSArray arrayWithObjects:@"Terrible", @"OK", @"Good", @"Great!", @"Fantastic", nil];
//	
//	long noteIndex = random() % [randomAdjectiveList count];
//	
//	NSString *randomNote = [NSString stringWithFormat:@"%@",
//													[randomAdjectiveList objectAtIndex:noteIndex]];
//	
//	long randomDuration = arc4random_uniform(60 * 60 * 24 * 7);
//	
//		// Set to 3 for past and future values
//	if (arc4random_uniform(2) > 1) {
//		randomDuration = 0 - randomDuration;
//	}
//	
//	NSDate *randomDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-randomDuration];
//	
//		//	double latitude = 37.33168900 + (float) ((random() % 100) +1) / 1000000.0;
//		//	double longitude = -122.03073100 + (float) ((random() % 100) +1) / 1000000.0;
//		//	
//		//	CLLocationCoordinate2D randomLocation = CLLocationCoordinate2DMake(latitude,longitude);
//	
//	LogEntry *le = [[self alloc] initWithNote:randomNote dateOccured:randomDate];
//	
//	return le;
//}

#pragma mark - Location

- (BOOL)hasLocation
{
	return [self.longitude doubleValue] != 0.0 && [self.latitude doubleValue] != 0.0;
}

- (void)reverseLookupLocation
{
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	
	if ([self hasLocation]) {
		NSLog(@"Fetching location for: %@", [self logEntryNote]);
		
		CLLocation *tempLoc = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
		[geocoder reverseGeocodeLocation:tempLoc completionHandler:
		 ^(NSArray* placemarks, NSError* error){
			 if ([placemarks count] > 0)	 {
				 NSString *name = [[placemarks objectAtIndex:0] name];
				 NSLog(@"Found location: %@", name);
				 [self setLogEntryLocationString:name];
			 } else {
				 NSLog(@"location not found");
			 }
		 }];
	}
	
}

- (NSString *)locationString
{
	if (![self valueForKey:@"logEntryLocationString"] && [self hasLocation]) {
		[self reverseLookupLocation];
	} else if (![self hasLocation]) {
		return @"";
	} else {
		return [self valueForKey:@"logEntryLocationString"];
	}
	
	return @"";
}

- (void)setLogEntryLocation:(CLLocationCoordinate2D)location
{
	self.latitude = [NSNumber numberWithFloat:location.latitude];
	self.longitude = [NSNumber numberWithFloat:location.longitude];
	NSLog(@"Setting location: %f - %f", location.latitude, location.longitude);
//	NSLog(@"Not setting location");
}

- (CLLocationCoordinate2D)logEntryLocation
{
	return CLLocationCoordinate2DMake([[self latitude] floatValue], [[self longitude] floatValue]);

}

@end
