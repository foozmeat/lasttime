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
@synthesize addButton;
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

#pragma mark -
- (void)setEvent:(Event *)event
{
	if (_event != event) {
		_event = event;
		
		// Update the view.
		[[self navigationItem] setTitle:[_event eventName]];
		[eventTableView reloadData];
		[[self addButton] setEnabled:YES];
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
	
	[hldc setLogEntry:[[EventStore defaultStore] createLogEntry]];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[_event logEntryCollection] count] > 0) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if ([[_event logEntryCollection] count] == 0) {
		return;
	}
	
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
			[_event removeLogEntry:item];
			[tableView reloadData];
			
		}
	}
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	[v setBackgroundColor:[UIColor clearColor]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width,30)];
	label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:16.0f];

	label.textColor = [UIColor brownColor];
	label.shadowColor = [UIColor colorWithRed:83 green:52 blue:24 alpha:1.0];
	label.shadowOffset = CGSizeMake(0, 1);
	
	[v addSubview:label];
	
	return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  
{
	if (section == kAverageSection && [_event showAverage]) {
		return 0;
	} else if (section == kAverageSection && ![_event showAverage]) {
		return 30;
	} else if (section == kHistorySection) {
		return 30;
	} else {
		return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kAverageSection && [_event showAverage]) {
		return @"";
	} else if (section == kAverageSection && ![_event showAverage]) {
		return NSLocalizedString(@"History", @"History");
	} else if (section == kHistorySection) {
		return NSLocalizedString(@"History", @"History");
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
		if ([[_event averageValue] floatValue] != 0.0) {
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
			cell.detailTextLabel.textColor = [UIColor brownColor];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];
		}
	
		switch ([indexPath row]) {
			case kAverageTime:
			{
				cell.textLabel.text = NSLocalizedString(@"Time Span",@"Time Span");
				cell.detailTextLabel.text = [_event averageStringInterval];
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
			case kNextTime:
			{
				cell.textLabel.text = NSLocalizedString(@"Next Time",@"Next Time");
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				NSDateFormatter *df = [[NSDateFormatter alloc] init];
				
				[df setDateStyle:NSDateFormatterFullStyle];
				[df setTimeStyle:NSDateFormatterNoStyle];
				
				cell.detailTextLabel.text = [df stringFromDate:[_event nextTime]];
				cell.detailTextLabel.numberOfLines = 2;
				cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;

				break;
			}
			case kAverageValue:
			{
				cell.textLabel.text = NSLocalizedString(@"Average Value",@"Average Value");
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
				historyLogCell.selectionStyle = UITableViewCellSelectionStyleGray;
				historyLogCell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];
			}

			LogEntry *item = [[_event logEntryCollection] objectAtIndex:[indexPath row]];
			
			if ([item showValue]) {
				NSString *value = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[item logEntryValue] floatValue]]];
				historyLogCell.logEntryValueCell.text = value;
			} else {
				historyLogCell.logEntryValueCell.text = @"";
			}
			
			if ([item showNote]) {
				historyLogCell.logEntryNoteCell.text = item.logEntryNote;				
			} else {
				historyLogCell.logEntryNoteCell.text = @"";
			}
			
			historyLogCell.logEntryDateCell.text = [item dateString];
			historyLogCell.locationMarker.hidden = ![item hasLocation];
			historyLogCell.logEntryLocationCell.text = [item locationString];
			return historyLogCell;

		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"NoHistoryCell"];
			
			if (!cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																			reuseIdentifier:@"NoHistoryCell"];
			}
			cell.textLabel.text = NSLocalizedString(@"No History Entries",@"No History Entries");
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;

		}
		

	} else {
		cell.textLabel.text = @"Error";
		return cell;
	}
	
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if ([[_event logEntryCollection] count] > 0) {
		if (([indexPath section] == kAverageSection && ![_event showAverage]) || [indexPath section] == kHistorySection) {
			HistoryLogCell *historyLogCell = (HistoryLogCell *)cell;

			if ([historyLogCell.logEntryValueCell.text isEqualToString:@""]) {
				historyLogCell.logEntryValueCell.textColor = [UIColor grayColor];
				historyLogCell.logEntryValueCell.font = [UIFont italicSystemFontOfSize:14.0f];
				historyLogCell.logEntryValueCell.text = NSLocalizedString(@"No Value", @"The value is empty");
			} else {
				historyLogCell.logEntryValueCell.textColor = [UIColor blackColor];
				historyLogCell.logEntryValueCell.font = [UIFont systemFontOfSize:14.0f];
				
			}
			
			if ([historyLogCell.logEntryNoteCell.text isEqualToString:@""]) {
				historyLogCell.logEntryNoteCell.textColor = [UIColor grayColor];
				historyLogCell.logEntryNoteCell.font = [UIFont italicSystemFontOfSize:14.0f];
				historyLogCell.logEntryNoteCell.text = NSLocalizedString(@"No Note", @"The note is blank");
			} else {
				historyLogCell.logEntryNoteCell.textColor = [UIColor blackColor];
				historyLogCell.logEntryNoteCell.font = [UIFont systemFontOfSize:14.0f];
				
			}
		}
	}
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	numberFormatter = [[NSNumberFormatter alloc] init];
	
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.jpg"]];
	[self.eventTableView setBackgroundColor:background];

	[[self navigationItem] setTitle:[_event eventName]];
	[[self eventTableView] reloadData];

}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (_event == nil) {
		[[self addButton] setEnabled:NO];
	} 
}
- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[self setEventTableView:nil];
	[self setAddButton:nil];
	[super viewDidUnload];
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
