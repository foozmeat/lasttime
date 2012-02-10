//
//  HistoryLogController.m
//  Last Time
//
//  Created by James Moore on 1/25/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HistoryLogController.h"
#import "HistoryLogDetailController.h"

@implementation HistoryLogController
@synthesize event;

- (id) init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	if (self) {
		UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																																				 target:self 
																																				 action:@selector(addNewItem:)];
		
		[[self navigationItem] setRightBarButtonItem:bbi];		
		[[self navigationItem] setTitle:[event eventName]];
		
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[self tableView] reloadData];
}

- (void)addNewItem:(id)sender
{
	HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];

	[hldc setLogEntry:[[LogEntry alloc] init]];
	[hldc setEvent:event];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:hldc];
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	

}

#pragma mark TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];
	
	[hldc setLogEntry:[[event logEntryCollection] objectAtIndex:[indexPath row]]];
	
	[[self navigationController] pushViewController:hldc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[event logEntryCollection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
	}
	
	id item = [[event logEntryCollection] objectAtIndex:[indexPath row]];
		
	[[cell textLabel] setText:[item logEntryNote]];
	[[cell detailTextLabel] setText:[item subtitle]];
	
	return cell;
}

@end
