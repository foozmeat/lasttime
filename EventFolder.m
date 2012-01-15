//
//  EventFolder.m
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventFolder.h"
#import "Event.h"

@implementation EventFolder
@synthesize folderName, rootFolder;

- (id)init
{
	self = [super init];
	
	if (self) {
		eventCollection = [[NSMutableArray alloc] init];
		folderCollection = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithRandomDataAsRoot:(BOOL)root
{
	self = [super init];
	rootFolder = root;
	
	@autoreleasepool {
    
		if (self) {
			eventCollection = [[NSMutableArray alloc] init];
			
			@autoreleasepool {
				for (int i = 0; i < 3; i++) {
					Event *e = [[Event alloc] initWithRandomData];
					[eventCollection insertObject:e atIndex:i];
				}

				if (rootFolder) {
					folderCollection = [[NSMutableArray alloc] init];
					
					for (int i = 0; i < 3; i++) {
						EventFolder *f = [[EventFolder alloc] initWithRandomDataAsRoot:NO];
						[folderCollection insertObject:f atIndex:i];
					}
				}

				if (rootFolder) {
					folderName = @"ROOT";
				} else {
					NSArray *randomFolderList = [NSArray arrayWithObjects:@"Health", @"Pet", @"Car", @"Vacation", @"Diet", nil];
					
					long folderIndex = arc4random() % [randomFolderList count];
					folderName = [randomFolderList objectAtIndex:folderIndex];
				}						
			}
		}
		
	}
	return self;
}

-(NSString *)eventDescriptions
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	for (Event *event in eventCollection) {
		[output appendFormat:@"%@", [event description]];
	}
	return output;
}

-(NSString *)folderDescriptions
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	for (EventFolder *f in folderCollection) {
		[output appendFormat:@"%@", [f description]];
	}
	return output;
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendFormat:@"\n------ %@ Folder ------\n", folderName];
	[output appendFormat:@"\n------ Events ------\n%@", [self eventDescriptions]];
	if (rootFolder) {
		[output appendFormat:@"------ Folders ------%@", [self folderDescriptions]];
	}
	
	return output;
}
@end
