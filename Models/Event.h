//
//  Event.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntryStore.h"

@interface Event : NSObject
{
	NSString *eventName;
	NSString *eventNote;
	LogEntryStore *logEntryCollection;
}

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *eventNote;
@property (nonatomic, strong) LogEntryStore *logEntryCollection;

- (id)initWithRandomData;
- (NSString *)subtitle;

@end

