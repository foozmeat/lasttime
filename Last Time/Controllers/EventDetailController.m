//
//  EventDetailController.m
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventDetailController.h"

@implementation EventDetailController
@synthesize nameField;
@synthesize noteField;
@synthesize event;
@synthesize dateButton;

- (IBAction)backgroundTapped:(id)sender {
	[[self view] endEditing:YES];
}

- (IBAction)dateButtonTapped:(id)sender {
	[[self view] endEditing:YES];
	[datePicker setHidden:NO];
}

- (IBAction)dateChanged:(id)sender
{
	[dateButton setTitle:[df stringFromDate:[datePicker date]] forState:UIControlStateNormal];
	
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSDate *now = [[NSDate alloc] init];
	[dateButton setTitle:[df stringFromDate:now] forState:UIControlStateNormal];
	[datePicker setDate:now];

}
- (void)viewDidAppear:(BOOL)animated
{
}

- (void)viewDidLoad
{
	df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[self view] endEditing:YES];
	
	if ([[nameField text] isEqualToString:@""]) {
		[event setEventName:@"New Event"];
	} else {
		[event setEventName:[nameField text]];
	}
	
	LogEntry *le = [[LogEntry alloc] initWithNote:[noteField text] dateOccured:[datePicker date]];
	[[event logEntryCollection] addObject:le];
	
}


- (void)viewDidUnload
{
	[self setNameField:nil];
	[self setNoteField:nil];
	[self setDateButton:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


@end
