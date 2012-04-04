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

@interface TimelineViewController ()

@end

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
	
	self.title = NSLocalizedString(@"Timeline", @"Timeline");
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EventCell"];
	}
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}	
	[self configureCell:cell atIndexPath:indexPath];
	
	
	return cell;
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
	[[cell detailTextLabel] setText:[item subtitleForTimeline:YES]];
	
	
}


- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
