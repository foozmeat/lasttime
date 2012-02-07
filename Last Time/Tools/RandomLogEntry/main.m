//
//  main.m
//  Last Time
//
//  Created by James Moore on 12/27/11.
//  Copyright (c) 2011 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

int main (int argc, const char * argv[])
{
	@autoreleasepool {
		
		// create a mutable array
		NSMutableArray *entries = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < 10; i++) {
			LogEntry *le = [LogEntry randomLogEntry];
			[entries addObject:le];
		}
		
		for (LogEntry *entry in entries)
			NSLog(@"%@", entry);
		
	}
	return 0;
}

