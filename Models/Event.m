//
//  Event.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Event.h"
#import "LogEntryStore.h"

@implementation Event
@synthesize name, note, logEntryCollection;


- (id)init
{
	self = [super init];
	
	if (self) {
		logEntryCollection = [[LogEntryStore alloc] init];
	}
	return self;
}

- (id)initWithRandomData
{
	self = [super init];
	
	@autoreleasepool {
    
		if (self) {
			logEntryCollection = [[LogEntryStore alloc] initWithRandomData];
			NSArray *randomEventList = [NSArray arrayWithObjects:@"Got a Massage", @"Took Vacation", @"Watered Plants", @"Bought Cat Food", @"Had Coffee", nil];
			
			long eventIndex = arc4random() % [randomEventList count];
			name = [randomEventList objectAtIndex:eventIndex];
			
			
			NSArray *randomNoteList = [NSArray arrayWithObjects:@"Note 1", @"Note 2", @"Note 3", @"Note 4", @"Note 5", nil];
			
			long noteIndex = arc4random() % [randomNoteList count];
			note = [randomNoteList objectAtIndex:noteIndex];

		}
		
	}
	return self;
}

-(NSString*)subtitle
{
	return [[[self logEntryCollection] latestEntry] subtitle];
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];

	[output appendFormat:@"\n%@", name];
	[output appendFormat:@"\n%@", note];
	[output appendFormat:@"\n%@", [self subtitle]];
	
	[output appendFormat:@"%@", [self logEntryCollection]];
	
	return output;
}

@end
