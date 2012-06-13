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

#import "FPOCsvWriter.h"

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
	
	NSString *path = pathInDocumentDirectory(@"LastTime.sqlite");
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

#pragma mark - Exporting
- (NSURL *)exportToFile
{
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	
	NSURL *tmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Last Time Export %@.%@", [df stringFromDate:[NSDate new]], @"csv"]]];

	[[NSFileManager defaultManager] createFileAtPath:[tmpFile path] contents:nil attributes:nil];
	
	NSLog(@"%@", tmpFile);
	
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
	return tmpFile;
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

- (void)migrateDataFromVersion:(int)version
{
	
	if (version == 0) {		
		[[EventStore defaultStore] loadDefaultData];
	}
	
	if (version != 0 && version < 7) {
		[self migrateToCoreData];
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

	NSLog(@"Found %i entries to delete", [result count]);
	
	for (LogEntry *le in result) {
		[self removeLogEntry:le];
	}

	[self saveChanges];
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
	[self	updateEventLatestDates];
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
