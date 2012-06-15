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

//-(void)awakeFromFetch
//{
//	needsSorting = YES;
//}

- (void)addEvent:(Event *)event
{
	[self addEventsObject:event];
	[[EventStore defaultStore] saveChanges];
	
	[self refreshItems];

}
- (void)removeEvent:(Event *)event
{
	[[EventStore defaultStore] removeEvent:event];
	[[EventStore defaultStore] saveChanges];

	[self refreshItems];
}

- (void)refreshItems
{
	_latestItem = nil;
	_allItems = nil;
	[[[EventStore defaultStore] context] refreshObject:self mergeChanges:NO];
}

- (NSString *)subtitle
{
	if (![self latestItem]) {
		return @"";
	}
	
	return [[NSString alloc] initWithFormat:@"%@", [[self latestItem] eventName]];
	
}

- (NSMutableArray *)allItems
{
	
	if (!_allItems) {
		_allItems = [[NSMutableArray alloc] initWithArray:[self.events allObjects]];
//		needsSorting = YES;
	}

	return _allItems;
}

- (Event *)latestItem
{
	if (!_latestItem) {
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *e = [NSEntityDescription	entityForName:@"LogEntry" inManagedObjectContext:[[EventStore defaultStore] context]];
		
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
	}
	return _latestItem;
	
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	[output appendFormat:@"Folder: %@\n", [self folderName]];
	 for (Event *item in [self allItems]) {
		 [output appendFormat:@"-> %@ ---> %@\n", [item eventName], [item subtitle]];
	 }
	
	return output;
}

@end
