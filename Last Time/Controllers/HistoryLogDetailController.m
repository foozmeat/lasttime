//
//  HistoryLogDetailController.m
//  Last Time
//
//  Created by James Moore on 1/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HistoryLogDetailController.h"
#import "EditableTableCell.h"
#import "DatePickerCell.h"

@implementation HistoryLogDetailController
@synthesize logEntry, event;
@synthesize noteCell, dateCell;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[event addLogEntry:logEntry];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewFinishedLoading
{
	[self setNoteCell:[EditableTableCell newDetailCellWithTag:EventNote withDelegate:self]];
	[self setDateCell:[DatePickerCell newDateCellWithTag:EventDate withDelegate:self]];
	
	
	if ([self isModal]) {
		[self setTitle:@"New Entry"];		
	} else {
		[self setTitle:@"Edit Entry"];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate Protocol
//  Sets the label of the keyboard's return key to 'Done' when the insertion
//  point moves to the table view's last field.
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//	if ([textField tag] == EventName && ![self isModal]) {
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
	
	switch (tag)
	{
		case EventNote:
			[logEntry setLogEntryNote:text];
			break;
	}
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//  Determine the text field's value. Each section of the table view
	//  is mapped to a property of the event object we're displaying.
	//
	EditableTableCell *cell = nil;
	DatePickerCell *dcell = nil;
	
	switch ([indexPath row]) 
	{
		case EventNote:
			cell = [self noteCell];
			[[cell cellTextField] setText:[logEntry logEntryNote]];
			[[cell cellTextField] setPlaceholder:@"Happy!"];
			[[cell textLabel] setText:@"Note"];
			return cell;
			break;
		case EventDate:
			dcell = [self dateCell];
			[[dcell pickerView] setDate:[logEntry logEntryDateOccured]];
			[dcell dateChanged:self];
			[[dcell textLabel] setText:@"Date"];
			return dcell;
			break;
		default:
			cell = [[EditableTableCell alloc] init];
			[[cell cellTextField] setText:@"Error"];
			return cell;
			break;
	}
}

#pragma mark -
#pragma mark DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[logEntry setLogEntryDateOccured:date];

	NSLog(@"Date Change: %@", date);
}

@end
