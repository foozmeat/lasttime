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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
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
		[picker setSubject:[NSString stringWithFormat:@"Last Time: %@",self.event.eventName]];
		[picker setToRecipients:[NSArray array]];
		[picker setMessageBody:exportedText isHTML:NO];
		[picker setMailComposeDelegate:self];
		[self presentViewController:picker animated:YES completion:nil];
	}
	else {
		[self launchMailAppOnDevice];
	}

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
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
	NSInteger section = [indexPath section];
	if ((section == kAverageSection && ![_event showAverage]) || section == kHistorySection){
		return YES;
	} else {
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

	NSInteger section = [indexPath section];

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSInteger count = [[_event logEntryCollection] count];

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
	NSInteger count = [[_event logEntryCollection] count];

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
	LTStyleManager *sm = [LTStyleManager manager];

	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.001];

	cell = [tableView dequeueReusableCellWithIdentifier:@"AverageCell"];
	cell.textLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];
	cell.detailTextLabel.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];

	if ([indexPath section] == kLastTimeSection && [[_event logEntryCollection] count] > 0) {

		cell.textLabel.text = NSLocalizedString(@"Last Time",@"Last Time");
		cell.detailTextLabel.text = [_event lastStringInterval];
		cell.detailTextLabel.textColor = [sm detailTextColor];

		return cell;

	} else if ([indexPath section] == kAverageSection && [_event showAverage]) {


		switch ([indexPath row]) {
			case kAverageTime:
			{
				cell.textLabel.text = NSLocalizedString(@"Time Span",@"Time Span");
				cell.detailTextLabel.text = [_event averageStringInterval];
				cell.detailTextLabel.textColor = [sm detailTextColor];

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
				cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
				cell.detailTextLabel.textColor = [sm detailTextColor];

				break;
			}
			case kAverageValue:
			{
				cell.textLabel.text = NSLocalizedString(@"Average Value",@"Average Value");
				cell.detailTextLabel.text = [_event averageStringValue];
				cell.detailTextLabel.textColor = [sm detailTextColor];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
		}
		return cell;

	} else if ([indexPath section] == kHistorySection) {

		if ([[_event logEntryCollection] count] > 0) {

			HistoryLogCell *historyLogCell = [tableView dequeueReusableCellWithIdentifier:@"HistoryLogCell"];

			LogEntry *item = [[_event logEntryCollection] objectAtIndex:[indexPath row]];

			historyLogCell.logEntry = item;

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

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	numberFormatter = [[NSNumberFormatter alloc] init];

	[[self navigationItem] setTitle:[_event eventName]];
	[[self event] refreshItems];
	[[self eventTableView] reloadData];

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

	self.addButton.title = NSLocalizedString(@"Add", @"Add Item");
	self.exportButton.title = NSLocalizedString(@"Export", @"Export");

}

- (void)viewDidUnload
{
	[self setEventTableView:nil];
	[self setExportButton:nil];
	[self setAddButton:nil];
	[super viewDidUnload];
}

#pragma mark - ItemDetailViewControllerDelegate
- (void) itemDetailViewControllerWillDismiss:(CustomTableViewController *)ctvc
{
	[[self eventTableView] reloadData];
}

@end
