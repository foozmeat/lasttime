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

#import "FPOCsvWriter.h"

#import "NSManagedObjectContext+FetchAdditions.h"

static EventStore *defaultStore = nil;

@implementation EventStore
@synthesize allFolders = _allFolders;
@synthesize context = _context;
@synthesize model = _model;

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
- (NSManagedObjectModel *)model
{
	if (_model != nil) {
		return _model;
	}
	
	_model = [NSManagedObjectModel mergedModelFromBundles:nil];
	
	return _model;
}

- (NSManagedObjectContext *)context
{
	if (_context != nil)
	{
		return _context;
	}

	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
													 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
	
#if CREATING_SCREENSHOTS
	NSString *path = pathInDocumentDirectory(@"LastTimeDemo.sqlite");
#else
	NSString *path = pathInDocumentDirectory(@"LastTime.sqlite");
#endif
	NSURL *storeURL = [NSURL fileURLWithPath:path];
	
	NSError *error = nil;
	if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
		[NSException raise:@"Open failed"
								format:@"Reason: %@ %@", [error localizedDescription], [error userInfo]];
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
		
		NSEntityDescription *e = [[self.model entitiesByName] objectForKey:@"EventFolder"];
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
	[self saveChanges];
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
	[event removeNotification];
	[self.context deleteObject:event];
}

- (Event *)eventForUUID:(NSString *)uuid
{

	DLog(@"Fetching event for UUID %@", uuid);
	
	NSArray *objects = [[self context] fetchObjectArrayForEntityName:@"Event" withPredicateFormat:@"notificationUUID == %@", uuid];
	
	if ([objects count] > 0) {
		DLog(@"Found event named %@", [[objects objectAtIndex:0] eventName]);
		return [objects objectAtIndex:0];
	} else {
		DLog(@"Found no events with that uuid");
		return nil;
	}

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

#pragma mark - Exporting
- (NSString *)exportToFile
{
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	
	NSURL *tmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@",NSLocalizedString(@"Last Time Export", @"The prefix for the exported file's name"), @"csv"]]];

	[[NSFileManager defaultManager] createFileAtPath:[tmpFile path] contents:nil attributes:nil];
	
//	NSLog(@"%@", tmpFile);
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[tmpFile path]];
	FPOCsvWriter *writer = [[FPOCsvWriter alloc] initWithFileHandle:handle];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *e = [[self.model entitiesByName] objectForKey:@"LogEntry"];
	[request setEntity:e];
	
	NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"logEntryDateOccured" ascending:YES];
	
	[request setSortDescriptors:[NSArray arrayWithObject:sd]];
	
	NSError *error;
	NSArray *result = [self.context executeFetchRequest:request error:&error];
	
	if (!result) {
		[NSException raise:@"Fetch failed" 
								format:@"Reason: %@", [error localizedDescription]];
	}
	
	[writer writeRow:[NSArray arrayWithObjects:@"Date", @"List", @"Event", @"Note", @"Value", @"Location", nil]];

	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];

	@autoreleasepool {
		for (LogEntry *l in result) {
			[writer writeRow:[NSArray arrayWithObjects:[df stringFromDate:l.logEntryDateOccured], l.event.folder.folderName, l.event.eventName, l.logEntryNote, [l.logEntryValue stringValue], l.logEntryLocationString, nil]];

		}
	}	
	
	[handle closeFile];
	return [tmpFile path];
}


#pragma mark - Saving/Loading

- (BOOL)saveChanges
{
	BOOL successful = false;
	
	if ([self.context hasChanges]) {
//		NSLog(@"Saving data...");
		NSError *err = nil;
		successful = [self.context save:&err];
		if (!successful) {
			NSLog(@"Error saving: %@", [err localizedDescription]);
		}
		
	} else {
//		NSLog(@"No changes to save");
	}
	
	return successful;
}

#pragma mark - Migrations
- (void)deleteDatabase
{
	NSString *path = pathInDocumentDirectory(@"LastTime.sqlite");
	NSURL *storeURL = [NSURL fileURLWithPath:path];
	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
	
}

- (void)migrateDataFromVersion:(NSInteger)version
{
#if CREATING_SCREENSHOTS
	return;
#endif
	
	if (version == 0) {		
		[[EventStore defaultStore] loadDefaultData];
	}
	
}

- (void)updateEventLatestDates
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *e = [[self.model entitiesByName] objectForKey:@"Event"];
	[request setEntity:e];
	
	NSError *error;
	NSArray *events = [self.context executeFetchRequest:request error:&error];
	
	if (!events) {
		[NSException raise:@"Fetch failed" 
								format:@"Reason: %@", [error localizedDescription]];
	}

	for (Event *event in events) {
		[event updateLatestDate];
	}
	
	[self saveChanges];
}

- (void)pruneOrphanedLogEntries
{
	NSLog(@"Pruning orphaned log entries");
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *e = [[self.model entitiesByName] objectForKey:@"LogEntry"];
	[request setEntity:e];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == NULL"];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray *result = [self.context executeFetchRequest:request error:&error];
	
	if (!result) {
		[NSException raise:@"Fetch failed" 
								format:@"Reason: %@", [error localizedDescription]];
	}

	NSLog(@"Found %lu entries to delete", (unsigned long)[result count]);
	
	for (LogEntry *le in result) {
		[self removeLogEntry:le];
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
					
//					NSLog(@"Event: %@", e);
				}
			}
		}
		
		[self saveChanges];
	} else {
		NSLog(@"Unable to load plist");
	}
	
	
}

@end
