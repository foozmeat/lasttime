//
//  EventController.m
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventController.h"
#import "HistoryLogDetailController.h"

@implementation EventController
@synthesize eventTableView;
@synthesize event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

#pragma mark - Model methods
- (IBAction)addNewItem:(id)sender
{
	HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];
	
	[hldc setLogEntry:[[LogEntry alloc] init]];
	[hldc setEvent:event];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:hldc];
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (([indexPath section] == 1 && [event showAverage]) || 
			([indexPath section] == 0 && ![event showAverage])) {
		
		HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];
		
		[hldc setLogEntry:[[event logEntryCollection] objectAtIndex:[indexPath row]]];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		[[self navigationController] pushViewController:hldc animated:YES];

	}
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id item = [[event logEntryCollection] objectAtIndex:[indexPath row]];
		[event removeItem:item];
		
		[tableView reloadData];
//		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
				
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0 && [event showAverage]) {
		return @"";
	} else if ((section == 0 && ![event showAverage]) || 
						 (section == 1 && [event showAverage])) {
		return @"History";
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	
	if ([event showAverage]) {
		return 2;
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0 && [event showAverage]) {
		return 2;
	} else if ((section == 0 && ![event showAverage]) || 
						 (section == 1 && [event showAverage])) {
		return [[event logEntryCollection] count];
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
	
	if ([indexPath section] == 0 && [event showAverage]) {
		
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
	} else if (([indexPath section] == 0 && ![event showAverage]) || 
						 ([indexPath section] == 1 && [event showAverage])) {
		
		id item = [[event logEntryCollection] objectAtIndex:[indexPath row]];
		
		[[cell textLabel] setText:[item logEntryNote]];
		[[cell detailTextLabel] setText:[item subtitle]];

	}
	
	
	return cell;
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[self navigationItem] setTitle:[event eventName]];
	[[self eventTableView] reloadData];

}

- (void)viewDidLoad
{
	[self setEventTableView:nil];
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
	[self setEventTableView:nil];
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
