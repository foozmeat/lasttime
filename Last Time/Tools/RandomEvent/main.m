//
//  main.m
//  RandomEvent
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

int main (int argc, const char * argv[])
{

	// Avoid warnings
	argc = argc;
	argv = argv;
	
	@autoreleasepool {
		
		Event *e = [[Event alloc] initWithRandomData];
		NSLog(@"%@", e);
	}
	return 0;
}

