//
//  EventStore.h
//  Last Time
//
//  Created by James Moore on 2/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventFolder;

@interface EventStore : NSObject <NSCoding>
{
	NSMutableArray *_allItems;
}
@property (nonatomic, strong) NSMutableArray *allItems;

+ (EventStore *)defaultStore;

- (NSArray *)allFolders;

-(void)removeFolder:(EventFolder *)folder;
-(void)addFolder:(EventFolder *)folder;

- (BOOL)saveChanges;
- (void)fetchItemsIfNecessary;

- (void)removeRootEvents;


@end
