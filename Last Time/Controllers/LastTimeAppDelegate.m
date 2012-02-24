//
//  LastTimeAppDelegate.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LastTimeAppDelegate.h"
#import "FolderListViewController.h"

@implementation LastTimeAppDelegate

@synthesize window = _window;
@synthesize rootFolderViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TESTFLIGHT
	[TestFlight takeOff:@"7dc090a5932acba7bcf3c281394f4a6a_NTAwNTgyMDExLTEyLTI3IDE2OjM1OjAyLjE4Mzg5MA"];
#endif
	
	[self versionCheck];

	rootFolderViewController = [[FolderListViewController alloc] init];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootFolderViewController];
	
	[[self window] setRootViewController:navController];
		
	[[self window] makeKeyAndVisible];
	return YES;
}

- (void)versionCheck
{
	int lastVersionRun = [[NSUserDefaults standardUserDefaults] integerForKey:@"PrefKeyLastVersionRun"];
	
	NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *intVersionString = [versionString	stringByReplacingOccurrencesOfString:@"." withString:@""];
	int newVersion = [intVersionString intValue];
	
	NSLog(@"%i", lastVersionRun);
	NSLog(@"%i", newVersion);
	
	if (lastVersionRun == 0) {
		[self removeRootEvents];
		
	}
	
	[[NSUserDefaults standardUserDefaults] setInteger:newVersion forKey:@"PrefKeyLastVersionRun"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)removeRootEvents
{
	@autoreleasepool {
		
		EventFolder *root = [[EventFolder alloc] initWithRoot:YES];
		
		// Gather up all the root events
		NSMutableArray *unfiledEvents = [[NSMutableArray alloc] init];
		
		for (id item in [root allItems]) {
			if ([item isMemberOfClass:[Event class]]) {
				[unfiledEvents addObject:item];
				
			}
		}
		
		// If there are any then make a new folder
		if ([unfiledEvents count] > 0) {
			EventFolder *unfiled = [[EventFolder alloc] init];
			unfiled.folderName = @"Unfiled";
			
			//Put the events in the folder
			unfiled.allItems = unfiledEvents;

			// add the new folder to the root
			[root addItem:unfiled];

			//Remove them from the root
			for (id item in unfiledEvents) {
				[root removeItem:item];
			}
			
			[root saveChanges];
			
		}
	}
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[rootFolderViewController rootFolder] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[rootFolderViewController rootFolder] saveChanges];

}
@end
