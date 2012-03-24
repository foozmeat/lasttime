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
	
	userDrivenDataModelChange = NO;
	newCell = nil;
	
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
//		[[EventStore defaultStore] saveChanges];
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

#pragma mark - Core Data
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
	self.fetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
			// Update to handle the error appropriately.
		NSLog(@"Error fetching folders %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	return _fetchedResultsController;    
	
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if (userDrivenDataModelChange) return;
	
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if (userDrivenDataModelChange) return;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	if (userDrivenDataModelChange) return;
	
	UITableView *tableView = self.tableView;
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			newCell = newIndexPath;
			break;
			
		case NSFetchedResultsChangeDelete:
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(FolderListCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (userDrivenDataModelChange) return;
	
	[self.tableView endUpdates];

	if (newCell) {
		FolderListCell *cell = (FolderListCell *)[self.tableView cellForRowAtIndexPath:newCell];
		[[cell cellTextField] becomeFirstResponder];
		newCell = nil;
	}
}


#pragma mark - TableView Delegate

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
		folder = [_fetchedResultsController objectAtIndexPath:indexPath];
	}

	if (![tableView isEditing]) {
		EventListViewController *elvc = [[EventListViewController alloc] init];
		[elvc setFolder:folder];
		[elvc setDetailViewController:[self detailViewController]];
		[[self navigationController] pushViewController:elvc animated:YES];
		
	} else {
		if ( addingNewRow ) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			NSManagedObject *lastObject = [self.fetchedResultsController.fetchedObjects lastObject];
			double lastObjectDisplayOrder = [[lastObject valueForKey:@"orderingValue"] doubleValue];
			[folder setValue:[NSNumber numberWithDouble:lastObjectDisplayOrder + 1.0] forKey:@"orderingValue"];

		}		
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
				
		[[EventStore defaultStore] saveChanges];

		if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
			[self setEditing:NO animated:YES];
		}
		
		
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

//		[[EventStore defaultStore] moveFolderAtIndex:[sourceIndexPath row] 
//																				 toIndex:[destinationIndexPath row]];
    NSUInteger fromIndex = sourceIndexPath.row;  
    NSUInteger toIndex = destinationIndexPath.row;
    NSLog(@"Moving from %u to %u", fromIndex, toIndex);
		
    if (fromIndex == toIndex) return;
    
    NSUInteger count = [self.fetchedResultsController.fetchedObjects count];
    
    NSManagedObject *movingObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:fromIndex];
    
    NSManagedObject *toObject  = [self.fetchedResultsController.fetchedObjects objectAtIndex:toIndex];
    double toObjectDisplayOrder =  [[toObject valueForKey:@"orderingValue"] doubleValue];
    
    double newIndex;
    if ( fromIndex < toIndex ) {
        // moving up
			if (toIndex == count-1) {
					// toObject == last object
				newIndex = toObjectDisplayOrder + 1.0;
			} else  {
				NSManagedObject *object = [self.fetchedResultsController.fetchedObjects objectAtIndex:toIndex+1];
				double objectDisplayOrder = [[object valueForKey:@"orderingValue"] doubleValue];
				
				newIndex = toObjectDisplayOrder + (objectDisplayOrder - toObjectDisplayOrder) / 2.0;
			}
			
    } else {
        // moving down
			
			if ( toIndex == 0) {
					// toObject == last object
				newIndex = toObjectDisplayOrder - 1.0;
				
			} else {
				
				NSManagedObject *object = [self.fetchedResultsController.fetchedObjects objectAtIndex:toIndex-1];
				double objectDisplayOrder = [[object valueForKey:@"orderingValue"] doubleValue];
				
				newIndex = objectDisplayOrder + (toObjectDisplayOrder - objectDisplayOrder) / 2.0;
				
			}
    }
    
    [movingObject setValue:[NSNumber numberWithDouble:newIndex] forKey:@"orderingValue"];
    NSLog(@"Moving to %f", newIndex);
		
    userDrivenDataModelChange = YES;
    
    [[EventStore defaultStore] saveChanges];
		
    userDrivenDataModelChange = NO;
    
			// update with a short delay the moved cell
//    [self performSelector:(@selector(configureCellAtIndexPath:)) withObject:(destinationIndexPath) afterDelay:0.2];
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
		
		
		reuseString = @"FolderCell";
		
		FolderListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[FolderListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}
		[self configureCell:cell atIndexPath:indexPath];
		return cell;
	}
	
}


- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:(FolderListCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}


- (void)configureCell:(FolderListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	
	id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[[cell cellTextField] setDelegate:self];
	[[cell textLabel] setText:[item objectName]];
	
	[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:15.0]];
	[[cell detailTextLabel] setText:[item subtitle]];
	
	
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
