//
//  LastTimeAppDelegate.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LastTimeAppDelegate.h"
#import "FolderViewController.h"

@implementation LastTimeAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifndef DEBUG
	[TestFlight takeOff:@"7dc090a5932acba7bcf3c281394f4a6a_NTAwNTgyMDExLTEyLTI3IDE2OjM1OjAyLjE4Mzg5MA"];
#endif
	
	FolderViewController *folderViewController = [[FolderViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:folderViewController];
	
	[[self window] setRootViewController:navController];
		
	[[self window] makeKeyAndVisible];
	return YES;
}


@end
