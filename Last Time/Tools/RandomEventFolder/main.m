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

	@autoreleasepool {
	    
		EventFolder *ef = [EventFolder randomFolderWithRoot:YES];
		NSLog(@"%@", ef);
	    
	}
    return 0;
}

