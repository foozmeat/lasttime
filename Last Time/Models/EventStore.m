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
#import "PlistStore.h"

#import "oldEvent.h"
#import "oldEventFolder.h"
#import "oldLogEntry.h"

static EventStore *defaultStore = nil;

@implementation EventStore
@synthesize allFolders = _allFolders;
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

- (NSMutableArray *)allFolders
{
	if (!_allFolders) {
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
		_allFolders = [[NSMutableArray alloc] initWithArray:result];
	}
	return _allFolders;
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

//- (void)fetchItemsIfNecessary
//{
//	if (!_allItems) {
//		NSFetchRequest *request = [[NSFetchRequest alloc] init];
//		
//		NSEntityDescription *e = [[model entitiesByName] objectForKey:@"EventFolder"];
//		[request setEntity:e];
//		
//		NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
//		
//		[request setSortDescriptors:[NSArray arrayWithObject:sd]];
//		
//		NSError *error;
//		NSArray *result = [self.context executeFetchRequest:request error:&error];
//		
//		if (!result) {
//			[NSException raise:@"Fetch failed" 
//									format:@"Reason: %@", [error localizedDescription]];
//		}
//		_allItems = [[NSMutableArray alloc] initWithArray:result];
//
//	}
//	
//}

#pragma mark - Migrations
- (void)deleteDatabase
{
	NSString *path = pathInDocumentDirectory(@"LastTime.sqllite");
	NSURL *storeURL = [NSURL fileURLWithPath:path];
	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
	
}

- (void)migrateDataFromVersion:(int)version
{
	
	if (version == 0) {		
		[[EventStore defaultStore] loadDefaultData];
	}
	
	if (version != 0 && version < 7) {
		[self migrateToCoreData];
	}

}

- (void)migrateToCoreData
{
	NSLog(@"Migrating to Core Data");
	PlistStore *archivedStore = [PlistStore defaultStore];
		
	float	index = 0.0;
	
	for (OldEventFolder *ef in [archivedStore allItems]) {
		NSLog(@"%@", ef.folderName);
    EventFolder *newFolder = [self createFolder];
		newFolder.folderName = ef.folderName;
		newFolder.orderingValue = [NSNumber numberWithFloat:index];

		index++;
		for (OldEvent *ev in [ef allItems]) {
			Event *newEvent = [self createEvent];
			newEvent.eventName = ev.eventName;
			newEvent.folder = newFolder;
			
			for (OldLogEntry *le in [ev logEntryCollection]) {
				
				LogEntry *newLogEntry = [self createLogEntry];
				newLogEntry.logEntryDateOccured = le.logEntryDateOccured;
				newLogEntry.logEntryNote = le.logEntryNote;
				newLogEntry.logEntryValue = [NSNumber numberWithFloat:le.logEntryValue];
				newLogEntry.logEntryLocationString = le.logEntryLocationString;
				newLogEntry.latitude = [NSNumber numberWithFloat:le.logEntryLocation.latitude];
				newLogEntry.longitude = [NSNumber numberWithFloat:le.logEntryLocation.longitude];
				newLogEntry.event = newEvent;
			}
			
		}
		
	}
	
	[self saveChanges];
}

- (void)loadDefaultData
{
	
//	if ([[self allFolders] count] > 0) {
//		NSLog(@"NOT Loading default data");
//		return;
//	}
	
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
					
					[f addEventsObject:e];
					
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
