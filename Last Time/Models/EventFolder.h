//
//  EventFolder.h
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"Event.h"

@interface EventFolder : NSObject
{
	NSString *folderName;
	NSMutableArray *allItems;
	BOOL isRoot;
	BOOL needsSorting;
}

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic) BOOL isRoot;

- (id)initWithRandomDataAsRoot:(BOOL)root;

- (NSString *)subtitle;
- (NSString *)objectName;

- (void) sortItems;
- (id)latestItem;
- (NSDate *)latestDate;
- (NSArray *)allItems;

- (Event *)createEvent;
- (void)removeItem:(id)item;

@end
