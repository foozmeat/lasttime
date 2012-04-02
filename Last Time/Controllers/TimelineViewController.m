//
//  TimelineViewController.m
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TimelineViewController.h"

@interface TimelineViewController ()

@end

@implementation TimelineViewController
@synthesize managingViewController, detailViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController detailViewController:dViewController
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.managingViewController = aViewController;
		self.detailViewController = dViewController;
	}
	return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	CGRect frame = self.tableView.frame;
	frame.origin.x = frame.origin.y = 0.0f;
	self.tableView.frame = frame;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
