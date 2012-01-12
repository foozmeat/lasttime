//
//  main.m
//  RandomLogEntryStore
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntryStore.h"

int main (int argc, const char * argv[])
{

	@autoreleasepool {
	    
		LogEntryStore *rles = [[LogEntryStore alloc] initWithRandomData];
		NSLog(@"%@", rles);
	}
    return 0;
}

