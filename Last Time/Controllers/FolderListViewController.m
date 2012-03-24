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
@synthesize activeCell, detailViewController;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id) init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
			// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
}

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

- (void)viewDidUnload {
	self.fetchedResultsController = nil;
}

#pragma mark - Add Actions

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	if (!editing) 	{
		[[activeCell cellTextField] resignFirstResponder];
	}

	[super setEditing:editing animated:animate];

	NSArray *paths = [NSArray arrayWithObject:	[NSIndexPath indexPathForRow:[[self.fetchedResultsController fetchedObjects] count] inSection:0]];

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

- (NSFetchedResultsController *)fetchedResultsController {
	
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
																 entityForName:@"EventFolder" inManagedObjectContext:[[EventStore defaultStore] context]];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
														initWithKey:@"orderingValue" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSFetchedResultsController *theFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																			managedObjectContext: [[EventStore defaultStore] context]
																				sectionNameKeyPath:nil 
																								 cacheName:@"FolderList"];
	self.fetchedResultsController = theFetchedResultsController;
	_fetchedResultsController.delegate = self;
	
	return _fetchedResultsController;    
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([tableView isEditing]) {
		if( indexPath.row == (int)[[self.fetchedResultsController fetchedObjects] count] ) {
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
	EventFolder *folder = nil;
	
	BOOL addingNewRow = indexPath.row == (int)[[self.fetchedResultsController fetchedObjects] count];
	
	if ( addingNewRow ) {
		folder = [[EventStore defaultStore] createFolder];
	} else {
		folder = [_fetchedResultsController objectAtIndexPath:indexPath];;
	}

	if (![tableView isEditing]) {
		EventListViewController *elvc = [[EventListViewController alloc] init];
		[elvc setFolder:folder];
		[elvc setDetailViewController:[self detailViewController]];
		[[self navigationController] pushViewController:elvc animated:YES];
		
	} else {
		if ( addingNewRow ) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			NSArray *paths = [NSArray arrayWithObject:indexPath];
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
		
		id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[[EventStore defaultStore] removeFolder:item];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
			[self setEditing:NO animated:YES];
		}
		
		[[EventStore defaultStore] saveChanges];
		
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == (int)[[self.fetchedResultsController fetchedObjects] count] ) {
		return NO;
	} else {
		return YES;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (proposedDestinationIndexPath.row == (int)[[self.fetchedResultsController fetchedObjects] count]) {
		return sourceIndexPath;
	} else {
		return proposedDestinationIndexPath;
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath 
{
	if ((sourceIndexPath.row != (int)[[self.fetchedResultsController fetchedObjects] count] ) && 
			(destinationIndexPath.row != (int)[[self.fetchedResultsController fetchedObjects] count] )) {

		[[EventStore defaultStore] moveFolderAtIndex:[sourceIndexPath row] 
																				 toIndex:[destinationIndexPath row]];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

	if ([tableView isEditing]) {
		return [sectionInfo numberOfObjects] + 1;
	} else {
		return [sectionInfo numberOfObjects];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *reuseString = nil;
	
	if ([indexPath row] == (int)[[self.fetchedResultsController fetchedObjects] count]) {
		reuseString = @"addFolderCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}

		[[cell textLabel] setText:@"Add a Folder..."];
		return cell;

	} else {
		
		id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
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
	
	EventFolder *folder = [self.fetchedResultsController objectAtIndexPath:path];
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
