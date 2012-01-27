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
	if (!(self = [super init]))
		return nil;
	
	[self setLogEntryNote:@""];
	[self setLogEntryDateOccured:[[NSDate alloc] init]];
	
	return self;

}

- (id)initWithNote:(NSString *)note
	 dateOccured:(NSDate *)dateOccured
			location:(CLLocationCoordinate2D)location
{
	if (!(self = [super init]))
		return nil;

	[self setLogEntryNote:note];
	[self setLogEntryDateOccured:dateOccured];

	logEntryLocation = location;
	
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
		
	// Get the system calendar
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	
	// Create the NSDates
	NSDate *now = [[NSDate alloc] init];
	NSDate *date2 = [[NSDate alloc] initWithTimeInterval:interval sinceDate:now]; 
	
	// Get conversion to months, days, hours, minutes
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
	
	NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:now  toDate:date2  options:0];
	NSInteger month = ABS([conversionInfo month]);
	NSInteger day = ABS([conversionInfo day]);
	NSInteger hour = ABS([conversionInfo hour]);
	NSInteger minute = ABS([conversionInfo minute]);
	
	NSArray *datePieces = [[NSArray alloc] initWithObjects:
												 [NSNumber numberWithUnsignedInteger:month],
												 [NSNumber numberWithUnsignedInteger:day],
												 [NSNumber numberWithUnsignedInteger:hour],
												 [NSNumber numberWithUnsignedInteger:minute],
												 nil];
	
	// Figure date string pieces
	NSString *nbmonth = nil;
	if(month > 1)
		nbmonth = @"months";
	else
		nbmonth = @"month";

	NSString *nbday = nil;
	if(day > 1)
		nbday = @"days";
	else
		nbday = @"day";

	NSString *nbhour = nil;
	if(hour > 1)
		nbhour = @"hours";
	else
		nbhour = @"hour";

	NSString *nbmin = nil;
	if(minute > 1)
		nbmin = @"minutes";
	else
		nbmin = @"minute";
	
	NSMutableString *output = [[NSMutableString alloc] init];

	NSArray *dateStringPieces = [[NSArray alloc] initWithObjects:nbmonth, nbday, nbhour, nbmin, nil];
	
	BOOL foundFirstPiece = NO;
	int piecesFound = 0;
	unsigned long i = 0;
//	NSLog(@"%@", conversionInfo);
	
	while (piecesFound < 2 && i < [datePieces count]) {

		if (![[datePieces objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:0]]) {
			foundFirstPiece = YES;
			piecesFound++;
			[output appendFormat:@"%@ %@ ", [datePieces objectAtIndex:i], [dateStringPieces objectAtIndex:i]];
		} else if (foundFirstPiece) {
			piecesFound++;
		}
		i++;
//		NSLog(@"%lu", i);
	}
	if (piecesFound == 0) {
		[output appendString:@"Now"];
	} else if (suffix) {
		[output appendFormat:@"%@",[self suffixString:interval]];
	}
		
	return output;
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

	double latitude = 37.33168900 + (float) ((random() % 100) +1) / 1000000.0;
	double longitude = -122.03073100 + (float) ((random() % 100) +1) / 1000000.0;
	
	CLLocationCoordinate2D randomLocation = CLLocationCoordinate2DMake(latitude,longitude);

	LogEntry *le = [[self alloc] initWithNote:randomNote dateOccured:randomDate location:randomLocation];

	return le;
}

@end
