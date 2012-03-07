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
#import "WEPopoverController.h"
#import "LogEntry.h"
#import "Event.h"

@implementation EventController
@synthesize eventTableView;
@synthesize event = _event; 
@synthesize folder;
@synthesize averagePopover;

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

-(void)showAveragePopup
{
#if TESTFLIGHT
	[TestFlight passCheckpoint:@"Saw Average Popup"];
#endif
	if (!self.averagePopover) {

		//		Create a label with custom text 
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
		[label setText:@"Add another entry to this event."];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor whiteColor]];
		[label setTextAlignment:UITextAlignmentCenter];

		UIFont *font = [UIFont boldSystemFontOfSize:11];
		[label setFont:font];
		CGSize size = [label.text sizeWithFont:font];
		CGRect frame = CGRectMake(0, 0, size.width + 10, size.height + 10); // add a bit of a border around the text
		label.frame = frame;
		
		//  place inside a temporary view controller and add to popover
		UIViewController *viewCon = [[UIViewController alloc] init];
		viewCon.view = label;
		viewCon.contentSizeForViewInPopover = frame.size;       // Set the content size

		averagePopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
		[averagePopover setDelegate:self];
	}
	
	if([averagePopover isPopoverVisible]) {
		[averagePopover dismissPopoverAnimated:YES];
		[averagePopover setDelegate:nil];
		averagePopover = nil;
	} else {
		
		[averagePopover presentPopoverFromRect:CGRectMake(298, 445, 1, 1)
																		inView:self.navigationController.view
									permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
																	animated:YES];
	}
}

#pragma mark -
- (void)setEvent:(Event *)event
{
	if (_event != event) {
		_event = event;
		
		// Update the view.
		[[self navigationItem] setTitle:[_event eventName]];
		[eventTableView reloadData];
	}

}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	averagePopover = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

#pragma mark - Model methods
- (IBAction)addNewItem:(id)sender
{
	HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];
	
	[hldc setLogEntry:[[LogEntry alloc] init]];
	[hldc setEvent:_event];
	[hldc setDelegate:self];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:hldc];

	if ([[UIDevice currentDevice] userInterfaceIdiom	] == UIUserInterfaceIdiomPad) {
		[newNavController setModalPresentationStyle:UIModalPresentationFormSheet];
	}
	
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (([_event showAverage] && [indexPath section] == kHistorySection) ||
			(![_event showAverage] && [indexPath section] == kAverageSection)) {
		
		HistoryLogDetailController *hldc = [[HistoryLogDetailController alloc] init];
		
		[hldc setLogEntry:[[_event logEntryCollection] objectAtIndex:[indexPath row]]];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		[[self navigationController] pushViewController:hldc animated:YES];

	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];
	if ((section == kAverageSection && ![_event showAverage]) || section == kHistorySection){
		return YES;
	} else {
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	int section = [indexPath section];
	
	if ((section == kAverageSection && ![_event showAverage]) || section == kHistorySection){
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			id item = [[_event logEntryCollection] objectAtIndex:[indexPath row]];
			[_event removeItem:item];
			
			[tableView reloadData];
			//		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
			
		}
	}
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kAverageSection && [_event showAverage]) {
		return @"";
	} else if (section == kAverageSection && ![_event showAverage]) {
		return @"History";
	} else if (section == kHistorySection) {
		return @"History";
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (_event == nil) {
		return 0;
	}
	
	if ([_event showAverage]) {
		return NUM_EVENT_SECTIONS;
	} else {
		return NUM_EVENT_SECTIONS - 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kAverageSection && [_event showAverage]) {
		if ([_event averageValue] != 0.0) {
			return NUM_AVERAGE_SECTIONS;
		} else {
			return NUM_AVERAGE_SECTIONS - 1;
		}
	} else if ((section == kAverageSection && ![_event showAverage]) || (section == kHistorySection)) {

		int count = [[_event logEntryCollection] count];
		if (count == 0) {
			return 1;
		} else {
			return count;
		}
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = nil;
	
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.001];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																	reuseIdentifier:@"UITableViewCell"];
	}
	
	if ([indexPath section] == kAverageSection && [_event showAverage]) {
		
		cell = [tableView dequeueReusableCellWithIdentifier:@"AverageCell"];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																		reuseIdentifier:@"AverageCell"];
		}
		switch ([indexPath row]) {
			case kAverageTime:
			{
				cell.textLabel.text = @"Average Duration";
				cell.detailTextLabel.text = [_event averageStringInterval];
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
				
				cell.detailTextLabel.text = [df stringFromDate:[_event nextTime]];
				break;
			}
			case kAverageValue:
			{
				cell.textLabel.text = @"Average Value";
				cell.detailTextLabel.text = [_event averageStringValue];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
		}
		return cell;

	} else if (([indexPath section] == kAverageSection && ![_event showAverage]) || [indexPath section] == kHistorySection) {

		if ([[_event logEntryCollection] count] > 0) {
			
			HistoryLogCell *historyLogCell = [tableView dequeueReusableCellWithIdentifier:@"HistoryLogCell"];
			
			if (historyLogCell == nil) {
				UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"HistoryLogCell" bundle:nil];
				historyLogCell = (HistoryLogCell *)temporaryController.view;
			}

			LogEntry *item = [[_event logEntryCollection] objectAtIndex:[indexPath row]];

			if ([[item logEntryNote] isEqualToString:@""]){
				UIFont *font = [UIFont italicSystemFontOfSize:14];
				[historyLogCell.logEntryNoteCell setFont:font];
				[historyLogCell.logEntryNoteCell setTextColor:[UIColor grayColor]];
				
				historyLogCell.logEntryNoteCell.text = @"No Note";
			} else {
				UIFont *font = [UIFont systemFontOfSize:14];
				[historyLogCell.logEntryNoteCell setFont:font];
				[historyLogCell.logEntryNoteCell setTextColor:[UIColor blackColor]];
				historyLogCell.logEntryNoteCell.text = item.logEntryNote;
			}
			
			if ([item logEntryValue] != 0.0) {
				NSString *value = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[item logEntryValue]]];
				historyLogCell.logEntryValueCell.text = value;
			} else {
				historyLogCell.logEntryValueCell.text = @"";
			}
			historyLogCell.logEntryDateCell.text = [item stringFromLogEntryInterval];
			historyLogCell.locationMarker.hidden = ![item hasLocation];
			historyLogCell.logEntryLocationCell.text = [item logEntryLocationString];
			return historyLogCell;

		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"NoHistoryCell"];
			
			if (!cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																			reuseIdentifier:@"NoHistoryCell"];
			}
			cell.textLabel.text = @"No History Entries";
			return cell;

		}
		

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

	[[self navigationItem] setTitle:[_event eventName]];
	[[self eventTableView] reloadData];

}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (![_event showAverage]) {
//		[self showAveragePopup];
	}
	
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



#pragma mark - ItemDetailViewControllerDelegate
- (void) itemDetailViewControllerWillDismiss:(CustomTableViewController *)ctvc
{
	[[self eventTableView] reloadData];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom	] == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

@end
