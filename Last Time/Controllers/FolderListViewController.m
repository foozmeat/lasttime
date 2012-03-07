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
@synthesize activeCell;

- (id) init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.tableView.allowsSelectionDuringEditing = YES;
	self.title = NSLocalizedString(@"Lists", @"Lists");
	
	[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
}

- (void)viewDidDisappear:(BOOL)animated
{
	if ([self.tableView isEditing]) {
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

	NSArray *paths = [NSArray arrayWithObject:	[NSIndexPath indexPathForRow:[[[EventStore defaultStore] allFolders] count] inSection:0]];

	if (editing) 	{
		[[self tableView] insertRowsAtIndexPaths:paths 
														withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else {
		[[self tableView] deleteRowsAtIndexPaths:paths 
														withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark - TableView Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([tableView isEditing]) {
		if( indexPath.row == (int)[[[EventStore defaultStore] allFolders] count] ) {
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
	
	BOOL addingNewRow = indexPath.row == (int)[[[EventStore defaultStore] allFolders] count];
	
	if ( addingNewRow ) {
		item = [[EventFolder alloc] init];
	} else {
		item = [[[EventStore defaultStore] allFolders] objectAtIndex:[indexPath row]];
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
		FolderListCell *cell = (FolderListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		[[cell cellTextField] becomeFirstResponder];
	}

}

#pragma mark - TableView Datasource Delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		FolderListCell *cell = (FolderListCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell cellTextField] resignFirstResponder];
		
		id item = [[[EventStore defaultStore] allFolders] objectAtIndex:[indexPath row]];
		[[EventStore defaultStore] removeFolder:item];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if ([[[EventStore defaultStore] allFolders] count] == 0) {
			[self setEditing:NO animated:YES];
		}
		
		[[EventStore defaultStore] saveChanges];
		
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == (int)[[[EventStore defaultStore] allFolders] count] ) {
		return NO;
	} else {
		return YES;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (proposedDestinationIndexPath.row == (int)[[[EventStore defaultStore] allFolders] count]) {
		return sourceIndexPath;
	} else {
		return proposedDestinationIndexPath;
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath 
{
	if ((sourceIndexPath.row != (int)[[[EventStore defaultStore] allFolders] count] ) && 
			(destinationIndexPath.row != (int)[[[EventStore defaultStore] allFolders] count] )) {

		[[EventStore defaultStore] moveFolderAtIndex:[sourceIndexPath row] 
																				 toIndex:[destinationIndexPath row]];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEditing]) {
		return [[[EventStore defaultStore] allFolders] count] + 1;
	} else {
		return [[[EventStore defaultStore] allFolders] count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *reuseString = nil;
	
	if ([indexPath row] == (int)[[[EventStore defaultStore] allFolders] count]) {
		reuseString = @"addFolderCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}

		[[cell textLabel] setText:@"Add a Folder..."];
		return cell;

	} else {
		
		id item = [[[EventStore defaultStore] allFolders] objectAtIndex:[indexPath row]];
		
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

	FolderListCell *cell = (FolderListCell *)[textField superview];
	[[cell textLabel] setText:newText];

	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	
	NSString *text = [textField text];

	FolderListCell *cell = (FolderListCell *)[textField superview];
	
	NSIndexPath *path = [self.tableView indexPathForCell:cell];
	
	EventFolder *folder = [[[EventStore defaultStore] allFolders] objectAtIndex:path.row];
	[folder setFolderName:text];

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
	[[self tableView] reloadData];
	if ([self.tableView isEditing]) {
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
