//
//  main.m
//  RandomEventFolder
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventFolder.h"

int main (int argc, const char * argv[])
{

	// Avoid warnings
	argc = argc;
	argv = argv;
	

	@autoreleasepool {
	    
		EventFolder *ef = [[EventFolder alloc] initWithRandomDataAsRoot:YES];
		NSLog(@"%@", ef);
	    
	}
    return 0;
}

