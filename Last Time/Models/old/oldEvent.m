//
//  Event.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "oldEvent.h"

@implementation OldEvent
@synthesize eventName, logEntryCollection, needsSorting;


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
