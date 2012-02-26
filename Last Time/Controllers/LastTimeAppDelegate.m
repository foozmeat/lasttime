//
//  LastTimeAppDelegate.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LastTimeAppDelegate.h"
#import "FolderListViewController.h"
#import "EventStore.h"

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
		[[EventStore defaultStore] removeRootEvents];
		
	}
	
	[[NSUserDefaults standardUserDefaults] setInteger:newVersion forKey:@"PrefKeyLastVersionRun"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//	[[rootFolderViewController rootFolder] saveChanges];
	[[EventStore defaultStore] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//	[[rootFolderViewController rootFolder] saveChanges];
	[[EventStore defaultStore] saveChanges];

}
@end
