//
//  EventStore.m
//  Last Time
//
//  Created by James Moore on 2/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventStore.h"
#import "EventFolder.h"

static EventStore *defaultStore = nil;

@implementation EventStore
@synthesize allItems = _allItems;

+ (EventStore *)defaultStore
{
	if (!defaultStore) {
		defaultStore = [[super allocWithZone:NULL] init];
	}
	
	return defaultStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [self defaultStore];
	
}

- (id)init
{
	if (defaultStore) {
		return defaultStore;
	}
	
	self = [super init];
	
	if (self) {
	}
	return self;
}

#pragma mark - Folder Management

- (NSMutableArray *)allItems
{
	[self fetchItemsIfNecessary];
	return _allItems;
}

- (NSArray *)allFolders
{
	[self fetchItemsIfNecessary];
	return [self allItems];
}

-(void)removeFolder:(EventFolder *)folder
{
	[[self allItems] removeObjectIdenticalTo:folder];
}

-(void)addFolder:(EventFolder *)folder
{
	[[self allItems] addObject:folder];
	[self saveChanges];
}

#pragma mark - Saving/Loading

- (NSString *)eventDataAchivePath
{
	return pathInDocumentDirectory(@"events.plist");
}

- (BOOL)saveChanges
{
	NSLog(@"Saving data...");
	return [NSKeyedArchiver archiveRootObject:self
																		 toFile:[self eventDataAchivePath]];
}

- (void)fetchItemsIfNecessary
{
	if (!_allItems) {
		NSString *path = [self eventDataAchivePath];
		EventStore *archivedStore = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		[self setAllItems:[[NSMutableArray alloc] initWithArray:[archivedStore allItems]]];
	}
	
	if (!_allItems) {
		_allItems = [[NSMutableArray alloc] init];
		
	}
}


#pragma mark - Migrations

- (void)migrateDataFromVersion:(int)version
{

	if (version == 0) {
		[[EventStore defaultStore] removeRootEvents];
		
	}

}

- (void)removeRootEvents
{
	NSLog(@"Migrating root events");
	@autoreleasepool {
				
		// Gather up all the root events
		NSMutableArray *unfiledEvents = [[NSMutableArray alloc] init];
		
		for (id item in [self allItems]) {
			if ([item isMemberOfClass:[Event class]]) {
				[unfiledEvents addObject:item];
				
			}
		}
		
		// If there are any then make a new folder
		if ([unfiledEvents count] > 0) {
			EventFolder *unfiled = [[EventFolder alloc] init];
			unfiled.folderName = @"Unfiled";
			
			//Put the events in the folder
			unfiled.allItems = unfiledEvents;
			
			// add the new folder to the root
			[self addFolder:unfiled];
			
			//Remove them from the root
			for (id item in unfiledEvents) {
				[[self allItems] removeObjectIdenticalTo:item];
			}
		}
	}
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_allItems forKey:@"allItems"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
	}
	
	return self;
}

@end
