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
#import "DurationPickerCell.h"
#import	"EventFolder.h"
#import "EventStore.h"
#import "LogEntry.h"
#import "Event.h"
#import "HeaderView.h"

@implementation EventDetailController
{
	BOOL _reminderEnabled;
}

@synthesize noteCell, dateCell, folderCell, durationCell,reminderCell;
@synthesize event, folder, logEntry;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[self endEditing];
	[folder addEvent:event];
	[super save];
}

- (void)cancel
{
	[[EventStore defaultStore] removeEvent:event];

	[super cancel];
}
#pragma mark - UIViewController Methods

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (event.reminderDuration != 0) {
		_reminderEnabled = YES;
	}
	
	if (logEntry) {
		[event addLogEntry:logEntry];
	}
}

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

	[self setDurationCell:[DurationPickerCell newDurationCellWithTag: kEventReminderDuration withDelegate:self]];
	
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	HeaderView *header = [[HeaderView alloc] initWithWidth:tableView.bounds.size.width label:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];

	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.00001f;
    } else {
        return [HeaderView height];
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
	DurationPickerCell *durcell = nil;
	NumberCell *ncell = nil;
	
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
				rcell.reminderSwitch.on = _reminderEnabled;
				return rcell;
				break;
			case kEventReminderDuration:
				durcell = self.durationCell;
				durcell.duration = [event reminderDuration];
				if (![self isModal]) {
					durcell.eventDate = [event latestDate];
				}
				[durcell setupPickerComponants];
				
				return durcell;
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
	if (_reminderEnabled == sender.on) {
		return;
	}

#ifdef DEBUG
	NSLog(@"Reminder is switched to %d", _reminderEnabled);
#endif

	_reminderEnabled = sender.on;

	NSUInteger indexes[] = { kReminderSection, kEventReminderDuration };
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
	
	if (_reminderEnabled == YES) {
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		[self durationPickerDidChangeWithDuration:(60 * 60 *24)];
	} else {
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		[self durationPickerDidChangeWithDuration:0];
		[event removeNotification];
	}

	[[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:kReminderSection] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - EditableTableCellDelegate
- (void)stringDidChange:(NSString *)value {
}

#pragma mark - DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[logEntry setLogEntryDateOccured:date];
	[event updateLatestDate];
	[durationCell updateEventDate:date];
}

#pragma mark - DurationPickerDelegate

- (void)durationPickerDidChangeWithDuration:(NSTimeInterval)duration;
{
	[event setReminderDuration:duration];
	[event updateReminderNotification];
	 
#ifdef DEBUG
	NSLog(@"Duration set to %f", duration);
#endif
	
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

}

- (EventFolder *)folderPickerCurrentFolder;
{
	return [self folder];
}

@end
