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
#import "LogEntry.h"
#import "Event.h"

@interface EventController ()
@end

@implementation EventController
@synthesize eventTableView;
@synthesize event = _event; 
@synthesize folder;

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

#pragma mark - Model methods
- (IBAction)exportEvent:(id)sender {

	NSString *exportedText = [_event description];

	MFMailComposeViewController *picker = [MFMailComposeViewController new];
	picker.mailComposeDelegate = self;

	if ([MFMailComposeViewController canSendMail]) {
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"Exported Event Data"];
#endif
		[picker setSubject:[NSString stringWithFormat:@"Last Time: %@",self.event.eventName]];
		[picker setToRecipients:[NSArray array]];
		[picker setMessageBody:exportedText isHTML:NO];
		[picker setMailComposeDelegate:self];
		[self presentModalViewController:picker animated:YES];
	}
	else {
		[self launchMailAppOnDevice];
	}

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

	// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?subject=Please set up your email!";
	NSString *body = @"&body=Please set up your email!";

	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addLogEntry"]) {
//		HistoryLogDetailController *hldc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		HistoryLogDetailController *hldc = [segue destinationViewController];

		[hldc setLogEntry:[[EventStore defaultStore] createLogEntry]];
		[hldc setEvent:self.event];
		[hldc setDelegate:self];
		[hldc setIsModal:YES];

	} else if ([segue.identifier isEqualToString:@"editLogEntry"]) {
		HistoryLogDetailController *hldc = [segue destinationViewController];
		NSIndexPath *indexPath = [self.eventTableView indexPathForSelectedRow];
		[hldc setLogEntry:[[_event logEntryCollection] objectAtIndex:[indexPath row]]];
		[hldc setIsModal:NO];

	}
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
	
	NSInteger count = [[_event logEntryCollection] count];

	if (count == 0) {
		return;
	}
	
	NSInteger section = [indexPath section];
	
	if (section == kLastTimeSection) {

		[_event cycleLastTimeDisplayFormat];
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

	} else if (section == kHistorySection) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
			[_event updateLatestDate];
			[tableView reloadData];

			if ([[_event logEntryCollection] count] == 0) {
				self.exportButton.enabled = NO;
			}
		}
	}
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
	[v setBackgroundColor:[UIColor clearColor]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width,20)];
	label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0];

	[v addSubview:label];
	
	return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section  
{
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  
{
	int count = [[_event logEntryCollection] count];

	if (section == kLastTimeSection && count > 0) {
		return 20.0;
	} else if (section == kAverageSection && count > 1) {
		return 20.0;
	} else if (section == kHistorySection && count > 0) {
		return 20;
	} else {
		return 0.00001f;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	int count = [[_event logEntryCollection] count];

	if (section == kLastTimeSection) {
		return nil;
	} else if (section == kAverageSection) {
		return nil;
	} else if (section == kHistorySection && count > 0) {
		return NSLocalizedString(@"History", @"History");
	} else if (section == kHistorySection && count == 0) {
		return NSLocalizedString(@"No History Entries",@"No History Entries");
	} else {
		return nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (_event == nil) {
		return 0;
	}
	
	return NUM_EVENT_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [[_event logEntryCollection] count];

	if (section == kLastTimeSection) {
		if (count > 0) {
			return NUM_LASTTIME_SECTIONS;
		} else {
			return 0;
		}
		
		
	} else if (section == kAverageSection) {
		if (count > 1) {
			if ([_event showAverageValue]) {
				return NUM_AVERAGE_SECTIONS;
			} else {
				return NUM_AVERAGE_SECTIONS - 1;
			}
		} else {
			return 0;
		}
		
	} else if (section == kHistorySection) {

		if (count == 0) {
			return 0;
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

	cell = [tableView dequeueReusableCellWithIdentifier:@"AverageCell"];
	
	if ([indexPath section] == kLastTimeSection && [[_event logEntryCollection] count] > 0) {

		cell.textLabel.text = NSLocalizedString(@"Last Time",@"Last Time");
		cell.detailTextLabel.text = [_event lastStringInterval];
		
		return cell;
		
	} else if ([indexPath section] == kAverageSection && [_event showAverage]) {
		
	
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

	} else if ([indexPath section] == kHistorySection) {

		if ([[_event logEntryCollection] count] > 0) {
			
			HistoryLogCell *historyLogCell = [tableView dequeueReusableCellWithIdentifier:@"HistoryLogCell"];

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
			
			cell.textLabel.text = NSLocalizedString(@"No History Entries",@"No History Entries");
			return cell;

		}
		

	} else {
		cell.textLabel.text = @"Error";
		return cell;
	}
		
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
//	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];

	if ([[_event logEntryCollection] count] > 0) {
		if ([indexPath section] == kHistorySection) {
			HistoryLogCell *historyLogCell = (HistoryLogCell *)cell;

			if ([historyLogCell.logEntryValueCell.text isEqualToString:@""]) {
				historyLogCell.logEntryValueCell.text = NSLocalizedString(@"No Value", @"The value is empty");
			} else {
				historyLogCell.logEntryValueCell.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
                historyLogCell.logEntryNoteCell.textColor = [UIColor blackColor];
			}
			
			if ([historyLogCell.logEntryNoteCell.text isEqualToString:@""]) {
				historyLogCell.logEntryNoteCell.text = NSLocalizedString(@"No Note", @"The note is blank");
			} else {
				historyLogCell.logEntryNoteCell.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
                historyLogCell.logEntryNoteCell.textColor = [UIColor blackColor];
				
			}
		}
	}
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	numberFormatter = [[NSNumberFormatter alloc] init];
	
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_paper.jpg"]];
//    [eventTableView setBackgroundView:imageView];

	[[self navigationItem] setTitle:[_event eventName]];
	[[self event] refreshItems];
	[[self eventTableView] reloadData];

}

- (void) viewDidAppear:(BOOL)animated
{

	if (self.event == nil) {
		NSAssert(self.event != nil, @"Our Event should not be nil");
		self.addButton.enabled = NO;
		self.exportButton.enabled = NO;
	}

	if ([[_event logEntryCollection] count] == 0) {
		self.exportButton.enabled = NO;
	} else {
		self.exportButton.enabled = YES;
	}

	[super viewDidAppear:animated];
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
