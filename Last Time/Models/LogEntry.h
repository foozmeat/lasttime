//
//  LogEntry.h
//  Last Time
//
//  Created by James Moore on 3/14/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Event;

@interface LogEntry : NSManagedObject
{

}
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSDate *logEntryDateOccured;
@property (nonatomic, strong) NSString *logEntryLocationString;
@property (nonatomic, strong) NSString *logEntryNote;
@property (nonatomic, strong) NSNumber *logEntryValue;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSString *sectionIdentifier;
@property (nonatomic, strong) NSString *primitiveSectionIdentifier;
@property (nonatomic, strong) NSDate *primitiveLogEntryDateOccured;


- (NSTimeInterval)secondsSinceNow;
- (NSString *)stringFromLogEntryInterval;
- (NSString *)subtitle;
- (BOOL)hasLocation;
- (void)reverseLookupLocation;
//+ (id)randomLogEntry;
+ (NSString *)stringFromInterval:(NSTimeInterval)interval
											withSuffix:(BOOL)suffix
												withDays:(BOOL)withDays;
- (void)setLogEntryLocation:(CLLocationCoordinate2D)location;
- (NSString *)locationString;
@end
