//
//  NSString+UUID.m
//  Last Time
//
//  Created by James Moore on 6/28/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *) stringWithUUID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
																				//get the string representation of the UUID
	NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return uuidString;
}


@end
