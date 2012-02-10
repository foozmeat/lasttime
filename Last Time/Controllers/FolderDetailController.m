//
//  FolderDetailController.m
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderDetailController.h"
#import "EditableTableCell.h"

@implementation FolderDetailController
@synthesize nameCell;
@synthesize folder, rootFolder;

#pragma mark -
#pragma mark Action Methods

- (void)save
{
	[rootFolder addItem:folder];
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewFinishedLoading
{
	
	if ([self isModal]) {
		[self setTitle:@"New Folder"];
	} else {
		[self setTitle:@"Edit Folder"];
	}
	[self setNameCell:[EditableTableCell newDetailCellWithTag:FolderName withDelegate:self]];
}

#pragma mark -
#pragma mark UITextFieldDelegate Protocol
//  Sets the label of the keyboard's return key to 'Done' when the insertion
//  point moves to the table view's last field.
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if ([textField tag] == 1)
	{
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
		case FolderName:     [folder setFolderName:text];          break;
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
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//  Determine the text field's value. Each section of the table view
	//  is mapped to a property of the book object we're displaying.
	//
	EditableTableCell *cell = nil;
	NSString *text = nil;
	NSString *label = nil;
	
	switch ([indexPath row]) 
	{
		case FolderName:
			cell = [self nameCell];
			[[cell cellTextField] setPlaceholder:@"Health, Social, Pets"];
			text = [folder folderName];
			label = @"Name";
			break;
	}
	
	UITextField *textField = [cell cellTextField];
	[textField setText:text];
	[[cell textLabel] setText:label];
	return cell;

}


@end
