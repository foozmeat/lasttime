//
//  HistoryLogDetailController.m
//  Last Time
//
//  Created by James Moore on 1/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HistoryLogDetailController.h"

@implementation HistoryLogDetailController
@synthesize logEntry;

- (void)viewDidLoad
{
	df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	noteField.text = [logEntry logEntryNote];	
	[dateButton setTitle:[df stringFromDate:[logEntry logEntryDateOccured]] forState:UIControlStateNormal];
	[datePicker setDate:[logEntry logEntryDateOccured]];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[self view] endEditing:YES];
	
	[logEntry setLogEntryNote:[noteField text]];
	// Set the date in the picker's dateChanged: action
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[noteField resignFirstResponder];
	return YES;
}

#pragma mark IBActions

- (IBAction)backgroundTapped:(id)sender {
	[[self view] endEditing:YES];
	[datePicker setHidden:YES];
}

- (IBAction)dateButtonPressed:(id)sender
{
	[[self view] endEditing:YES];
	[datePicker setHidden:NO];
}

- (IBAction)dateChanged:(id)sender
{
	[dateButton setTitle:[df stringFromDate:[datePicker date]] forState:UIControlStateNormal];
	[logEntry setLogEntryDateOccured:[datePicker date]];

}

- (void)viewDidUnload {
	noteField = nil;
	dateButton = nil;
	datePicker = nil;
	[super viewDidUnload];
}
@end