//
//  LogEntry.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LogEntry : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *logEntryDateOccured;
@property (nonatomic, strong) NSString *logEntryNote;
@property (nonatomic) CLLocationCoordinate2D logEntryLocation;
@property (nonatomic) float logEntryValue;

- (id)initWithNote:(NSString *)logEntryNote
			 dateOccured:(NSDate *)logEntryDateOccured;

- (NSTimeInterval)secondsSinceNow;
- (NSString *)stringFromLogEntryInterval;
- (NSString *)subtitle;
- (BOOL)hasLocation;

+ (id)randomLogEntry;
+ (NSString *)stringFromInterval:(NSTimeInterval)interval
											withSuffix:(BOOL)suffix
												withDays:(BOOL)withDays;

@end
