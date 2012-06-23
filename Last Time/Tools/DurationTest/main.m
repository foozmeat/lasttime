//
//  main.m
//  DurationTest
//
//  Created by James Moore on 2/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

int main(int argc, const char * argv[])
{

	NSManagedObjectContext *context = [NSManagedObjectContext new];
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];

	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
													 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	
//	NSString *path = pathInDocumentDirectory(@"LastTime.sqlite");
//	NSURL *storeURL = [NSURL fileURLWithPath:path];
	
	NSError *error = nil;
	if (![psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error]) {
		[NSException raise:@"Open failed"
								format:@"Reason: %@ %@", [error localizedDescription], [error userInfo]];
	}
	
	if (psc != nil)
	{
		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:psc];
	}

	
	@autoreleasepool {
		
		LogEntry *le = nil;
		
		for (int i=0; i < 10; i++) {
			le = (LogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"LogEntry" inManagedObjectContext:context];
			le.logEntryDateOccured = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24*i];
			NSLog(@"%@ -> %f -> %@", [le logEntryDateOccured], [le secondsSinceNow], [le stringFromLogEntryInterval]);
		}

	}
    return 1;
}

