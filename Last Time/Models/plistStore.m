//
//  plistStore.m
//  Last Time
//
//  Created by James Moore on 3/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "plistStore.h"

@implementation plistStore
@synthesize allItems;

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
	}
	
	return self;
}

@end
