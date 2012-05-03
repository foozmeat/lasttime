//
//  EventListViewController.m
//  Last Time
//
//  Created by James Moore on 2/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EventListViewController.h"
#import "EventController.h"
#import "EventDetailController.h"
#import "EventStore.h"
#import "EventFolder.h"
#import "Event.h"
#import "HeaderView.h"

@implementation EventListViewController
@synthesize folder;
@synthesize eventTableView;
@synthesize detailViewController;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidUnload
{
	[self setEventTableView:nil];
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.title = [folder folderName];
	userDrivenDataModelChange = NO;

	eventTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if ([[self.fetchedResultsController fetchedObjects] count] != 0) {
		[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	}
	
}
#pragma mark - Add Actions

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	[super setEditing:editing animated:animate];
	
	[eventTableView setEditing:editing animated:animate];
}

- (void)addNewEvent:(id)sender
{
	EventDetailController *edc = [[EventDetailController alloc] init];
	
	[edc setEvent:[[EventStore defaultStore] createEvent]];
	[edc setLogEntry:[[EventStore defaultStore] createLogEntry]];
	[edc setFolder:self.folder];
	[edc setDelegate:self];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:edc];

	if ([[UIDevice currentDevice] userInterfaceIdiom	] == UIUserInterfaceIdiomPad) {
		[newNavController setModalPresentationStyle:UIModalPresentationFormSheet];
	}

	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	
}

#pragma mark - Core Data
- (NSFetchedResultsController *)fetchedResultsController {
	
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
																 entityForName:@"Event" inManagedObjectContext:[[EventStore defaultStore] context]];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"folder == %@",
														folder];
	[fetchRequest setPredicate:predicate];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
														initWithKey:@"latestDate" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	_fetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																			managedObjectContext: [[EventStore defaultStore] context]
																				sectionNameKeyPath:nil
																								 cacheName:nil];
	_fetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
			// Update to handle the error appropriately.
		NSLog(@"Error fetching folders %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	return _fetchedResultsController;    
	
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if (userDrivenDataModelChange) return;
	
	[self.eventTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if (userDrivenDataModelChange) return;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.eventTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.eventTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	if (userDrivenDataModelChange) return;
	
	UITableView *tableView = self.eventTableView;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:cell atIndexPath:indexPath];
			[cell setNeedsLayout];
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
	
	[self.eventTableView endUpdates];
	
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([tableView isEditing]) {
		EventDetailController *edc = [[EventDetailController alloc] init];
		[edc setEvent:item];
		[edc setFolder:folder];
		[[self navigationController] pushViewController:edc animated:YES];
		
		[self setEditing:NO animated:NO];
		
	} else {
		
		[self.detailViewController setFolder:folder];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			EventController *ec = [[EventController alloc] init];
			[ec setEvent:item];			
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[[self navigationController] pushViewController:ec animated:YES];
		} else {
			[self.detailViewController setEvent:item];			
		}
	}
		
		
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Event *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[folder removeEvent:item];

		if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
			[[self navigationItem] setRightBarButtonItem:nil];
			[self setEditing:NO animated:YES];
		}
		
	}
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	return 0;
//	NSInteger count = [[self.fetchedResultsController sections] count];
//	return count;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	
//	id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
//	
//	return theSection.name;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EventCell"];
	}

	cell.detailTextLabel.textColor = [UIColor brownColor];
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}	
	[self configureCell:cell atIndexPath:indexPath];

	
	return cell;
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:[self.eventTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	
	Event *item = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	[[cell textLabel] setText:[item eventName]];
	[[cell detailTextLabel] setText:[item subtitle]];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];

	
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//	HeaderView *header = [[HeaderView alloc] initWithWidth:tableView.bounds.size.width 
//																									 label:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
//	
//	return header;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  
//{
//	return [HeaderView height];
//}

#pragma mark - ItemDetailViewControllerDelegate
- (void) itemDetailViewControllerWillDismiss:(CustomTableViewController *)ctvc
{
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
