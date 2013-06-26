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
@synthesize timelineTableView;
@synthesize exportButton;

- (void)viewDidAppear:(BOOL)animated
{
		// we need to do this in case any events were renamed
	[[self timelineTableView] reloadData];
	
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"Timeline", @"Timeline");
}

- (IBAction)exportTimeline:(id)sender
{
	
	NSString *tmpFile = [[EventStore defaultStore] exportToFile];
	NSData *exportedData = [NSData dataWithContentsOfFile:tmpFile];
	MFMailComposeViewController *picker = [MFMailComposeViewController new];
	picker.mailComposeDelegate = self;

	if (tmpFile != nil) {
		if ([MFMailComposeViewController canSendMail]) {
#ifdef TESTFLIGHT			
			[TestFlight passCheckpoint:@"Exported Data"]; 
#endif
			[picker setSubject:[tmpFile lastPathComponent]];
			[picker addAttachmentData:exportedData mimeType:@"text/csv" fileName:[tmpFile lastPathComponent]];
			[picker setToRecipients:[NSArray array]];
			[picker setMessageBody:@"" isHTML:NO];
			[picker setMailComposeDelegate:self];
			[self presentModalViewController:picker animated:YES];                    
		}
		else {
			[self launchMailAppOnDevice];
		}
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissModalViewControllerAnimated:YES];
}

	// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?subject=Please set up your email!";
	NSString *body = @"&body=Please set up your email!";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
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
	[self.timelineTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.timelineTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.timelineTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableViewCell *cell = [self.timelineTableView cellForRowAtIndexPath:indexPath];
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.timelineTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			
			[self.timelineTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:cell atIndexPath:indexPath];
			[cell setNeedsLayout];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.timelineTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.timelineTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.timelineTableView endUpdates];
	
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewEvent"]) {
        NSIndexPath *indexPath = [self.timelineTableView indexPathForSelectedRow];
        LogEntry *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
		EventController *ec = [segue destinationViewController];
		[ec setEvent:item.event];
    }

}

#pragma mark - TableView Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
#ifndef _USE_OS_7_OR_LATER
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, cell.contentView.frame.size.height - 1.0, cell.contentView.frame.size.width + 10.0, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1.0];
    [cell.contentView addSubview:lineView];
#endif
    [self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:[self.timelineTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LTStyleManager *sm = [LTStyleManager manager];

	LogEntry *le = (LogEntry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	Event *item = le.event;
	[[cell textLabel] setText:[item eventName]];
	[[cell detailTextLabel] setText:[le subtitle]];
    cell.textLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];
    cell.detailTextLabel.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	HeaderView *header = [[HeaderView alloc] initWithWidth:tableView.bounds.size.width label:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  
{
	return [HeaderView height];
}

@end
