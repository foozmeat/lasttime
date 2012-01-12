//
//  LogEntryStore.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

@interface LogEntryStore : NSObject
{
	NSMutableArray *logEntries;
	NSTimeInterval avgTime;
	NSTimeInterval meanTime;
	NSDate *nextTime;
	BOOL needsSorting;
}

@property (nonatomic) NSTimeInterval avgTime;
@property (nonatomic) NSTimeInterval meanTime;
@property (nonatomic, strong) NSDate *nextTime;

- (id)initWithRandomData;
- (NSArray *)allLogEntries;
- (LogEntry *)latestEntry;


//- (NSArray *)nearbyEntries;
//- (NSTimeInterval *)lastDuration;
//- (NSDate *)nextTime;
//- (CLLocationCoordinate2D *)lastLocation;
//
@end
