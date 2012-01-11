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

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: at %f,%f, recorded on %@", logEntryNote, logEntryLocation.longitude, logEntryLocation.latitude, logEntryDateOccured];
	
}

+ (id)randomLogEntry
{
	NSArray *randomAdjectiveList = [NSArray arrayWithObjects:@"Terrible", @"OK", @"Good", @"Great!", @"Fantastic", nil];

	long noteIndex = rand() % [randomAdjectiveList count];

	NSString *randomNote = [NSString stringWithFormat:@"%@",
													[randomAdjectiveList objectAtIndex:noteIndex]];
	
	int randomDuration = 0 - rand() % 1000000;
	
	NSDate *randomDate = [[NSDate alloc] initWithTimeIntervalSinceNow:randomDuration];

	double latitude = 37.33168900 + (float) ((random() % 100) +1) / 1000000.0;
	double longitude = -122.03073100 + (float) ((random() % 100) +1) / 1000000.0;
	
	CLLocationCoordinate2D randomLocation = CLLocationCoordinate2DMake(latitude,longitude);

	LogEntry *le = [[self alloc] initWithNote:randomNote dateOccured:randomDate location:randomLocation];

	return le;
}

@end
