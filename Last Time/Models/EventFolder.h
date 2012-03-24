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
{
//	BOOL needsSorting;
}

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSNumber *orderingValue;
@property (nonatomic, strong) NSSet *events;
@property (nonatomic, strong) NSMutableArray *allItems;;


//- (id)initWithName:(NSString *)name;
- (NSString *)subtitle;
- (NSString *)objectName;

//- (void) sortItems;
- (id)latestItem;
- (NSDate *)latestDate;

- (void)removeEvent:(Event *)item;
- (void)addEvent:(Event *)item;
@end

@interface EventFolder (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
