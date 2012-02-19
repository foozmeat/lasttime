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
@synthesize noteCell, dateCell, locationCell;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[event addLogEntry:logEntry];
	[self dismissModalViewControllerAnimated:YES];
	NSLog(@"%@", event);
}

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewDidLoad
{
	[super viewDidLoad];

	if ([self isModal] && [self shouldStoreLocation]) {
		[self startUpdatingLocation:@"Get location for controller"];
	}

}

- (void)viewFinishedLoading
{
	[self setNoteCell:[EditableTableCell newDetailCellWithTag:kEventNote withDelegate:self]];
	[self setDateCell:[DatePickerCell newDateCellWithTag:kEventDate withDelegate:self]];
	[self setLocationCell:[LocationSwitchCell newLocationCellWithTag:kEventLocation withDelegate:self]];
	[self setNumberCell:[NumberCell newNumberCellWithTag:kEventNumber withDelegate:self]];

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
	float value = 0.0;
	
	switch (tag)
	{
		case kEventNote:
			[logEntry setLogEntryNote:text];
			break;
		case kEventNumber:
			value = [text floatValue];
			[logEntry setLogEntryValue:value];
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
	if ([self isModal]) {
		return 3;
	} else {
		return 2;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//  Determine the text field's value. Each section of the table view
	//  is mapped to a property of the event object we're displaying.
	//
	EditableTableCell *cell = nil;
	DatePickerCell *dcell = nil;
	LocationSwitchCell *lcell = nil;
	NumberCell *ncell = nil;

	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.001];

	switch ([indexPath row]) 
	{
		case kEventNote:
			cell = [self noteCell];
			[[cell cellTextField] setText:[logEntry logEntryNote]];
			[[cell cellTextField] setPlaceholder:@"Happy!"];
			[[cell textLabel] setText:@"Note"];
			return cell;
			break;
		case kEventDate:
			dcell = [self dateCell];
			[[dcell pickerView] setDate:[logEntry logEntryDateOccured]];
			[dcell dateChanged:self];
			[[dcell textLabel] setText:@"Date"];
			return dcell;
			break;
		case kEventNumber:
			
			
			ncell = [self numberCell];
			[[ncell cellTextField] setText:[numberFormatter stringFromNumber:[NSNumber numberWithFloat:[logEntry logEntryValue]]]];
			[[ncell cellTextField] setPlaceholder:@"rating, mileage, weight"];
			[[ncell textLabel] setText:@"Number"];
			return ncell;
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
	
}

#pragma mark -
#pragma mark DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[logEntry setLogEntryDateOccured:date];
}

@end
