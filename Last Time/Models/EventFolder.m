//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 3/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"
#import "Event.h"

@implementation EventFolder

@dynamic folderName;
@dynamic orderingValue;
@dynamic events;

@synthesize allItems;

- (void)addEvent:(Event *)item;
{
	[allItems addObject:item];
	[self addEventsObject:item];
//	needsSorting = YES;
}

- (void)removeEvent:(Event *)item
{
	[allItems removeObjectIdenticalTo:item];
	[self removeEventsObject:item];
//	needsSorting = YES;
}

- (NSString *)subtitle
{
	if ([allItems count] == 0) {
		return @"";
	}
	
	return [[NSString alloc] initWithFormat:@"%@", 
					[[self latestItem] eventName]];
	
}

- (NSString *)objectName
{
	return self.folderName;
}

- (NSArray *)allItems
{
//	[self sortItems];

	return [[NSArray alloc] initWithArray:[self.events allObjects]];
}

//- (void) sortItems
//{
//	if (needsSorting && [allItems count] > 0) {
//		[allItems sortUsingComparator:^(id a, id b) {
//			NSDate *first = [(id)a latestDate];
//			NSDate *second = [(id)b latestDate];
//				//			NSLog(@"%@: %@ %@: %@", [a objectName], first, [b objectName], second);
//			
//			return [second compare:first];
//		}];
//		
//		needsSorting = NO;
//	}
//	
//}

- (id)latestItem
{
	if ([allItems count] == 0) {
		return nil;
	}
	
//	[self sortItems];
	return [allItems objectAtIndex:0];
}

- (NSDate *)latestDate
{
	id item = [self latestItem];
	if (!item) {
		return [[NSDate alloc] initWithTimeIntervalSince1970:0];
	} else {
		return [item latestDate];
	}
}


-(NSString *)itemDescriptions
{
	
//	[self sortItems];
	NSMutableString *output = [[NSMutableString alloc] init];
	
	for (id item in allItems) {
		[output appendFormat:@"-> %@\n---> %@\n", [item objectName], [item subtitle]];
	}
	return output;
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendFormat:@"\n%@", [self itemDescriptions]];
	
	return output;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
		[self setFolderName:[aDecoder decodeObjectForKey:@"folderName"]];
//		needsSorting = YES;
	}
	
	return self;
}

@end
