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
	BOOL needsSorting;
}

- (id)initWithRandomData;
- (LogEntry *)latestEntry;
- (NSTimeInterval)averageInterval;
- (NSDate *)nextTime;

//- (NSArray *)nearbyEntries;
//- (NSTimeInterval *)lastDuration;
//- (CLLocationCoordinate2D *)lastLocation;
//
@end
