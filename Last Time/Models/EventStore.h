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

@interface EventStore : NSObject <NSObject>
{
	NSMutableArray *_allItems;
	NSManagedObjectContext *context;
	NSManagedObjectModel *model;
}

@property (nonatomic, strong) NSMutableArray *allItems;

+ (EventStore *)defaultStore;
- (BOOL)saveChanges;
- (void)fetchItemsIfNecessary;

#pragma mark - Folders
- (NSArray *)allFolders;
- (void)removeFolder:(EventFolder *)folder;
- (void)addFolder:(EventFolder *)folder;
- (void)moveFolderAtIndex:(int)from toIndex:(int)to;

#pragma mark - Migrations
- (void)removeRootEvents;
- (void)migrateDataFromVersion:(int)version;

@end
