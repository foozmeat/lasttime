//
//  plistStore.h
//  Last Time
//
//  Created by James Moore on 3/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistStore : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *allItems;


+ (PlistStore *)defaultStore;
- (void)fetchItemsIfNecessary;

@end
