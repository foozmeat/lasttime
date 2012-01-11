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
	NSMutableArray *log;
	NSTimeInterval *avgTime;
	NSTimeInterval *meanTime;
	NSDate *lastTime;
	NSDate *nextTime;
}

@property NSTimeInterval *avgTime;
@property NSTimeInterval *meanTime;

- (NSArray *)allLogEntries;
- (NSArray *)nearbyEntries;
- (LogEntry *)latestEntry;
- (NSTimeInterval *)lastDuration;
- (NSDate *)nextTime;
- (CLLocationCoordinate2D *)lastLocation;

@end
