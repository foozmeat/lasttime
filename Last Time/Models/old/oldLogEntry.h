//
//  LogEntry.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OldLogEntry : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *logEntryDateOccured;
@property (nonatomic, strong) NSString *logEntryNote;
@property (nonatomic) CLLocationCoordinate2D logEntryLocation;
@property (nonatomic) float logEntryValue;
@property (nonatomic, strong) NSString *logEntryLocationString;


@end
