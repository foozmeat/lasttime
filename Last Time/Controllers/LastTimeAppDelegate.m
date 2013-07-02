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
#ifdef SEND_UDID
	[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif

#ifdef BETA
	[TestFlight takeOff:@"63a0aabe-c8e3-46a8-8041-0860cb5ea3e9"];
#else
	[TestFlight takeOff:@"6bf62164-8b9b-46dc-b894-74ebd8c699d7"];
#endif
	[[Tapstream shared] setAccountName:@"jmoore" developerSecret:@"GeBwRwR6TceJmk2O_u5jAw"];
	[[Tapstream shared] fireEvent:@"first_launch" oneTimeOnly:YES];
#endif

	[self versionCheck];

	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	[self handleNotification:localNotif];

	[self customizeAppearance];

#if CREATING_SCREENSHOTS
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        LTScreenshotManager *screenshotManager = [[LTScreenshotManager alloc] init];
        SASlideMenuRootViewController *myStoryBoardInitialViewController = (SASlideMenuRootViewController *) self.window.rootViewController;
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
	LTStyleManager *sm = [LTStyleManager manager];

	[[UINavigationBar appearance] setTintColor:[sm navBarBackgroundColor]];

	[[UINavigationBar appearance] setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys:
		[UIColor blackColor], UITextAttributeTextColor,
		[UIColor clearColor], UITextAttributeTextShadowColor,
		[sm mediumFontWithSize:0.0], UITextAttributeFont,
		nil]];

	[[UIBarButtonItem appearance] setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys:
		[sm tintColor], UITextAttributeTextColor,
		[UIColor clearColor], UITextAttributeTextShadowColor,
		[sm mediumFontWithSize:16.0], UITextAttributeFont,
		nil] forState:UIControlStateNormal];

	[[UIBarButtonItem appearance] setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys:
		[sm disabledTextColor], UITextAttributeTextColor,
		[UIColor clearColor], UITextAttributeTextShadowColor,
		[sm mediumFontWithSize:16.0], UITextAttributeFont,
		nil] forState:UIControlStateDisabled];

	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonTitlePositionAdjustment:UIOffsetMake(0.0,-3.0) forBarMetrics:UIBarMetricsDefault];

	[[UIBarButtonItem appearance] setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys:
		[sm tintColor], UITextAttributeTextColor,
		[UIColor clearColor], UITextAttributeTextShadowColor,
		[sm mediumFontWithSize:16.0], UITextAttributeFont,
		nil] forState:UIControlStateHighlighted];

	[[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:[sm backArrowImage] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

	[[UIToolbar appearance] setTintColor:[sm navBarBackgroundColor]];

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
