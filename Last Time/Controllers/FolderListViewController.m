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
#import "WEPopoverController.h"
#import "EventListViewController.h"

@implementation FolderListViewController
@synthesize rootFolder, folder;
@synthesize folderTableView;
@synthesize addPopover;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
	[self setFolderTableView:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!folder) {		
		[self setFolder:[[EventFolder alloc] initWithRoot:YES]];
	}

	if ([[self folder] isRoot]) {
		rootFolder = folder;
	}
	
	self.title = [folder folderName];
	
	
	if ([[folder allItems] count] > 0) {
		[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	} else {
		[self showAddPopup];
	}

	[[self folderTableView] reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if ([folderTableView isEditing]) {
		[self setEditing:NO animated:YES];
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
		[TestFlight passCheckpoint:@"Saw First Run Popup"];
#endif
		//		Create a label with custom text 
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
		[label setText:@"To get started, tap here and add an event."];
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

	[folderTableView setEditing:editing animated:animate];
	
	NSArray *paths = [NSArray arrayWithObject:	[NSIndexPath indexPathForRow:[[folder allItems] count] inSection:0]];
	if (editing)
	{
		[[self folderTableView] insertRowsAtIndexPaths:paths 
														withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else {
		[[self folderTableView] deleteRowsAtIndexPaths:paths 
														withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)addNewItem:(id)sender

//- (void)addNewFolder
{
	// Make new folder
	FolderDetailController *fdc = [[FolderDetailController alloc] init];
	[fdc setTheNewFolder:[[EventFolder alloc] init]];
	[fdc setRootFolder:rootFolder];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:fdc];
	
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	
}


#pragma mark - TableView Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([tableView isEditing]) {
		if( indexPath.row == (int)[[folder allItems] count] ) {
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
	
	if( indexPath.row == (int)[[folder allItems] count] ) {
		item = [[EventFolder alloc] init];
	} else {
		
		item = [[folder allItems] objectAtIndex:[indexPath row]];
	}

	if ([tableView isEditing]) {
		FolderDetailController *fdc = [[FolderDetailController alloc] init];
		[fdc setTheNewFolder:item];
		[fdc setRootFolder:rootFolder];
		
		if( indexPath.row == (int)[[folder allItems] count] ) {
			UINavigationController *newNavController = [[UINavigationController alloc]
																									initWithRootViewController:fdc];
			
			[[self navigationController] presentModalViewController:newNavController
																										 animated:YES];
		} else {
			[[self navigationController] pushViewController:fdc animated:YES];
			
		}
	
	
	} else {
		EventListViewController *elvc = [[EventListViewController alloc] init];
		[elvc setRootFolder:rootFolder];
		[elvc setFolder:item];
		[[self navigationController] pushViewController:elvc animated:YES];
		
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
		
		[rootFolder saveChanges];

	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEditing]) {
		return [[folder allItems] count] + 1;
	} else {
		return [[folder allItems] count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *reuseString = nil;
	UITableViewCell *cell = nil;
	
	if ([indexPath row] == (int)[[folder allItems] count]) {
		reuseString = @"addFolderCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}

		[[cell textLabel] setText:@"Add a Folder..."];

	} else {
		
		id item = [[folder allItems] objectAtIndex:[indexPath row]];
		
		reuseString = @"FolderCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:reuseString];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseString];
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:13.0]];
		
		[[cell textLabel] setText:[item objectName]];
		[[cell detailTextLabel] setText:[item subtitle]];
	}
	
	
	return cell;
}

@end
