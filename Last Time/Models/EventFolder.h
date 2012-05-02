//
//  EventFolder.h
//  Last Time
//
//  Created by James Moore on 3/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface EventFolder : NSManagedObject

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSNumber *orderingValue;
@property (nonatomic, strong) NSSet *events;
@property (nonatomic, strong) NSMutableArray *allItems;

@property (nonatomic, strong) Event *latestItem;
@property (nonatomic) BOOL needsSorting;

- (NSString *)subtitle;
- (Event *)latestItem;
- (void)addEvent:(Event *)event;
- (void)removeEvent:(Event *)event;
@end

@interface EventFolder (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
