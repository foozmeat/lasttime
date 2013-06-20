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
	
	[self customizeAppearance];

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
    
#ifdef _USE_OS_7_OR_LATER
    [[UINavigationBar appearance] setBackgroundColor:[sm navBarBackgroundColor]];
    window.tintColor = [sm tintColor];
#else
    [[UINavigationBar appearance] setTintColor:[sm navBarBackgroundColor]];

    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil]];

    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys: [sm tintColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateNormal];

    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys: [sm tintColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateHighlighted];

    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    UIImage *backButton = [[UIImage imageNamed:@"clear_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

	[[UIToolbar appearance] setTintColor:[sm navBarBackgroundColor]];
//    [[UIBarButtonItem appearance] setTintColor:[sm tintColor]];

#endif
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
