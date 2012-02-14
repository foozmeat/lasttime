//
//  CustomTableViewController.m
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "CustomTableViewController.h"
#import "EditableTableCell.h"

@implementation CustomTableViewController
@synthesize rootFolder, requiredField;

- (BOOL)isModal
{
	NSArray *viewControllers = [[self navigationController] viewControllers];
	UIViewController *rootViewController = [viewControllers objectAtIndex:0];
	
	return rootViewController == self;
}

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewDidLoad
{
	//  If the user clicked the '+' button in the list view, we're
	//  creating a new entry rather than modifying an existing one, so 
	//  we're in a modal nav controller. Modal nav controllers don't add
	//  a back button to the nav bar; instead we'll add Save and 
	//  Cancel buttons.
	//  
	
	if ([self isModal]) {
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] 
																	 initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																	 target:self
																	 action:@selector(save)];
		if ([self requiredField] != -1) {
			[saveButton setEnabled:NO];
		}
		[[self navigationItem] setRightBarButtonItem:saveButton];
		
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
																		 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																		 target:self
																		 action:@selector(cancel)];
		
		[[self navigationItem] setLeftBarButtonItem:cancelButton];
		
	}
	
	[self viewFinishedLoading];
}

- (void)viewFinishedLoading
{
	
}

#pragma mark -
#pragma mark Action Methods

- (void)save
{
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
	[self setRequiredField:-1];
	return self;
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
	
	[[self tableView] selectRowAtIndexPath:indexPath animated:YES scrollPosition:0];
}

//  Force textfields to resign firstResponder so that our implementation of
//  -textFieldDidEndEditing: will be called. That'll ensure that all current
//  UI values are flushed to our model object before the detail view disappears.
//
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[self view] endEditing:YES];
	
}

#pragma mark -
#pragma mark UITextFieldDelegate Protocol

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	
	if ([self isModal] && [textField tag] == [self requiredField]) {
		NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
		BOOL isFieldEmpty = [newText isEqualToString:@""];
		self.navigationItem.rightBarButtonItem.enabled = !isFieldEmpty;
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	if ([self isModal] && [textField tag] == [self requiredField]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	return YES;
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
		UIView *nextTextField = [[self tableView] viewWithTag:nextTag];
		
		[nextTextField becomeFirstResponder];
	}
	else if ([self isModal])
	{
		//  We're in a modal navigation controller, which means the user is
		//  adding a new book rather than editing an existing one.
		//
		[self save];
	}
	else
	{
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
	return YES;
}

#pragma mark - EditableTableCellDelegate
- (void)stringDidChange:(NSString *)value {
	@throw [NSException exceptionWithName:@"Called Delegate method in super class" reason:@"Override in subclass" userInfo:nil];
}


#pragma mark - DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	@throw [NSException exceptionWithName:@"Called Delegate method in super class" reason:@"Override in subclass" userInfo:nil];
}

#pragma mark - FolderPickerDelegate
- (void)folderPickerDidChange:(EventFolder *)folder
{
	@throw [NSException exceptionWithName:@"Called Delegate method in super class" reason:@"Override in subclass" userInfo:nil];
}

- (EventFolder *)folderPickerCurrentFolder
{
	@throw [NSException exceptionWithName:@"Called Delegate method in super class" reason:@"Override in subclass" userInfo:nil];
	return nil;
}

- (EventFolder *)folderPickerRootFolder
{
	return rootFolder;
}

- (void)endEditing
{
	[[self view] endEditing:YES];
}

@end
