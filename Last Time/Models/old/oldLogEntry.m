//
//  LogEntry.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "oldLogEntry.h"

@implementation OldLogEntry
@synthesize logEntryDateOccured, logEntryNote, logEntryLocation, logEntryValue, logEntryLocationString;


#pragma mark - NSCoder
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:logEntryNote forKey:@"logEntryNote"];
	[aCoder encodeObject:logEntryDateOccured forKey:@"logEntryDateOccured"];
	[aCoder encodeObject:logEntryLocationString forKey:@"logEntryLocationString"];
	[aCoder encodeDouble:logEntryLocation.longitude forKey:@"logEntryLongitude"];
	[aCoder encodeDouble:logEntryLocation.latitude forKey:@"logEntryLatitude"];
	[aCoder encodeDouble:logEntryValue forKey:@"logEntryValue"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setLogEntryNote:[aDecoder decodeObjectForKey:@"logEntryNote"]];
		[self setLogEntryDateOccured:[aDecoder decodeObjectForKey:@"logEntryDateOccured"]];
		[self setLogEntryLocationString:[aDecoder decodeObjectForKey:@"logEntryLocationString"]];
		
		float longitude, latitude;
		longitude = [aDecoder decodeDoubleForKey:@"logEntryLongitude"];
		latitude = [aDecoder decodeDoubleForKey:@"logEntryLatitude"];
		
		CLLocationCoordinate2D new_coordinate = { latitude, longitude };
		
		[self setLogEntryLocation:new_coordinate];

		[self setLogEntryValue:[aDecoder decodeDoubleForKey:@"logEntryValue"]];

	}
	
	return self;
}

@end
