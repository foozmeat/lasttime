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
#import <HockeySDK/HockeySDK.h>

@implementation LastTimeAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifndef CREATING_SCREENSHOTS
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"5a45072beb3c9b563e69a3515f0bc8fd"];
	[[BITHockeyManager sharedHockeyManager] startManager];
	[self versionCheck];
#endif

	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	[self handleNotification:localNotif];

	[self customizeAppearance];

#ifndef CREATING_SCREENSHOTS
	NSString *path = pathInDocumentDirectory(@"LastTime.sqlite");
	NSURL *storeURL = [NSURL fileURLWithPath:path];

	NSLog(@"Store URL: %@", storeURL.path);
#endif
	
#if CREATING_SCREENSHOTS

	NSError *error;
	NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"LastTimeDemo" ofType:@"sqlite"];
	NSURL *dataFile = [NSURL fileURLWithPath:dataFilePath];
//	NSLog(@"Data file: %@", dataFile.path);

	NSString *path = pathInDocumentDirectory(@"LastTimeDemo.sqlite");
	NSURL *storeURL = [NSURL fileURLWithPath:path];

//	NSLog(@"Dest URL: %@", storeURL.path);

	NSFileManager *fm = [NSFileManager defaultManager];

	NSLog(@"Installing demo data file");
	[fm copyItemAtURL:dataFile toURL:storeURL error:&error];

	if (error) {
//		NSLog(@"Error copying: %@", error);
	}

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
	NSInteger lastVersionRun = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastVersionRun"];
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
		NSLog(@"Last Version: %li, New Version: %i", (long)lastVersionRun, newVersion);
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
