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
#import "Event.h"
#import	"LogEntry.h"

@implementation HistoryLogDetailController
@synthesize logEntry, event;
@synthesize noteCell, dateCell;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[self endEditing];
	[event addLogEntry:logEntry];
	[super save];
}

- (void)cancel
{
	[[EventStore defaultStore] removeLogEntry:logEntry];
	
	[super cancel];
}

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_paper.jpg"]];
//    [self.tableView setBackgroundView:imageView];
}

- (void)viewDidLoad
{
	self.requiredField = -1;
	[super viewDidLoad];

	if ([self isModal] && [self shouldStoreLocation]) {
		[self startUpdatingLocation:@"Get location for controller"];
	}

}

- (void)viewFinishedLoading
{
	[self setNoteCell:[EditableTableCell newDetailCellWithTag:kEventNote withDelegate:self]];
	[self setDateCell:[DatePickerCell newDateCellWithTag:kEventDate withDelegate:self]];
	[self setLocationCell:[LocationSwitchCell newLocationCellWithTag:kEventLocationSwitch withDelegate:self]];
	[self setNumberCell:[NumberCell newNumberCellWithTag:kEventNumber withDelegate:self]];

	if ([self isModal]) {
		self.title = self.event.eventName;
	} else {
		[self setTitle:NSLocalizedString(@"Edit Entry",@"Edit Entry")];
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
			if ([text isEqualToString:@""]) {
				[logEntry setLogEntryValue:nil];
			} else {
				value = [text floatValue];
				[logEntry setLogEntryValue:[NSNumber numberWithFloat:value]];
			}
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
		
	int rowCount = 3; // Name field
	
	if ( [self locationServicesEnabled] && [self isModal] ) {
		rowCount++;
	}
	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int row = [indexPath row];
	//  Determine the text field's value. Each section of the table view
	//  is mapped to a property of the event object we're displaying.
	//
	EditableTableCell *cell = nil;
	DatePickerCell *dcell = nil;
	LocationSwitchCell *lcell = nil;
	NumberCell *ncell = nil;
	UITableViewCell *geoCell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];

	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.001];

	switch (row) 
	{
		case kEventNote:
			cell = [self noteCell];
			[[cell cellTextField] setText:[logEntry logEntryNote]];
//			[[cell cellTextField] setPlaceholder:NSLocalizedString(@"noteCellPlaceholder",@"")];
			[[cell textLabel] setText:NSLocalizedString(@"Note",@"Note")];
			return cell;
			break;
		case kEventDate:
			dcell = [self dateCell];
			[[dcell pickerView] setDate:[logEntry logEntryDateOccured]];
			[dcell dateChanged:self];
			[[dcell textLabel] setText:NSLocalizedString(@"Date",@"Date")];
			return dcell;
			break;
		case kEventNumber:
			
			
			ncell = [self numberCell];
			
			if ([logEntry showValue]) {

				[[ncell cellTextField] setText:[numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[logEntry logEntryValue] floatValue]]]];
			}
//			[[ncell cellTextField] setPlaceholder:NSLocalizedString(@"valueCellPlaceholder",@"")];
			[[ncell textLabel] setText:NSLocalizedString(@"Number",@"Number")];
			return ncell;
			break;
		case kEventLocationSwitch:
			if ([self isModal]) {

				lcell = [self locationCell];
				return lcell;
			} else {
				if (!geoCell) {
					geoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																					 reuseIdentifier:@"UITableViewCell"];
				}
				[[geoCell detailTextLabel] setText:[logEntry logEntryLocationString]];
				[[geoCell textLabel] setText:NSLocalizedString(@"Location",@"Location")];
				return geoCell;

			}
			break;
		case kEventLocation:
			if (!geoCell) {
				geoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
																				 reuseIdentifier:@"UITableViewCell"];
			}
			[[geoCell detailTextLabel] setText:@"Locating..."];
			[[geoCell textLabel] setText:@"Location"];
			
			return geoCell;
			break;
		default:
			cell = [[EditableTableCell alloc] init];
			[[cell cellTextField] setText:@"Error"];
			return cell;
			break;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//	cell.selectionStyle = UITableViewCellSelectionStyleGray;
//	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];

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

-(void)updateLocationCell
{
	
	NSUInteger indexes[] = { 0, kEventLocation };
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
																											length:2];
	
	UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
	
	[[cell detailTextLabel] setText:[logEntry logEntryLocationString]];
	[cell setNeedsLayout];
	
}
- (void)stopUpdatingLocation:(NSString *)state 
{
	[super stopUpdatingLocation:state];
	[logEntry reverseLookupLocation];
//	[self updateLocationCell];
//	[self performSelector:@selector(updateLocationCell) withObject:@"Reload Cell" afterDelay:3];
}

#pragma mark -
#pragma mark DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[logEntry setLogEntryDateOccured:date];
	[event setNeedsSorting:YES];
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
