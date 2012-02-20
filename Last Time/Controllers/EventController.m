//
//  EventController.m
//  Last Time
//
//  Created by James Moore on 1/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventController.h"
#import "HistoryLogDetailController.h"
#import "HistoryLogCell.h"

@implementation EventController
@synthesize eventTableView;
@synthesize event, folder, rootFolder;

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
	
	if ([indexPath section] == kHistorySection) {
		
		HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];
		
		[hldc setLogEntry:[[event logEntryCollection] objectAtIndex:[indexPath row]]];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		[[self navigationController] pushViewController:hldc animated:YES];

	} else if ([indexPath section] == kAverageSection && ![event showAverage]) {
		[self addNewItem:self];
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
	if (section == kAverageSection) {
		return @"";
	} else if (section == kHistorySection) {
		return @"History";
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return NUM_EVENT_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kAverageSection && [event showAverage]) {
		return NUM_AVERAGE_SECTIONS;
	} else if (section == kAverageSection && ![event showAverage]) {
		return 1;
	} else if (section == kHistorySection) {
		return [[event logEntryCollection] count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	HistoryLogCell *historyLogCell = [tableView dequeueReusableCellWithIdentifier:@"HistoryLogCell"];
	
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.001];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																	reuseIdentifier:@"UITableViewCell"];
	}

	if (historyLogCell == nil) {
		UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"HistoryLogCell" bundle:nil];
		historyLogCell = (HistoryLogCell *)temporaryController.view;
	}
	
	
	if ([indexPath section] == kAverageSection && [event showAverage]) {
		
		switch ([indexPath row]) {
			case kAverageTime:
			{
				cell.textLabel.text = @"Average Duration";
				cell.detailTextLabel.text = [event averageStringInterval];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
			case kNextTime:
			{
				cell.textLabel.text = @"Next Time";
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				NSDateFormatter *df = [[NSDateFormatter alloc] init];
				
				[df setDateStyle:NSDateFormatterMediumStyle];
				[df setTimeStyle:NSDateFormatterNoStyle];
				
				cell.detailTextLabel.text = [df stringFromDate:[event nextTime]];
				break;
			}
			case kAverageValue:
			{
				cell.textLabel.text = @"Average Value";
				cell.detailTextLabel.text = [event averageStringValue];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
		}
		return cell;

	} else if ([indexPath section] == kAverageSection && ![event showAverage]) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
																	reuseIdentifier:@"UIDefaultTableViewCell"];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;

		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"Add another occurence to see the average";
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
		return cell;
	
	} else if ([indexPath section] == kHistorySection) {
		
		LogEntry *item = [[event logEntryCollection] objectAtIndex:[indexPath row]];
		
		historyLogCell.logEntryNoteCell.text = item.logEntryNote;
		historyLogCell.logEntryDateCell.text = [item stringFromLogEntryInterval];
		NSString *value = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[item logEntryValue]]];
		historyLogCell.logEntryValueCell.text = value;
		historyLogCell.locationMarker.hidden = ![item hasLocation];
		
		return historyLogCell;
		
	} else {
		cell.textLabel.text = @"Error";
		return cell;
	}
	
	
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	numberFormatter = [[NSNumberFormatter alloc] init];

	[[self navigationItem] setTitle:[event eventName]];
	[[self eventTableView] reloadData];

}

- (void)viewDidLoad
{
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
