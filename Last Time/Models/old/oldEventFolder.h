//
//  EventFolder.h
//  Last Time
//
//  Created by James Moore on 1/13/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"oldEvent.h"

@interface OldEventFolder : NSObject <NSCoding>
{
	BOOL needsSorting;
}

@property (nonatomic, strong) NSMutableArray *allItems;;
@property (nonatomic, strong) NSString *folderName;


@end