//
//  EventFolder.h
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"Event.h"

@interface EventFolder : NSObject <NSCoding>
{
	BOOL needsSorting;
}

@property (nonatomic, strong) NSMutableArray *allItems;;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) EventFolder *parentFolder;

+ (EventFolder *)randomFolder;
- (id)initWithName:(NSString *)name;

- (NSString *)subtitle;
- (NSString *)objectName;

- (void) sortItems;
- (id)latestItem;
- (NSDate *)latestDate;
- (NSArray *)allItems;

- (void)removeItem:(id)item;
- (void)addItem:(id)item;

@end
