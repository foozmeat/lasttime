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
#import "SegmentsController.h"
#import "TimelineViewController.h"

@implementation LastTimeAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize segmentsController, segmentedControl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TESTFLIGHT
	[TestFlight takeOff:@"7dc090a5932acba7bcf3c281394f4a6a_NTAwNTgyMDExLTEyLTI3IDE2OjM1OjAyLjE4Mzg5MA"];
#endif
	
	[self versionCheck];

	NSArray *viewControllers = [self segmentViewControllers];
	NSArray *segmentTitles = [[NSArray alloc] initWithObjects:@"Lists", @"Timeline", nil];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    self.segmentsController = [[SegmentsController alloc] initWithNavigationController:navigationController viewControllers:viewControllers];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [self.segmentedControl addTarget:self.segmentsController
                              action:@selector(indexDidChangeForSegmentedControl:)
                    forControlEvents:UIControlEventValueChanged];
    
    [self firstUserExperience];
    
    [window addSubview:navigationController.view];

	} else {
		FolderListViewController *masterViewController = [viewControllers objectAtIndex:0];
		
		UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];

		EventController *detailViewController = masterViewController.detailViewController;
		UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
		
		self.segmentsController = [[SegmentsController alloc] initWithNavigationController:masterNavigationController viewControllers:viewControllers];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [self.segmentedControl addTarget:self.segmentsController
                              action:@selector(indexDidChangeForSegmentedControl:)
                    forControlEvents:UIControlEventValueChanged];
    
    [self firstUserExperience];
				
		self.splitViewController = [[MGSplitViewController alloc] init];
		self.splitViewController.showsMasterInPortrait = YES;
		
		self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
		
		self.window.rootViewController = self.splitViewController;

	}
	
	[window makeKeyAndVisible];
	return YES;
}

- (NSArray *)segmentViewControllers {
	FolderListViewController *lists = [[FolderListViewController alloc] init];
	TimelineViewController *timeline = [[TimelineViewController alloc] init];
	EventController *detailViewController = [[EventController alloc] init];

	lists.detailViewController = detailViewController;
	timeline.detailViewController = detailViewController;
	
	NSArray *viewControllers = [NSArray arrayWithObjects:lists, timeline, nil];

	return viewControllers;
}

- (void)firstUserExperience {
	self.segmentedControl.selectedSegmentIndex = 0;
	[self.segmentsController indexDidChangeForSegmentedControl:self.segmentedControl];
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
