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

- (void)moveFolderAtIndex:(int)from toIndex:(int)to
{
	if (from == to) {
		return;
	}
	
	EventFolder *e = [_allItems objectAtIndex:from];
	[_allItems removeObjectAtIndex:from];
	
	[_allItems insertObject:e atIndex:to];
	
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
		
		[[EventStore defaultStore] loadDefaultData];
		
	}

}

- (void)removeRootEvents
{
	if ([_allItems count] == 0) {
		return;
	}
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

- (void)loadDefaultData
{
	
// Wipe out root
//#warning Delete this
//	_allItems = [[NSMutableArray alloc] init];
	
	if ([_allItems count] > 0) {
		return;
	}
	
	NSLog(@"Loading default data");
	NSString *path = [[NSBundle mainBundle] pathForResource:@"default_data" ofType:@"plist"];
	NSData *data = [NSData dataWithContentsOfFile:path];
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data
																													 mutabilityOption:NSPropertyListImmutable
																																		 format:NSPropertyListImmutable
																													 errorDescription:NULL];

	if (dict) {
		
		@autoreleasepool {
			NSArray *root = [dict objectForKey:@"Root"];
			for (NSDictionary* folder in root) {
				EventFolder *f = [[EventFolder alloc] initWithName:[folder objectForKey:@"name"]];
				
				NSArray *events = [folder objectForKey:@"events"];
				for (NSDictionary *event in events) {
					Event *e = [[Event alloc] init];
					[e setEventName:[event objectForKey:@"name"]];
					
					NSArray *logEntries = [event objectForKey:@"logEntries"];
					NSMutableArray *entryCollection = [[NSMutableArray alloc] init];
					
					for (NSDictionary *logEntry in logEntries) {
						
						LogEntry *le = [[LogEntry alloc] init];
						
						[le setLogEntryNote:[logEntry objectForKey:@"note"]];
						
						// Make up a date
						// Set to 3 for past and future values
						long randomDuration = arc4random_uniform(60 * 60 * 24 * 100);
						if (arc4random_uniform(2) > 1) {
							randomDuration = 0 - randomDuration;
						}
						
						NSDate *randomDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-randomDuration];

						[le setLogEntryDateOccured:randomDate];
						
						NSNumber *value = [logEntry objectForKey:@"value"];
						[le setLogEntryValue:[value floatValue]];
						
						NSDictionary *location = [logEntry objectForKey:@"location"];
						NSNumber *lat = [location objectForKey:@"latitude"];
						NSNumber *longitude = [location objectForKey:@"longitude"];
						
						CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([lat floatValue], [longitude floatValue]);
					
						[le setLogEntryLocation:loc];
						[le reverseLookupLocation];
						[entryCollection addObject:le];
						
					}
					[e setNeedsSorting:YES];
					[e setLogEntryCollection:entryCollection];
					[f addItem:e];
				}
				
				[[EventStore defaultStore] addFolder:f];
			}
		}
		
	} else {
		NSLog(@"Unable to load plist");
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
