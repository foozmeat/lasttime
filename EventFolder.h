//
//  EventFolder.h
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface EventFolder : NSObject
{
	NSString *folderName;
	NSMutableArray *eventCollection;
	NSMutableArray *folderCollection;
	BOOL rootFolder;
}

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic) BOOL rootFolder;

- (id)initWithRandomDataAsRoot:(BOOL)root;

@end
