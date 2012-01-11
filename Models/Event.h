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
	NSString *name;
	NSString *note;
	LogEntryStore *logEntryCollection;
}
@end
