//
//  EventDetailController.m
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventDetailController.h"
#import "EditableTableCell.h"
#import "DatePickerCell.h"
#import	"EventFolder.h"
#import "EventStore.h"
#import "LogEntry.h"
#import "Event.h"

@implementation EventDetailController
{
	BOOL _reminderEnabled;
}

@synthesize noteCell, dateCell, folderCell;
@synthesize event, folder, logEntry;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[self endEditing];
	[event addLogEntry:logEntry];
	[folder addEvent:event];
	
	[super save];
}

- (void)cancel
{
	[[EventStore defaultStore] removeLogEntry:logEntry];
	[[EventStore defaultStore] removeEvent:event];

	[super cancel];
}
#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
	[self setRequiredField:kEventName];
	[super viewDidLoad];
	
	if ([self isModal] && [self shouldStoreLocation]) {
		[self startUpdatingLocation:@"Get location for controller"];
	}
}
- (void)viewFinishedLoading
{
	[self setNameCell:[EditableTableCell newDetailCellWithTag:kEventName withDelegate:self]];
	[self setFolderCell:[FolderPickerCell newFolderCellWithTag:kEventFolder 
																								withDelegate:self]];

	[self setReminderCell:[ReminderSwitchCell newReminderCellWithTag:kEventReminderSwitch withDelegate:self]];
	if ([self isModal]) {
		[self setTitle:NSLocalizedString(@"New Event",@"New Event")];
		
		[self setNoteCell:[EditableTableCell newDetailCellWithTag:kEventNote withDelegate:self]];
		[self setDateCell:[DatePickerCell newDateCellWithTag:kEventDate withDelegate:self]];
		[self setLocationCell:[LocationSwitchCell newLocationCellWithTag:kEventLocation withDelegate:self]];
		[self setNumberCell:[NumberCell newNumberCellWithTag:kEventNumber withDelegate:self]];
		
	} else {
		[self setTitle:NSLocalizedString(@"Edit Event",@"Edit Event")];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate Protocol
//  Sets the label of the keyboard's return key to 'Done' when the insertion
//  point moves to the table view's last field.
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//	if ([textField tag] == kEventName && ![self isModal]) {
//		[textField setReturnKeyType:UIReturnKeyDone];
//	} else if ([textField tag] == kEventNumber && [self isModal]) {
//		[textField setReturnKeyType:UIReturnKeyDone];
//	}
	return YES;
}

//  UITextField sends this message to its delegate after resigning
//  firstResponder status. Use this as a hook to save the text field's
//  value to the corresponding property of the model object.
//  
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	
	NSString *text = [textField text];
	NSUInteger tag = [textField tag];
	NSNumber *value = [NSNumber numberWithFloat:[text floatValue]];
	
	switch (tag)
	{
		case kEventName:
			if (![text isEqualToString:@""]) {
				[event setEventName:text];
			}
			break;
		case kEventNote:
			[logEntry setLogEntryNote:text];
			break;
		case kEventNumber:
			[logEntry setLogEntryValue:value];
			break;
	}
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kMainSection) {
		
		int rowCount = 1; // Name field

		if ([self isModal]) {
			rowCount += 3; // note, number, date;
			
			if ([self locationServicesEnabled]) {
				rowCount++;
			}
		}
		
		return rowCount;
	} else if (section == kReminderSection) {
		if (_reminderEnabled) {
			return NUM_REMINDER_ROWS;
		} else {
			return NUM_REMINDER_ROWS - 1;
		}
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//  Determine the text field's value. Each section of the table view
	//  is mapped to a property of the event object we're displaying.
	//
	EditableTableCell *cell = nil;
	DatePickerCell *dcell = nil;
	FolderPickerCell *fcell = nil;
	LocationSwitchCell *lcell = nil;
	ReminderSwitchCell *rcell = nil;
	NumberCell *ncell = nil;
	UITableViewCell *mycell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"duration"];

	if ([indexPath section] == kMainSection) {
		
		switch ([indexPath row]) {
			case kEventName:
				cell = [self nameCell];
				[[cell cellTextField] setText:[event eventName]];
				[[cell cellTextField] setPlaceholder:NSLocalizedString(@"nameCellPlaceholder",@"An example for the event name field")];
				[[cell textLabel] setText:NSLocalizedString(@"Name",@"Name")];
				return cell;
				break;
			case kEventNote:
				cell = [self noteCell];
				[[cell cellTextField] setPlaceholder:NSLocalizedString(@"noteCellPlaceholder",@"An example movie for the note field")];
				[[cell textLabel] setText:NSLocalizedString(@"Note",@"Note")];
				return cell;
				break;
			case kEventNumber:
				ncell = [self numberCell];
				[[ncell cellTextField] setPlaceholder:NSLocalizedString(@"valueCellPlaceholder",@"examples of ways to use this field")];
				[[ncell textLabel] setText:NSLocalizedString(@"Number",@"Number")];
				return ncell;
				break;
			case kEventDate:
				dcell = [self dateCell];
				[[dcell textLabel] setText:NSLocalizedString(@"Date",@"Date")];
				return dcell;
				break;
			case kEventLocation:
				lcell = [self locationCell];
				return lcell;
				break;
			default:
				cell = [[EditableTableCell alloc] init];
				[[cell cellTextField] setText:@"Error"];
				return cell;
				break;
		}
	} else if ([indexPath section] == kReminderSection) {
		switch ([indexPath row]) {
			case kEventReminderSwitch:
				rcell = [self reminderCell];
				return rcell;
				break;
			case kEventReminderDuration:
				[[mycell detailTextLabel] setText:@"Duration"];
				[[mycell textLabel] setText:NSLocalizedString(@"Duration",@"Duration")];
				return mycell;
				break;
			default:
				cell = [[EditableTableCell alloc] init];
				[[cell cellTextField] setText:@"Error"];
				return cell;
				break;
		}
	} else if ([indexPath section] == kFolderSection) {
		switch ([indexPath row]) {
			case kEventFolder:
				fcell = [self folderCell];
				[[fcell textLabel] setText:NSLocalizedString(@"List",@"List")];
				[[fcell detailTextLabel] setText:[folder folderName]];
				return fcell;
				break;
			default:
				cell = [[EditableTableCell alloc] init];
				[[cell cellTextField] setText:@"Error"];
				return cell;
				break;
		}
	} else {
		cell = [[EditableTableCell alloc] init];
		[[cell cellTextField] setText:@"Error"];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];

}

#pragma mark - Location methods
-(void)updateObjectLocation
{
	CLLocationCoordinate2D loc;
	if ([self shouldStoreLocation]) {
		loc = [[self bestLocation] coordinate];
	} else {
		loc = CLLocationCoordinate2DMake(0.0, 0.0);
	}
	[logEntry setLogEntryLocation:loc];
	[logEntry locationString];

	
}

#pragma mark - Reminder Switch
-(void)reminderSwitchChanged:(UISwitch *)sender
{
	_reminderEnabled = sender.on;

	NSUInteger indexes[] = { kReminderSection, kEventReminderDuration };
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
	
	if (_reminderEnabled == YES) {
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	}

#ifdef DEBUG
	NSLog(@"Reminder is switched %d", _reminderEnabled);
#endif
}

#pragma mark - EditableTableCellDelegate
- (void)stringDidChange:(NSString *)value {
}

#pragma mark - DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[logEntry setLogEntryDateOccured:date];
}

#pragma mark - FolderPickerDelegate

- (void)folderPickerDidChange:(EventFolder *)newFolder
{
	if ([self isModal]) {
		[self setFolder:newFolder];
	} else {
		[newFolder addEvent:event];
		[folder removeEvent:event];
		[self setFolder:newFolder];
	}
	[[self tableView] reloadData];
}

- (EventFolder *)folderPickerCurrentFolder;
{
	return [self folder];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	}
}


@end
