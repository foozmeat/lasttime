//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"

@implementation EventFolder
@synthesize isRoot, folderName, allItems, parentFolder;

- (id)init
{
	return [self initWithRoot:NO];
}

- (id)initWithRoot:(BOOL)root
{
	self = [super init];
	
	if (self) {
		if (root) {
			isRoot = root;
			[self setFolderName:NSLocalizedString(@"Home", @"Home")];
			[self fetchItemsIfNecessary];
			[self setParentFolder:nil];

		} else {
			allItems = [[NSMutableArray alloc] init];
		}
	}
	return self;

}

+ (EventFolder *)randomFolderWithRoot:(BOOL)root
{
	EventFolder *folder = [[EventFolder alloc] initWithRoot:root];
	
	@autoreleasepool {
		for (int i = 0; i < 2; i++) {
			[folder addItem:[Event randomEvent]];
		}

		if ([folder isRoot]) {
			folder.folderName = @"Home";
			
			for (int i = 0; i < 1; i++) {
				[folder addItem:[self randomFolderWithRoot:NO]];
			}
		}

		if (![folder isRoot]) {
			NSArray *randomFolderList = [NSArray arrayWithObjects:@"Health", @"Pet", @"Car", @"Vacation", @"Diet", nil];
			
			long folderIndex = arc4random() % [randomFolderList count];
			folder.folderName = [randomFolderList objectAtIndex:folderIndex];
		}						
	}

	return folder;
}

- (void)addItem:(id)item;
{
	[item setParentFolder:self];
	[allItems addObject:item];
	needsSorting = YES;
}

- (Event *)createEvent
{
	Event *e = [[Event alloc] init];
	[allItems addObject:e];
	needsSorting = YES;
	
	return e;
}


- (void)removeItem:(id)item
{
	[allItems removeObjectIdenticalTo:item];
	needsSorting = YES;
}

- (NSString *)subtitle
{
	if (isRoot || [allItems count] == 0) {
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

- (NSArray *)allFolders
{
	
	if (![self isRoot]) {
		return [[NSArray alloc] init];
	}
	
	NSMutableArray *folders = [[NSMutableArray alloc] init];
	
	for (id item in [self allItems]) {
		if ([item isMemberOfClass:[EventFolder class]]) {
			[folders addObject:item];
		}
	}
	
	return folders;
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

#pragma mark - loading/saving
- (NSString *)eventDataAchivePath
{
	return pathInDocumentDirectory(@"events.plist");
}

- (BOOL)saveChanges
{
	if (isRoot) {
		NSLog(@"Saving data...");
		return [NSKeyedArchiver archiveRootObject:self
																			 toFile:[self eventDataAchivePath]];
	} else {
		return NO;
	}
}

- (void)fetchItemsIfNecessary
{
	if (!allItems) {
		NSString *path = [self eventDataAchivePath];
		EventFolder *archivedRootFolder = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		[self setAllItems:[[NSMutableArray alloc] initWithArray:[archivedRootFolder allItems]]];
		needsSorting = YES;

	}

	if (!allItems) {
		allItems = [[NSMutableArray alloc] init];
		
	}
}

#pragma mark - NSCoder
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:folderName forKey:@"folderName"];
	[aCoder encodeObject:allItems forKey:@"allItems"];
	[aCoder encodeInt:isRoot forKey:@"isRoot"];
	[aCoder encodeObject:parentFolder forKey:@"parentFolder"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
		[self setFolderName:[aDecoder decodeObjectForKey:@"folderName"]];
		[self setIsRoot:[aDecoder decodeIntForKey:@"isRoot"]];
		[self setParentFolder:[aDecoder decodeObjectForKey:@"parentFolder"]];
	}
	
	return self;
}

@end
