//
//  main.m
//  DurationTest
//
//  Created by James Moore on 2/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

int main(int argc, const char * argv[])
{

	@autoreleasepool {
		
		LogEntry *le = nil;
		
		for (int i=0; i < 20; i++) {
			le = [[LogEntry alloc] initWithNote:@"" dateOccured:[[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24*i]];
			NSLog(@"%@ -> %f -> %@", [le logEntryDateOccured], [le secondsSinceNow], [le stringFromLogEntryInterval]);
		}

		for (int i=0; i < 20; i++) {
			le = [[LogEntry alloc] initWithNote:@"" dateOccured:[[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24*i]];
			NSLog(@"%@ -> %f -> %@", [le logEntryDateOccured], [le secondsSinceNow], [le stringFromLogEntryInterval]);
		}
}
    return 1;
}

