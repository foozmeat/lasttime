//
//  plistStore.m
//  Last Time
//
//  Created by James Moore on 3/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "PlistStore.h"
#import "oldEvent.h"
#import "oldEventFolder.h"
#import "oldLogEntry.h"

static PlistStore *defaultStore = nil;

@implementation PlistStore
@synthesize allItems = _allItems;

+ (PlistStore *)defaultStore
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


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
	}
	
	return self;
}


- (NSString *)eventDataAchivePath
{
	return pathInDocumentDirectory(@"events.plist");
}

- (void)fetchItemsIfNecessary
{
	if (!_allItems) {
		NSString *path = [self eventDataAchivePath];
//		NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//		NSKeyedUnarchiver *ka = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//		[ka setClass:(OldEventFolder) forClassName:@"EventFolder";
		[NSKeyedUnarchiver setClass:[OldEventFolder class] forClassName:@"EventFolder"];
		[NSKeyedUnarchiver setClass:[OldEvent class] forClassName:@"Event"];
		[NSKeyedUnarchiver setClass:[OldLogEntry class] forClassName:@"LogEntry"];
		[NSKeyedUnarchiver setClass:[PlistStore class] forClassName:@"EventStore"];
		
		PlistStore *archivedStore = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		[self setAllItems:[[NSMutableArray alloc] initWithArray:[archivedStore allItems]]];
	}
	
	if (!_allItems) {
		_allItems = [[NSMutableArray alloc] init];
		
	}
}

- (NSString *)itemArchivePath
{
	NSArray *documentDirectories =
	NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																			NSUserDomainMask, YES);
	
		// Get one and only document directory from that list
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	
	return [documentDirectory stringByAppendingPathComponent:@"events.plist"];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

@end
