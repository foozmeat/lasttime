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
#import "WEPopoverController.h"
#import "EventStore.h"
#import "EventFolder.h"

@implementation EventListViewController
@synthesize folder;
@synthesize eventTableView;
@synthesize addPopover;
@synthesize detailViewController;

- (void)viewDidUnload
{
	[self setEventTableView:nil];
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.title = [folder folderName];
	
	[[self eventTableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if ([[folder allItems] count] > 0) {
		[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	} else {
//		[self showAddPopup];
	}
	
}
#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	addPopover = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

-(void)showAddPopup
{
	
	if (!self.addPopover) {
		
#if TESTFLIGHT
		[TestFlight passCheckpoint:@"Saw Add Event Popup"];
#endif
		//		Create a label with custom text 
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
		[label setText:@"Tap here and add an event."];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor whiteColor]];
		[label setTextAlignment:UITextAlignmentCenter];
		
		UIFont *font = [UIFont boldSystemFontOfSize:11];
		[label setFont:font];
		CGSize size = [label.text sizeWithFont:font];
		CGRect frame = CGRectMake(0, 0, size.width + 10, size.height + 10); // add a bit of a border around the text
		label.frame = frame;
		
		//  place inside a temporary view controller and add to popover
		UIViewController *viewCon = [[UIViewController alloc] init];
		viewCon.view = label;
		viewCon.contentSizeForViewInPopover = frame.size;       // Set the content size
		
		addPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
		[addPopover setDelegate:self];
	}
	
	if([addPopover isPopoverVisible]) {
		[addPopover dismissPopoverAnimated:YES];
		[addPopover setDelegate:nil];
		addPopover = nil;
	} else {		
		[addPopover presentPopoverFromRect:CGRectMake(298, 445, 1, 1)
																inView:self.navigationController.view
							permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
															animated:YES];
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
	
	[edc setEvent:[[Event alloc] init]];
	[edc setFolder:folder];
	[edc setDelegate:self];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:edc];

	if ([[UIDevice currentDevice] userInterfaceIdiom	] == UIUserInterfaceIdiomPad) {
		[newNavController setModalPresentationStyle:UIModalPresentationFormSheet];
	}

	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	id item = [[folder allItems] objectAtIndex:[indexPath row]];
	
	if ([tableView isEditing]) {
		EventDetailController *edc = [[EventDetailController alloc] init];
		[edc setEvent:item];
		[edc setFolder:folder];
		[[self navigationController] pushViewController:edc animated:YES];
		
		[self setEditing:NO animated:NO];
		
	} else {
		
		[self.detailViewController setFolder:folder];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			[self.detailViewController setEvent:item];			
			[[self navigationController] pushViewController:self.detailViewController animated:YES];
		} else {
			[self.detailViewController setEvent:item];			
		}
	}
		
		
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id item = [[folder allItems] objectAtIndex:[indexPath row]];
		[folder removeItem:item];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if ([[folder allItems] count] == 0) {
			[[self navigationItem] setRightBarButtonItem:nil];
			[self setEditing:NO animated:YES];
			[self showAddPopup];
		}
		
		[[EventStore defaultStore] saveChanges];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[folder allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	id item = [[folder allItems] objectAtIndex:[indexPath row]];
		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EventCell"];
	}
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[[cell textLabel] setText:[item objectName]];
	[[cell detailTextLabel] setText:[item subtitle]];
	
	return cell;
}

#pragma mark - ItemDetailViewControllerDelegate
- (void) itemDetailViewControllerWillDismiss:(CustomTableViewController *)ctvc
{
	[[self eventTableView] reloadData];
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
