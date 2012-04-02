//
//  LastTimeAppDelegate.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LastTimeAppDelegate.h"
#import "FolderListViewController.h"
#import "EventController.h"
#import "EventStore.h"
#import "MGSplitViewController.h"
#import "SegmentManagingViewController.h"

@implementation LastTimeAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TESTFLIGHT
	[TestFlight takeOff:@"7dc090a5932acba7bcf3c281394f4a6a_NTAwNTgyMDExLTEyLTI3IDE2OjM1OjAyLjE4Mzg5MA"];
#endif
	
	[self versionCheck];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		SegmentManagingViewController *masterViewController = [[SegmentManagingViewController alloc] init];
		
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
//		[self.window addSubview:self.navigationController.view];

		self.window.rootViewController = self.navigationController;

	} else {
		SegmentManagingViewController *masterViewController = [[SegmentManagingViewController alloc] init];
		
		UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];

		EventController *detailViewController = [[EventController alloc] init];
		UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
		
		masterViewController.detailViewController = detailViewController;

		self.splitViewController = [[MGSplitViewController alloc] init];
		self.splitViewController.showsMasterInPortrait = YES;
		
//		self.splitViewController.delegate = detailViewController;
		self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
		
		self.window.rootViewController = self.splitViewController;

	}
	
	[[self window] makeKeyAndVisible];
	return YES;
}

- (void)versionCheck
{
	int lastVersionRun = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastVersionRun"];
	if (lastVersionRun >= 10 && lastVersionRun <= 99) {
		lastVersionRun *= 10;
	}
			
	NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *intVersionString = [versionString	stringByReplacingOccurrencesOfString:@"." withString:@""];
	int newVersion = [intVersionString intValue];

	if (newVersion >= 10 && newVersion <= 99) {
		newVersion *= 10;
	}
			
	if (newVersion != lastVersionRun) {
		NSLog(@"Last Version: %i, New Version: %i", lastVersionRun, newVersion);
		[[EventStore defaultStore] migrateDataFromVersion:lastVersionRun];
		[[NSUserDefaults standardUserDefaults] setInteger:newVersion forKey:@"LastVersionRun"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[EventStore defaultStore] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[EventStore defaultStore] saveChanges];

}
@end
