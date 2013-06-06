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
@property (weak, nonatomic) IBOutlet UIToolbar *exportButton;
@end

@implementation EventController
@synthesize addButton;
@synthesize eventTableView;
@synthesize event = _event; 
@synthesize folder;

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

#pragma mark - Model methods
- (IBAction)exportEvent:(id)sender {

	NSMutableString *exportedText = [NSMutableString new];

//	[exportedText appendFormat:@"%@\n\n",self.event.eventName];

	if ([[_event logEntryCollection] count] > 0) {
		[exportedText appendFormat:@"%@: %@\n",NSLocalizedString(@"Last Time",@"Last Time"), [_event lastStringInterval]];

		if ([_event showAverage]) {
			[exportedText appendFormat:@"%@: %@\n",NSLocalizedString(@"Time Span",@"Time Span"), [_event averageStringInterval]];

			NSDateFormatter *df = [[NSDateFormatter alloc] init];

			[df setDateStyle:NSDateFormatterFullStyle];
			[df setTimeStyle:NSDateFormatterNoStyle];

			[exportedText appendFormat:@"%@: %@\n",NSLocalizedString(@"Next Time",@"Next Time"), [df stringFromDate:[_event nextTime]]];

			if ([_event showAverageValue]) {
				[exportedText appendFormat:@"%@: %@\n",NSLocalizedString(@"Average Value","@Average Value"), [_event averageStringValue]];
			}

			[exportedText appendFormat:@"\n— %@ —\n\n",NSLocalizedString(@"History","@History")];
			for (LogEntry *le in _event.logEntryCollection) {
				[exportedText appendFormat:@"%@",le.dateString];
				if ([le showNote]) {
					[exportedText appendFormat:@" — %@",le.logEntryNote];
				}
				if ([le showValue]) {
					NSString *value = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[le logEntryValue] floatValue]]];
					[exportedText appendFormat:@" — %@",value];
				}

				[exportedText appendString:@"\n"];
			}
		}

	} else {
		[exportedText appendString:NSLocalizedString(@"No History Entries",@"No History Entries")];
	}

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
	
	NSInteger count = [[_event logEntryCollection] count];

	if (count == 0) {
		return;
	}
	
	NSInteger section = [indexPath section];
	
	if (section == kLastTimeSection) {

		[_event cycleLastTimeDisplayFormat];
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

	} else if (section == kHistorySection) {
		
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
			[_event updateLatestDate];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section  
{
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  
{
	int count = [[_event logEntryCollection] count];

	if (section == kLastTimeSection && count > 0) {
		return 10.0;
	} else if (section == kAverageSection && count > 1) {
		return 10.0;
	} else if (section == kHistorySection) {
		return 30;
	} else {
		return 0.00001f;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kLastTimeSection) {
		return nil;
	} else if (section == kAverageSection) {
		return nil;
	} else if (section == kHistorySection) {
		return NSLocalizedString(@"History", @"History");
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

	cell = [tableView dequeueReusableCellWithIdentifier:@"AverageCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																	reuseIdentifier:@"AverageCell"];
		cell.detailTextLabel.textColor = [UIColor brownColor];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}

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
			
			if (historyLogCell == nil) {
				UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"HistoryLogCell" bundle:nil];
				historyLogCell = (HistoryLogCell *)temporaryController.view;
				historyLogCell.selectionStyle = UITableViewCellSelectionStyleGray;
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
	
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];

	if ([[_event logEntryCollection] count] > 0) {
		if ([indexPath section] == kHistorySection) {
			HistoryLogCell *historyLogCell = (HistoryLogCell *)cell;

			if ([historyLogCell.logEntryValueCell.text isEqualToString:@""]) {
				historyLogCell.logEntryValueCell.text = NSLocalizedString(@"No Value", @"The value is empty");
			} else {
				historyLogCell.logEntryValueCell.textColor = [UIColor brownColor];
				historyLogCell.logEntryValueCell.font = [UIFont systemFontOfSize:14.0f];
				
			}
			
			if ([historyLogCell.logEntryNoteCell.text isEqualToString:@""]) {
				historyLogCell.logEntryNoteCell.text = NSLocalizedString(@"No Note", @"The note is blank");
			} else {
				historyLogCell.logEntryNoteCell.textColor = [UIColor brownColor];
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
	
	UIView *backgroundView = [[UIView alloc] init];
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.jpg"]];
	[eventTableView setBackgroundView:backgroundView];

	[[self navigationItem] setTitle:[_event eventName]];
	[[self event] refreshItems];
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
	[self setExportButton:nil];
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
