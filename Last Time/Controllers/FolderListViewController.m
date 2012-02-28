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
#import "FolderDetailController.h"
#import "EventListViewController.h"
#import "EventStore.h"
#import "EventFolder.h"
#import "FolderListCell.h"

@implementation FolderListViewController
@synthesize folderTableView;

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

- (void)addNewItem:(id)sender
{
	// Make new folder
	FolderDetailController *fdc = [[FolderDetailController alloc] init];
	[fdc setTheNewFolder:[[EventFolder alloc] init]];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:fdc];
	
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	
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
	
	if( indexPath.row == (int)[[[EventStore defaultStore] allItems] count] ) {
		item = [[EventFolder alloc] init];
	} else {
		
		item = [[[EventStore defaultStore] allItems] objectAtIndex:[indexPath row]];
	}

	if ([tableView isEditing]) {
		FolderDetailController *fdc = [[FolderDetailController alloc] init];
		[fdc setTheNewFolder:item];
		
		if( indexPath.row == (int)[[[EventStore defaultStore] allItems] count] ) {
			UINavigationController *newNavController = [[UINavigationController alloc]
																									initWithRootViewController:fdc];
			
			[[self navigationController] presentModalViewController:newNavController
																										 animated:YES];
		} else {
			[[self navigationController] pushViewController:fdc animated:YES];
			
		}
	
	
	} else {
		EventListViewController *elvc = [[EventListViewController alloc] init];
		[elvc setFolder:item];
		[[self navigationController] pushViewController:elvc animated:YES];
		
	}

}

#pragma mark - TableView Datasource Delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
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
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[[cell textLabel] setText:[item objectName]];

		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:15.0]];
		[[cell detailTextLabel] setText:[item subtitle]];
		
		return cell;
	}
	
}

@end
