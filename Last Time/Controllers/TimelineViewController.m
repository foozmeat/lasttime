//
//  TimelineViewController.m
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TimelineViewController.h"
#import "EventController.h"
#import "LogEntry.h"
#import "Event.h"
#import <QuartzCore/QuartzCore.h>
#import "HeaderView.h"

@implementation TimelineViewController
@synthesize detailViewController;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id) init
{
	self = [super initWithStyle:UITableViewStylePlain];
	return self;
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];
	self.tableView.backgroundColor = background;

}

#pragma mark - Core Data
- (NSFetchedResultsController *)fetchedResultsController {
	
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
																 entityForName:@"LogEntry" inManagedObjectContext:[[EventStore defaultStore] context]];
	[fetchRequest setEntity:entity];
	
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"",
//														folder];
//	[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
														initWithKey:@"logEntryDateOccured" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	[fetchRequest setFetchBatchSize:20];

	_fetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																			managedObjectContext: [[EventStore defaultStore] context]
																				sectionNameKeyPath:@"sectionIdentifier" 
																								 cacheName:@"Timeline"];
	_fetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
			// Update to handle the error appropriately.
		NSLog(@"Error fetching log entries %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	return _fetchedResultsController;    
	
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//	if (userDrivenDataModelChange) return;
	
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
//	if (userDrivenDataModelChange) return;
	
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
//	if (userDrivenDataModelChange) return;
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:cell atIndexPath:indexPath];
			[cell setNeedsLayout];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//	if (userDrivenDataModelChange) return;
	
	[self.tableView endUpdates];
	
}

#pragma mark - TableView Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	LogEntry *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

//	[self.detailViewController setFolder:folder];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		EventController *ec = [[EventController alloc] init];
		[ec setEvent:item.event];			
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[[self navigationController] pushViewController:ec animated:YES];
	} else {
		[self.detailViewController setEvent:item.event];			
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	NSInteger count = [[self.fetchedResultsController sections] count];
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	return theSection.name;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_paper.jpg"]];
	
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	
	LogEntry *le = (LogEntry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	Event *item = le.event;
	[[cell textLabel] setText:[item eventName]];
	[[cell detailTextLabel] setText:[le subtitle]];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	HeaderView *header = [[HeaderView alloc] initWithWidth:tableView.bounds.size.width 
																									 label:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  
{
	return [HeaderView height];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
