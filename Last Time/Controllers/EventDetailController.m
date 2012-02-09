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
@synthesize tableView;
@synthesize nameCell, noteCell, dateCell;
@synthesize event;



- (BOOL)isModal
{
	NSArray *viewControllers = [[self navigationController] viewControllers];
	UIViewController *rootViewController = [viewControllers objectAtIndex:0];
	
	return rootViewController == self;
}

#pragma mark -
#pragma mark Action Methods

- (void)save
{
//	[rootFolder addItem:folder];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancel
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController Methods

- (id) init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

- (void)viewDidLoad
{
	//  If the user clicked the '+' button in the list view, we're
	//  creating a new entry rather than modifying an existing one, so 
	//  we're in a modal nav controller. Modal nav controllers don't add
	//  a back button to the nav bar; instead we'll add Save and 
	//  Cancel buttons.
	//  
	if ([self isModal])
	{
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] 
																	 initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																	 target:self
																	 action:@selector(save)];
		
		[[self navigationItem] setRightBarButtonItem:saveButton];
		
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
																		 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																		 target:self
																		 action:@selector(cancel)];
		
		[[self navigationItem] setLeftBarButtonItem:cancelButton];
		[self setTitle:@"New Event"];
		
	} else {
		[self setTitle:@"Edit Event"];
		
	}
	
	[self setNameCell:[EditableTableCell newDetailCellWithTag:EventName withDelegate:self]];
	
	if ([self isModal]) {
		[self setNoteCell:[EditableTableCell newDetailCellWithTag:EventNote withDelegate:self]];
		[self setDateCell:[DatePickerCell newDateCellWithTag:EventDate withDelegate:self]];
		
	}
	

}

//  Override inherited method to automatically place the insertion point in the
//  first field.
//
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSUInteger indexes[] = { 0, 0 };
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
																											length:2];
	
	EditableTableCell *cell = (EditableTableCell *)[[self tableView]
																									cellForRowAtIndexPath:indexPath];
	
	[[cell cellTextField] becomeFirstResponder];
}

//  Force textfields to resign firstResponder so that our implementation of
//  -textFieldDidEndEditing: will be called. That'll ensure that all current
//  UI values are flushed to our model object before the detail view disappears.
//
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	for (NSInteger section = 0; section < [[self tableView] numberOfSections]; section++)
	{
		NSUInteger indexes[] = { section, 0 };
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
																												length:2];
		
		EditableTableCell *cell = (EditableTableCell *)[[self tableView]
																										cellForRowAtIndexPath:indexPath];
		if ([[cell cellTextField] isFirstResponder])
		{
			[[cell cellTextField] resignFirstResponder];
		}
	}
}


#pragma mark -
#pragma mark UITextFieldDelegate Protocol
//  Sets the label of the keyboard's return key to 'Done' when the insertion
//  point moves to the table view's last field.
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//	if ([textField tag] == EventNote)	{
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
		case EventName:     [event setEventName:text];          break;
	}
}

//  UITextField sends this message to its delegate when the return key
//  is pressed. Use this as a hook to navigate back to the list view 
//  (by 'popping' the current view controller, or dismissing a modal nav
//  controller, as the case may be).
//
//  If the user is adding a new item rather than editing an existing one,
//  respond to the return key by moving the insertion point to the next cell's
//  textField, unless we're already at the last cell.
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField returnKeyType] == UIReturnKeyNext)
	{
		//  The keyboard's return key is currently displaying 'Next' instead of
		//  'Done', so just move the insertion point to the next field. The
		//  keyboard will display 'Done' when we're at the last field.
		//
		//  (See the implementation of -textFieldShouldBeginEditing:, above.)
		//
		NSInteger nextTag = [textField tag] + 1;
		UIView *nextField = [[self tableView] viewWithTag:nextTag];

		if ([nextField isMemberOfClass:[UITextField class]]) {
			[nextField becomeFirstResponder];
		} else if ([nextField isMemberOfClass:[UITableViewCell class]]) {

			[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:nextTag inSection:0]];
		}
		
	}
	else if ([self isModal])
	{
		//  We're in a modal navigation controller, which means the user is
		//  adding a new event rather than editing an existing one.
		//
		[self save];
	}
	else
	{
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
	return YES;
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
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
		case EventName:
			cell = [self nameCell];
			[[cell cellTextField] setText:@""];
			[[cell cellTextField] setPlaceholder:@"Event Name"];
			return cell;
			break;
		case EventNote:
			cell = [self noteCell];
			[[cell cellTextField] setText:@""];
			[[cell cellTextField] setPlaceholder:@"Event Note"];
			return cell;
			break;
		case EventDate:
			dcell = [self dateCell];
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
	NSLog(@"Date Change: %@", date);
}

- (void)endEditing
{

	[[self view] endEditing:YES];
}
@end
