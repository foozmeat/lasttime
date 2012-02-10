//
//  EventController.m
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventController.h"
#import "HistoryLogController.h"
#import "HistoryLogDetailController.h"

@implementation EventController
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

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

#pragma mark Model methods
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
	
	if (([indexPath section] == 2 && [event showAverage]) || ([indexPath section] == 1 && ![event showAverage]) ) {
		
		HistoryLogController *hlc = [[HistoryLogController alloc] init];
		[hlc setEvent:event];
		[[self navigationController] pushViewController:hlc animated:YES];

	}
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"Previously";
	} else if (section == 1) {
		return @"";
	} else if (section == 2) {
		return @"";
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([event showAverage]) {
		return 3;
	} else {
		return 2;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 1;
	} else if (section == 1 && [event showAverage]) {
		return 2;
	} else if (section == 2 || ![event showAverage]) {
		return 1;
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
	}
	
	if ([indexPath section] == 0) {
		cell.textLabel.text = [event subtitle];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else if ([indexPath section] == 1 && [event showAverage]) {
		
		if ([indexPath row] == 0) {
			cell.textLabel.text = @"Average";
			cell.detailTextLabel.text = [event averageStringInterval];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

		} else {
			cell.textLabel.text = @"Next Time";

			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			
			[df setDateStyle:NSDateFormatterMediumStyle];
			[df setTimeStyle:NSDateFormatterNoStyle];
			
			cell.detailTextLabel.text = [df stringFromDate:[event nextTime]];
			
		}
	} else if ([indexPath section] == 2 || ![event showAverage]) {
		cell.textLabel.text = [[NSString alloc] initWithFormat:@"History Log (%i)", [[event logEntryCollection] count]];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	
	return cell;
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[self navigationItem] setTitle:[event eventName]];
	[[self tableView] reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
