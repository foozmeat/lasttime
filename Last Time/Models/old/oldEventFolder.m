//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "oldEventFolder.h"

@implementation OldEventFolder
@synthesize folderName, allItems;

#pragma mark - NSCoder
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:folderName forKey:@"folderName"];
	[aCoder encodeObject:allItems forKey:@"allItems"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self) {
		[self setAllItems:[aDecoder decodeObjectForKey:@"allItems"]];
		[self setFolderName:[aDecoder decodeObjectForKey:@"folderName"]];
		needsSorting = YES;
	}
	
	return self;
}

@end
