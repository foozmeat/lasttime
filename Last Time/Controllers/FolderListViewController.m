//
//  LogEntryViewController.m
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderListViewController.h"
#import "EventController.h"
#import "EventDetailController.h"
#import "EventListViewController.h"
#import "EventStore.h"
#import "EventFolder.h"
#import "FolderListCell.h"

@implementation FolderListViewController
@synthesize folderTableView;
@synthesize activeCell;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
	[self setFolderTableView:nil];
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.title = NSLocalizedString(@"Folders", @"Folders");
	
	
	[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];

	[[self folderTableView] reloadData];
	
	[self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if ([folderTableView isEditing]) {
		[self setEditing:NO animated:YES];
	}

}

#pragma mark - Add Actions

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	if (!editing) 	{
		[[activeCell cellTextField] resignFirstResponder];
	}

	[super setEditing:editing animated:animate];

	
	[folderTableView setEditing:editing animated:animate];
	
	NSArray *paths = [NSArray arrayWithObject:	[NSIndexPath indexPathForRow:[[[EventStore defaultStore] allItems] count] inSection:0]];

	if (editing) 	{
		[[self folderTableView] insertRowsAtIndexPaths:paths 
														withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else {
		[[self folderTableView] deleteRowsAtIndexPaths:paths 
														withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark - TableView Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([tableView isEditing]) {
		if( indexPath.row == (int)[[[EventStore defaultStore] allItems] count] ) {
			return UITableViewCellEditingStyleInsert;
			
		} else {
			return UITableViewCellEditingStyleDelete;
			
		}
	} else {
		return UITableViewCellEditingStyleNone;
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	EventFolder *item = nil;
	
	BOOL addingNewRow = indexPath.row == (int)[[[EventStore defaultStore] allItems] count];
	
	if ( addingNewRow ) {
		item = [[EventFolder alloc] init];
	} else {
		item = [[[EventStore defaultStore] allItems] objectAtIndex:[indexPath row]];
	}

	if (![tableView isEditing]) {
		EventListViewController *elvc = [[EventListViewController alloc] init];
		[elvc setFolder:item];
		[elvc setDetailViewController:[self detailViewController]];
		[[self navigationController] pushViewController:elvc animated:YES];
		
	} else {
		if ( addingNewRow ) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			NSArray *paths = [NSArray arrayWithObject:indexPath];
			[[EventStore defaultStore] addFolder:item];
			[tableView insertRowsAtIndexPaths:paths 
											 withRowAnimation:UITableViewRowAnimationAutomatic];
		}		
		FolderListCell *cell = (FolderListCell *)[folderTableView cellForRowAtIndexPath:indexPath];
		[cell setSelected:YES animated:YES];
	}

}

#pragma mark - TableView Datasource Delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		FolderListCell *cell = (FolderListCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell cellTextField] resignFirstResponder];
		
		id item = [[[EventStore defaultStore] allItems] objectAtIndex:[indexPath row]];
		[[EventStore defaultStore] removeFolder:item];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if ([[[EventStore defaultStore] allItems] count] == 0) {
			[self setEditing:NO animated:YES];
		}
		
		[[EventStore defaultStore] saveChanges];
		
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == (int)[[[EventStore defaultStore] allItems] count] ) {
		return NO;
	} else {
		return YES;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (proposedDestinationIndexPath.row == (int)[[[EventStore defaultStore] allItems] count]) {
		return sourceIndexPath;
	} else {
		return proposedDestinationIndexPath;
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath 
{
	if ((sourceIndexPath.row != (int)[[[EventStore defaultStore] allItems] count] ) && 
			(destinationIndexPath.row != (int)[[[EventStore defaultStore] allItems] count] )) {

		[[EventStore defaultStore] moveFolderAtIndex:[sourceIndexPath row] 
																				 toIndex:[destinationIndexPath row]];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEditing]) {
		return [[[EventStore defaultStore] allItems] count] + 1;
	} else {
		return [[[EventStore defaultStore] allItems] count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *reuseString = nil;
	
	if ([indexPath row] == (int)[[[EventStore defaultStore] allItems] count]) {
		reuseString = @"addFolderCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}

		[[cell textLabel] setText:@"Add a Folder..."];
		return cell;

	} else {
		
		id item = [[[EventStore defaultStore] allItems] objectAtIndex:[indexPath row]];
		
		reuseString = @"FolderCell";
		
		FolderListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[FolderListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}
		[[cell cellTextField] setDelegate:self];
		[[cell textLabel] setText:[item objectName]];

		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:15.0]];
		[[cell detailTextLabel] setText:[item subtitle]];
		
		return cell;
	}
	
}

#pragma mark - TextFieldDelegate
//  UITextField sends this message to its delegate after resigning
//  firstResponder status. Use this as a hook to save the text field's
//  value to the corresponding property of the model object.
//  
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	
	NSString *text = [textField text];

	FolderListCell *cell = (FolderListCell *)[textField superview];
	[[cell textLabel] setText:text];
	
	NSIndexPath *path = [folderTableView indexPathForCell:cell];
	
	EventFolder *folder = [[[EventStore defaultStore] allFolders] objectAtIndex:path.row];
	[folder setFolderName:text];

	return YES;
}

- (void)registerForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(keyboardWasShown:)
																							 name:UIKeyboardDidShowNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
	NSDictionary* info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

	// If active text field is hidden by keyboard, scroll it so it's visible
	// Your application might not need or want this behavior.
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbSize.height;
	
	if (!CGRectContainsPoint(aRect, activeCell.frame.origin) ) {

		CGPoint scrollPoint = CGPointMake(0.0, activeCell.frame.origin.y - 30.0);
		[self.folderTableView setContentOffset:scrollPoint animated:YES];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self setActiveCell:(FolderListCell *)[textField superview]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self setEditing:NO animated:YES];
	return YES;
}

#pragma mark - ItemDetailViewControllerDelegate
- (void) itemDetailViewControllerWillDismiss:(CustomTableViewController *)ctvc
{
	[[self folderTableView] reloadData];
	if ([folderTableView isEditing]) {
		[self setEditing:NO animated:YES];
	}
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
