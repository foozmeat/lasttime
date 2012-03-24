//
//  EventStore.m
//  Last Time
//
//  Created by James Moore on 2/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventStore.h"
#import "EventFolder.h"
#import "Event.h"
#import "LogEntry.h"
#import <CoreData/CoreData.h>
#import "plistStore.h"

static EventStore *defaultStore = nil;

@implementation EventStore
@synthesize allItems = _allItems;
@synthesize context = _context;

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
	return self;
}

#pragma mark - Core Data
- (NSManagedObjectContext *)context
{
	if (_context != nil)
	{
		return _context;
	}

	model = [NSManagedObjectModel mergedModelFromBundles:nil];
		//	NSLog(@"model = %@", model);
	
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	
	NSString *path = pathInDocumentDirectory(@"LastTime.sqllite");
	NSURL *storeURL = [NSURL fileURLWithPath:path];
	
	NSError *error = nil;
	if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		[NSException raise:@"Open failed"
								format:@"Reason: %@", [error localizedDescription]];
	}

	if (psc != nil)
	{
		_context = [[NSManagedObjectContext alloc] init];
		[_context setPersistentStoreCoordinator:psc];
	}
	return _context;
}


#pragma mark - Folder Management

- (NSMutableArray *)allItems
{
	[self fetchItemsIfNecessary];
	return _allItems;
}

- (void)removeFolder:(EventFolder *)folder
{
	[self.context deleteObject:folder];
}

- (EventFolder *)createFolder
{
	EventFolder *ef = [NSEntityDescription insertNewObjectForEntityForName:@"EventFolder" inManagedObjectContext:self.context];
	
	return ef;
	 
}

#pragma mark - events
- (Event *)createEvent
{
	Event *e = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.context];
	return e;
}

- (void)removeEvent:(Event *)event
{
	[self.context deleteObject:event];
}

#pragma mark - LogEntry
- (LogEntry *)createLogEntry
{
	LogEntry *le = (LogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"LogEntry" inManagedObjectContext:self.context];
	return le;
	
}

- (void)removeLogEntry:(LogEntry *)logEntry
{
	[self.context deleteObject:logEntry];
}


#pragma mark - Saving/Loading

- (BOOL)saveChanges
{
	BOOL successful = false;
	
	if ([self.context hasChanges]) {
		NSLog(@"Saving data...");
		NSError *err = nil;
		successful = [self.context save:&err];
		if (!successful) {
			NSLog(@"Error saving: %@", [err localizedDescription]);
		}
		
	} else {
		NSLog(@"No changes to save");
	}
	
	return successful;
}

- (void)fetchItemsIfNecessary
{
	if (!_allItems) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *e = [[model entitiesByName] objectForKey:@"EventFolder"];
		[request setEntity:e];
		
		NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
		
		[request setSortDescriptors:[NSArray arrayWithObject:sd]];
		
		NSError *error;
		NSArray *result = [self.context executeFetchRequest:request error:&error];
		
		if (!result) {
			[NSException raise:@"Fetch failed" 
									format:@"Reason: %@", [error localizedDescription]];
		}
		_allItems = [[NSMutableArray alloc] initWithArray:result];

	}
	
}

#pragma mark - Migrations

- (void)migrateDataFromVersion:(int)version
{

	if (version == 0) {		
		[[EventStore defaultStore] loadDefaultData];
		
	}
	
	if (version != 0 && version < 70) {
//		[self migrateToCoreData];
	}

}

- (void)migrateToCoreData
{
	NSString *path = pathInDocumentDirectory(@"events.plist");;
	plistStore *archivedStore = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	
	NSMutableArray *oldFolders = [[NSMutableArray alloc] initWithArray:[archivedStore allItems]];
	
	[self fetchItemsIfNecessary];
	
	for (EventFolder *ef in oldFolders) {
		NSLog(@"%@", ef.folderName);
    EventFolder *newFolder = [self createFolder];
		newFolder.folderName = ef.folderName;
	}
}

- (void)loadDefaultData
{
	
// Wipe out root
//#warning Delete this
//	_allItems = [[NSMutableArray alloc] init];
	
	if ([_allItems count] > 0) {
		NSLog(@"NOT Loading default data");
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
		int folderIndex = 0;
		@autoreleasepool {
			NSArray *root = [dict objectForKey:@"Root"];
			for (NSDictionary* folder in root) {
				EventFolder *f = [self createFolder];
				[f setFolderName:[folder objectForKey:@"name"]];
				[f setOrderingValue:[NSNumber numberWithInt:folderIndex]];
				folderIndex++;
				
				NSArray *events = [folder objectForKey:@"events"];
				for (NSDictionary *event in events) {
					Event *e = [self createEvent];

					[e setEventName:[event objectForKey:@"name"]];
					
					[f addEvent:e];
					
					NSLog(@"Event: %@", e);
				}
			}
		}
		
		[self saveChanges];
	} else {
		NSLog(@"Unable to load plist");
	}
	
	
}

@end
