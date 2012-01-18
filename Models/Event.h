//
//  Event.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

@interface Event : NSObject
{
	NSString *eventName;
	NSString *eventNote;
	NSMutableArray *logEntryCollection;
	BOOL needsSorting;
}

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *eventNote;
@property (nonatomic, strong) NSMutableArray *logEntryCollection;

- (id)initWithEventName:(NSString *)name
							eventNote:(NSString *)note
						 logEntries:(NSMutableArray *)entries;

- (NSString *)subtitle;
- (LogEntry *)latestEntry;
- (NSTimeInterval)averageInterval;
- (NSDate *)nextTime;
- (NSDate *)latestDate;
- (NSString *)lastStringInterval;
- (NSString *)objectName;

+ (Event *)randomEvent;

@end

