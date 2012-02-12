//
//  FileHelpers.m
//  Last Time
//
//  Created by James Moore on 2/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FileHelpers.h"

NSString *pathInDocumentDirectory(NSString *filename)
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																																		 NSUserDomainMask, YES);
	
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	
	return [documentDirectory	stringByAppendingPathComponent:filename];
	
}
