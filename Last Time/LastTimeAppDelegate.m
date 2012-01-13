//
//  LastTimeAppDelegate.m
//  Last Time
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LastTimeAppDelegate.h"
#import "LogEntryViewController.h"

@implementation LastTimeAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	NSLog(@"%@", application);
	NSLog(@"%@", launchOptions);
	
	LogEntryViewController *logEntryViewController = [[LogEntryViewController alloc] init];
	
	[[self window] setRootViewController:logEntryViewController];
	
	
	[[self window] makeKeyAndVisible];
	return YES;
}


@end
