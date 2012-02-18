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

@implementation EventDetailController
@synthesize nameCell, noteCell, dateCell, folderCell, locationCell;
@synthesize event, folder;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[folder addItem:event];
	[self dismissModalViewControllerAnimated:YES];
	NSLog(@"%@", event);
}

#pragma mark -
#pragma mark UIViewController Methods
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

	if ([self isModal]) {
		[self setTitle:@"New Event"];
		
		[self setNoteCell:[EditableTableCell newDetailCellWithTag:kEventNote withDelegate:self]];
		[self setDateCell:[DatePickerCell newDateCellWithTag:kEventDate withDelegate:self]];
		[self setLocationCell:[LocationSwitchCell newLocationCellWithTag:kEventLocation withDelegate:self]];
		
	} else {
		[self setTitle:@"Edit Event"];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate Protocol
//  Sets the label of the keyboard's return key to 'Done' when the insertion
//  point moves to the table view's last field.
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if ([textField tag] == kEventName && ![self isModal]) {
		[textField setReturnKeyType:UIReturnKeyDone];
	} else if ([textField tag] == kEventNote && [self isModal]) {
		[textField setReturnKeyType:UIReturnKeyDone];
	}
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
	
	switch (tag)
	{
		case kEventName:
			[event setEventName:text];
			break;
		case kEventNote:
			[[[event logEntryCollection] objectAtIndex:0] setLogEntryNote:text];
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
	if (section == 0) {
		if ([self isModal]) {
			return 4;
		} else {
			return 1;
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

	if ([indexPath section] == 0) {
		
		switch ([indexPath row]) {
			case kEventName:
				cell = [self nameCell];
				[[cell cellTextField] setText:[event eventName]];
				[[cell cellTextField] setPlaceholder:@"Got a haircut"];
				[[cell textLabel] setText:@"Name"];
				return cell;
				break;
			case kEventNote:
				cell = [self noteCell];
				[[cell cellTextField] setPlaceholder:@"Happy!"];
				[[cell textLabel] setText:@"Note"];
				return cell;
				break;
			case kEventDate:
				dcell = [self dateCell];
				[[dcell textLabel] setText:@"Date"];
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
	} if ([indexPath section] == 1) {
		switch ([indexPath row]) {
			case kEventFolder:
				fcell = [self folderCell];
				[[fcell textLabel] setText:@"Folder"];
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
	[[[event logEntryCollection] objectAtIndex:0] setLogEntryLocation:loc];
	
}

#pragma mark - EditableTableCellDelegate
- (void)stringDidChange:(NSString *)value {
//	[event setEventName:<#(NSString *)#>
}

#pragma mark - DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[[[event logEntryCollection] objectAtIndex:0] setLogEntryDateOccured:date];
}

#pragma mark - FolderPickerDelegate

- (void)folderPickerDidChange:(EventFolder *)newFolder
{
	if ([self isModal]) {
		[self setFolder:newFolder];
	} else {
		[newFolder addItem:event];
		[folder removeItem:event];
		[self setFolder:newFolder];
	}
	[[self tableView] reloadData];
}

- (EventFolder *)folderPickerCurrentFolder;
{
	return [self folder];
}
@end
