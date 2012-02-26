//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"
#import "EventStore.h"

@implementation EventFolder
@synthesize folderName, allItems;

- (id)init
{
	return [self initWithName:@""];
}

- (id)initWithName:(NSString *)name
{
	self = [super init];
	
	if (self) {
		[self setFolderName:name];
		allItems = [[NSMutableArray alloc] init];
	}
	return self;

}

+ (EventFolder *)randomFolder
{

	NSArray *randomFolderList = [NSArray arrayWithObjects:@"Health", @"Pet", @"Car", @"Vacation", @"Diet", nil];
	long folderIndex = arc4random() % [randomFolderList count];
	EventFolder *folder = [[EventFolder alloc] initWithName:[randomFolderList objectAtIndex:folderIndex]];

	@autoreleasepool {
		for (int i = 0; i < 2; i++) {
			[folder addItem:[Event randomEvent]];
		}

	}

	return folder;
}

- (void)addItem:(id)item;
{
	[allItems addObject:item];
	needsSorting = YES;
}

- (void)removeItem:(id)item
{
	[allItems removeObjectIdenticalTo:item];
	needsSorting = YES;
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
	return folderName;
}

- (NSArray *)allItems
{
	[self sortItems];
	return allItems;
}

- (void) sortItems
{
	if (needsSorting) {
		[allItems sortUsingComparator:^(id a, id b) {
			NSDate *first = [(id)a latestDate];
			NSDate *second = [(id)b latestDate];
//			NSLog(@"%@: %@ %@: %@", [a objectName], first, [b objectName], second);
			
			return [second compare:first];
		}];
		
		needsSorting = NO;
	}
	
}

- (id)latestItem
{
	if ([allItems count] == 0) {
		return nil;
	}
	
	[self sortItems];
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
	
	[self sortItems];
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


#pragma mark - NSCoder
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:folderName forKey:@"folderName"];
	[aCoder encodeObject:allItems forKey:@"allItems"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
		[self setFolderName:[aDecoder decodeObjectForKey:@"folderName"]];
	}
	
	return self;
}

@end
