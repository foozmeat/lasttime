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

	NSLog(@"%@", application);
	NSLog(@"%@", launchOptions);
	
	FolderViewController *folderViewController = [[FolderViewController alloc] init];
	
	[[self window] setRootViewController:folderViewController];
	
	
	[[self window] makeKeyAndVisible];
	return YES;
}


@end
