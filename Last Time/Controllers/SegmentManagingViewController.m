//
//  SegmentManagingViewController.m
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "SegmentManagingViewController.h"
#import "FolderListViewController.h"
#import "TimelineViewController.h"

@interface SegmentManagingViewController ()

@property (nonatomic, strong, readwrite) UISegmentedControl * segmentedControl;
@property (nonatomic, strong, readwrite) UIViewController *activeViewController;
@property (nonatomic, strong, readwrite) NSArray *segmentedViewControllers;

- (void)didChangeSegmentControl:(UISegmentedControl *)control;
- (NSArray *)segmentedViewControllerContent;

@end

@implementation SegmentManagingViewController

@synthesize segmentedControl, activeViewController, segmentedViewControllers, detailViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.segmentedViewControllers = [self segmentedViewControllerContent];
	
	NSArray *segmentTitles = [[NSArray alloc] initWithObjects:@"Lists", @"Timeline", nil];
	
	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
	self.segmentedControl.selectedSegmentIndex = 0;
	self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	
	[self.segmentedControl addTarget:self
														action:@selector(didChangeSegmentControl:)
									forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView = self.segmentedControl;
	
	[self didChangeSegmentControl:self.segmentedControl]; // kick everything off
}

- (NSArray *)segmentedViewControllerContent {
	UIViewController *lists = [[FolderListViewController alloc] initWithParentViewController:self 
																																			detailViewController:detailViewController];
	
	UIViewController *timeline = [[TimelineViewController alloc] initWithParentViewController:self 
																																			 detailViewController:detailViewController];
	
	NSArray *controllers = [NSArray arrayWithObjects:lists, timeline, nil];
	
	return controllers;
}

- (void)didChangeSegmentControl:(UISegmentedControl *)control {
	if (self.activeViewController) {
		[self.activeViewController viewWillDisappear:NO];
		[self.activeViewController.view removeFromSuperview];
		[self.activeViewController viewDidDisappear:NO];
	}
	
	self.activeViewController = [self.segmentedViewControllers objectAtIndex:control.selectedSegmentIndex];
	
	[self.activeViewController viewWillAppear:NO];
	[self.view addSubview:self.activeViewController.view];
	[self.activeViewController viewDidAppear:NO];
	
	NSString *segmentTitle = [control titleForSegmentAtIndex:control.selectedSegmentIndex];
	self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:segmentTitle style:UIBarButtonItemStylePlain target:nil action:nil];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
	for (UIViewController *viewController in self.segmentedViewControllers) {
		[viewController didReceiveMemoryWarning];
	}
}

- (void)viewDidUnload {
	self.segmentedControl = nil;
	self.segmentedViewControllers = nil;
	self.activeViewController = nil;
	
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.activeViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.activeViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.activeViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.activeViewController viewDidDisappear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewDidAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewWillAppear:animated];
}

@end
