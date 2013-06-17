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
#import "SegmentsController.h"
#import "TimelineViewController.h"
#import "Event.h"

@implementation LastTimeAppDelegate

@synthesize window;
//@synthesize splitViewController;
//@synthesize segmentsController, segmentedControl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TESTFLIGHT
#ifdef SEND_UDID
	[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
	[TestFlight takeOff:@"6bf62164-8b9b-46dc-b894-74ebd8c699d7"];
	[[Tapstream shared] setAccountName:@"jmoore" developerSecret:@"GeBwRwR6TceJmk2O_u5jAw"];
	[[Tapstream shared] fireEvent:@"first_launch" oneTimeOnly:YES];
#endif
	
	[self versionCheck];
	
	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	[self handleNotification:localNotif];
	
//	NSArray *viewControllers = [self segmentViewControllers];
//	NSArray *segmentTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Lists",@"Lists"), NSLocalizedString(@"Timeline",@"Timeline"), nil];
//
//	UIView *backgroundView = [[UIView alloc] initWithFrame: window.frame];
//	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.jpg"]];
//	[window addSubview:backgroundView];

//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//
//        UINavigationController *navigationController = [[UINavigationController alloc] init];
//        self.segmentsController = [[SegmentsController alloc] initWithNavigationController:navigationController viewControllers:viewControllers];
//        
//        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
//        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
//
//        [self.segmentedControl addTarget:self.segmentsController
//                                  action:@selector(indexDidChangeForSegmentedControl:)
//                        forControlEvents:UIControlEventValueChanged];
//        
//        [self firstUserExperience];
//
//        window.rootViewController = navigationController;
//    [window addSubview:navigationController.view];

//	} else {
//		FolderListViewController *masterViewController = [viewControllers objectAtIndex:0];
//		
//		UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
//
//		EventController *detailViewController = masterViewController.detailViewController;
//		UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
//		
//		self.segmentsController = [[SegmentsController alloc] initWithNavigationController:masterNavigationController viewControllers:viewControllers];
//    
//        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
//        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
//        
//        [self.segmentedControl addTarget:self.segmentsController
//                                  action:@selector(indexDidChangeForSegmentedControl:)
//                        forControlEvents:UIControlEventValueChanged];
//        
//        [self firstUserExperience];
//                    
//		self.splitViewController = [[MGSplitViewController alloc] init];
//		self.splitViewController.showsMasterInPortrait = YES;
//
//		self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
//		
//		self.window.rootViewController = self.splitViewController;
//
//	}
	[self customizeAppearance];

//	[window makeKeyAndVisible];
	return YES;
}

//- (NSArray *)segmentViewControllers {
//	FolderListViewController *lists = [[FolderListViewController alloc] init];
//	TimelineViewController *timeline = [[TimelineViewController alloc] init];
//	EventController *detailViewController = [[EventController alloc] init];
//
//	lists.detailViewController = detailViewController;
//	timeline.detailViewController = detailViewController;
//	
//	NSArray *viewControllers = [NSArray arrayWithObjects:lists, timeline, nil];
//
//	return viewControllers;
//}

//- (void)firstUserExperience {
//	self.segmentedControl.selectedSegmentIndex = 0;
//	[self.segmentsController indexDidChangeForSegmentedControl:self.segmentedControl];
//}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)localNotification {
	[self handleNotification:localNotification];
}

- (void)handleNotification:(UILocalNotification *)localNotification
{
#ifdef DEBUG
	NSLog(@"Handling notifications");
#endif
	
#ifdef DEBUG
	if (localNotification) {
		NSString *uuid = [localNotification.userInfo objectForKey:@"UUID"];
		NSLog(@"Found notification %@", uuid);

//		Event *event = [[EventStore defaultStore] eventForUUID:uuid];
	}
#endif

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

- (void)customizeAppearance
{
	
//	[[UIBarButtonItem appearance] setTintColor:[UIColor blueColor]];

    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [UIFont fontWithName:@"HelveticaNeue-Medium" size:0.0], UITextAttributeFont,
      nil]];

    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:21/255.0 green:126/255.0 blue:252/255.0 alpha:1.0], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0], UITextAttributeFont,
      nil]
     forState:UIControlStateNormal];

    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:21/255.0 green:126/255.0 blue:252/255.0 alpha:0.5], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0], UITextAttributeFont,
      nil]
    forState:UIControlStateHighlighted];

	[[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

	UIImage *backButton = [[UIImage imageNamed:@"clear_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0]];
//    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];

//	[[UITabBar appearance] setTintColor:[UIColor brownColor]];

//	UIImage *barButton = [[UIImage imageNamed:@"leather_navbar_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
//


//	[[UISegmentedControl appearance] setTintColor:[UIColor brownColor]];

//	UIImage *segmentSelected = [[UIImage imageNamed:@"leather_seg_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
//	UIImage *segmentUnselected = [[UIImage imageNamed:@"leather_seg_uns.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
//	UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"leather_seg_sel-uns.png"];
//	UIImage *segUnselectedSelected = [UIImage imageNamed:@"leather_seg_uns-sel.png"];
//	UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"leather_seg_uns-uns.png"];

//	[[UISegmentedControl appearance] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//	[[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

//	[[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
//															 forLeftSegmentState:UIControlStateNormal
//																 rightSegmentState:UIControlStateNormal
//																				barMetrics:UIBarMetricsDefault];
//	[[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
//															 forLeftSegmentState:UIControlStateSelected
//																 rightSegmentState:UIControlStateNormal
//																				barMetrics:UIBarMetricsDefault];
//
//	[[UISegmentedControl appearance] setDividerImage:segUnselectedSelected
//															 forLeftSegmentState:UIControlStateNormal
//																 rightSegmentState:UIControlStateSelected
//																				barMetrics:UIBarMetricsDefault];



    // iPhone
//    UIImage *navBarImage = [UIImage imageNamed:@"leather_navbar.png"];
//    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
//
//    UIImage* tabBarBackground = [UIImage imageNamed:@"leather_toolbar.png"];
//    [[UIToolbar appearance] setBackgroundImage:tabBarBackground forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];


}

- (BOOL)application:(UIApplication *)application
						openURL:(NSURL *)url
	sourceApplication:(NSString *)sourceApplication
				 annotation:(id)annotation {
//	NSLog(@"url recieved: %@", url);
//	NSLog(@"scheme: %@", [url scheme]);
//	NSLog(@"query string: %@", [url query]);

		// handle these things in your app here
	return YES;
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
