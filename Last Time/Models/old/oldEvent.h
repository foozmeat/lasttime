//
//  Event.h
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "oldLogEntry.h"

@class OldEventFolder;

@interface OldEvent : NSObject <NSCoding>
{
	NSNumberFormatter *nf;
}
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSMutableArray *logEntryCollection;

@property (nonatomic) BOOL needsSorting;


@end

