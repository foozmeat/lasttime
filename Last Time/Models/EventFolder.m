//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 3/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"
#import "Event.h"
#import "LogEntry.h"

@implementation EventFolder

@dynamic folderName;
@dynamic orderingValue;
@dynamic events;

@synthesize allItems = _allItems;
@synthesize latestItem = _latestItem;
@synthesize needsSorting;

-(void)awakeFromFetch
{
	needsSorting = YES;
}

- (NSString *)subtitle
{
	if (![self latestItem]) {
		return @"";
	}
	
	return [[NSString alloc] initWithFormat:@"%@", 
					[[self latestItem] eventName]];
	
}

- (NSMutableArray *)allItems
{
	
	if (!_allItems) {
		_allItems = [[NSMutableArray alloc] initWithArray:[self.events allObjects]];
		needsSorting = YES;
	}

	return _allItems;
}

- (Event *)latestItem
{
	if (!_latestItem || needsSorting == YES) {
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *e = [NSEntityDescription
																							entityForName:@"LogEntry" inManagedObjectContext:[[EventStore defaultStore] context]];
		
		[request setEntity:e];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event IN %@",
															self.events];
		[request setPredicate:predicate];

		NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"logEntryDateOccured" ascending:NO];
		
		[request setSortDescriptors:[NSArray arrayWithObject:sd]];
		[request setFetchLimit:1];
		NSError *error;
		NSArray *result = [[[EventStore defaultStore] context] executeFetchRequest:request error:&error];
		
		if (!result) {
			[NSException raise:@"Fetch failed" 
									format:@"Reason: %@", [error localizedDescription]];
		}
		if ([result count] == 0) {
			_latestItem = nil;
		} else {
			_latestItem = [(LogEntry *)[result objectAtIndex:0] event];
			
		}
		needsSorting = NO;
	}
	return _latestItem;
	
}

-(NSString *)itemDescriptions
{
	
//	[self sortItems];
	NSMutableString *output = [[NSMutableString alloc] init];
	
	for (id item in [self allItems]) {
		[output appendFormat:@"-> %@\n---> %@\n", [item folderName], [item subtitle]];
	}
	return output;
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendFormat:@"\n%@", [self itemDescriptions]];
	
	return output;
}

@end
