//
//  LastTimeAppDelegate.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LastTimeAppDelegate.h"
#import "EventStore.h"
#import "Event.h"

#if CREATING_SCREENSHOTS
#import "LTScreenshotManager.h"
#import "FolderListViewController.h"
#import "LTSlideViewController.h"
#endif

@implementation LastTimeAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TESTFLIGHT
#ifdef BETA
	[TestFlight takeOff:@"63a0aabe-c8e3-46a8-8041-0860cb5ea3e9"];
#else
	[TestFlight takeOff:@"6bf62164-8b9b-46dc-b894-74ebd8c699d7"];
#endif
#endif

	[self versionCheck];

	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	[self handleNotification:localNotif];

	[self customizeAppearance];

#if CREATING_SCREENSHOTS
    SASlideMenuRootViewController *myStoryBoardInitialViewController = (SASlideMenuRootViewController *) self.window.rootViewController;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        LTScreenshotManager *screenshotManager = [[LTScreenshotManager alloc] init];
        [screenshotManager setInitialViewController:myStoryBoardInitialViewController];
        [screenshotManager takeScreenshots];
    });
#endif

	return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)localNotification {
	[self handleNotification:localNotification];
}

- (void)handleNotification:(UILocalNotification *)localNotification
{

	DLog(@"Handling notifications");

#ifdef DEBUG
	if (localNotification) {
		NSString *uuid = [localNotification.userInfo objectForKey:@"UUID"];
		DLog(@"Found notification %@", uuid);

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
	LTStyleManager *sm = [LTStyleManager manager];

	[[UINavigationBar appearance] setTintColor:[sm tintColor]];
	[[UIBarButtonItem appearance] setTintColor:[sm tintColor]];

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
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
