//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"
#import "Event.h"

@implementation EventFolder
@synthesize folderName, rootFolder;

- (id)init
{
	self = [super init];
	
	if (self) {
		eventCollection = [[NSMutableArray alloc] init];
		folderCollection = [[NSMutableArray alloc] init];
		allItems = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithRandomDataAsRoot:(BOOL)root
{
	self = [super init];
	rootFolder = root;
	
	@autoreleasepool {
    
		if (self) {
			allItems = [[NSMutableArray alloc] init];
			eventCollection = [[NSMutableArray alloc] init];
			needsSorting = YES;

			@autoreleasepool {
				for (int i = 0; i < 3; i++) {
					Event *e = [[Event alloc] initWithRandomData];
					[eventCollection insertObject:e atIndex:i];
				}

				if (rootFolder) {
					folderCollection = [[NSMutableArray alloc] init];
					
					for (int i = 0; i < 3; i++) {
						EventFolder *f = [[EventFolder alloc] initWithRandomDataAsRoot:NO];
						[folderCollection insertObject:f atIndex:i];
					}
				}

				if (rootFolder) {
					folderName = @"ROOT";
				} else {
					NSArray *randomFolderList = [NSArray arrayWithObjects:@"Health", @"Pet", @"Car", @"Vacation", @"Diet", nil];
					
					long folderIndex = arc4random() % [randomFolderList count];
					folderName = [randomFolderList objectAtIndex:folderIndex];
				}						
			}
		}
		
	}
	return self;
}

- (NSString *)subtitle
{
	if (rootFolder) {
		return @"";
	}
	
	NSMutableString *output = [[NSMutableString alloc] init];
	return [[NSString alloc] initWithFormat:@"%@ - %@", 
					[[self latestItem] eventName], 
					[[self latestItem] lastStringInterval]];
	
	return output;
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
		
		[allItems removeAllObjects];
		[allItems addObjectsFromArray:eventCollection];
		[allItems addObjectsFromArray:folderCollection];
																
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

//-(NSString *)eventDescriptions
//{
//
//	NSMutableString *output = [[NSMutableString alloc] init];
//	
//	for (Event *event in eventCollection) {
//		[output appendFormat:@"-> %@\n---> %@\n", [event eventName], [event subtitle]];
//	}
//	return output;
//}
//
//-(NSString *)folderDescriptions
//{
//	NSMutableString *output = [[NSMutableString alloc] init];
//	
//	for (EventFolder *f in folderCollection) {
//		[output appendFormat:@"%@", [f description]];
//	}
//	return output;
//}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	if (!rootFolder) {
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
