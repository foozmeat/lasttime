//
//  LogEntry.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LogEntry : NSObject
{
	NSDate *logEntryDateOccured;
	NSString *logEntryNote;
	CLLocationCoordinate2D logEntryLocation;
}

@property (nonatomic, strong) NSDate *logEntryDateOccured;
@property (nonatomic, strong) NSString *logEntryNote;
@property (nonatomic, readonly) CLLocationCoordinate2D logEntryLocation;

- (id)initWithNote:(NSString *)logEntryNote
	 dateOccured:(NSDate *)logEntryDateOccured
			location:(CLLocationCoordinate2D)logEntryLocation;

- (NSTimeInterval)secondsSinceNow;
- (NSString *)stringFromLogEntryInterval;
- (NSString *)subtitle;

+ (id)randomLogEntry;
+ (NSString *)stringFromInterval:(NSTimeInterval) interval;

@end
