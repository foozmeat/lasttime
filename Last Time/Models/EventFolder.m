//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"

@implementation EventFolder
@synthesize isRoot, folderName;

- (id)init
{
	self = [super init];
	
	if (self) {
		allItems = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithRandomDataAsRoot:(BOOL)root
{
	self = [super init];
	isRoot = root;
	
	@autoreleasepool {
    
		if (self) {
			allItems = [[NSMutableArray alloc] init];
			needsSorting = YES;

			@autoreleasepool {
				for (int i = 0; i < 1; i++) {
					Event *e = [Event randomEvent];
					[allItems addObject:e];
				}

				if (isRoot) {
					folderName = @"Home";
					
					for (int i = 0; i < 1; i++) {
						EventFolder *f = [[EventFolder alloc] initWithRandomDataAsRoot:NO];
						[allItems addObject:f];
					}
				}

				if (!isRoot) {
					NSArray *randomFolderList = [NSArray arrayWithObjects:@"Health", @"Pet", @"Car", @"Vacation", @"Diet", nil];
					
					long folderIndex = arc4random() % [randomFolderList count];
					folderName = [randomFolderList objectAtIndex:folderIndex];
				}						
			}
		}
		
	}
	return self;
}

- (Event *)createEvent
{
	Event *e = [Event randomEvent];
	
	[allItems addObject:e];
	needsSorting = YES;
	
	return e;
}

- (void)removeItem:(id)item
{
	[allItems removeObjectIdenticalTo:item];
}

- (NSString *)subtitle
{
	if (isRoot) {
		return @"";
	}
	
	return [[NSString alloc] initWithFormat:@"%@ - %@", 
					[[self latestItem] eventName], 
					[[self latestItem] lastStringInterval]];
	
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
			return [second compare:first];
		}];
		
		needsSorting = NO;
	}
	
}

- (id)latestItem
{
	[self sortItems];
	return [allItems objectAtIndex:0];
}

- (NSDate *)latestDate
{
	id item = [self latestItem];
	return [item latestDate];
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
	
	if (!isRoot) {
		[output appendFormat:@"\n%@\n", folderName];
		[output appendFormat:@"-> %@\n", [self subtitle]];
	}
	[output appendFormat:@"\n%@", [self itemDescriptions]];
//	if (rootFolder) {
//		[output appendFormat:@"\n%@", [self folderDescriptions]];
//	}
	
	return output;
}
@end
