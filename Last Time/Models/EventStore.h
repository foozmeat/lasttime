//
//  EventStore.h
//  Last Time
//
//  Created by James Moore on 2/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventFolder;
@class Event;
@class LogEntry;

@interface EventStore : NSObject <NSObject>

@property (nonatomic, strong) NSMutableArray *allFolders;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

+ (EventStore *)defaultStore;
- (BOOL)saveChanges;
//- (void)fetchItemsIfNecessary;
- (NSManagedObjectContext *)context;
- (void)pruneOrphanedLogEntries;
- (void)updateEventLatestDates;

#pragma mark - Folders
- (NSMutableArray *)allFolders;
- (void)removeFolder:(EventFolder *)folder;
- (EventFolder *)createFolder;

#pragma mark - Events
- (Event *)createEvent;
- (void)removeEvent:(Event *)event;
- (Event *)eventForUUID:(NSString *)uuid;

#pragma mark - LogEntry
- (LogEntry *)createLogEntry;
- (void)removeLogEntry:(LogEntry *)logEntry;

#pragma mark - Migrations
- (void)migrateDataFromVersion:(int)version;

#pragma mark - Exporting
- (NSString *)exportToFile;
@end
