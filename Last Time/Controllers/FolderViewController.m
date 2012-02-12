//
//  LogEntryViewController.m
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderViewController.h"
#import "EventController.h"
#import "EventDetailController.h"
#import "FolderDetailController.h"

@implementation FolderViewController
@synthesize rootFolder;
@synthesize folderTableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

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
	if (!rootFolder) {			
		rootFolder = [[EventFolder alloc] initWithRoot:YES];
	}
	if ([rootFolder isRoot]) {
		self.title = NSLocalizedString(@"Home", @"Home");
	} else {
		self.title = [rootFolder folderName];
	}
	
	if ([[rootFolder allItems] count] > 0) {
		[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	}

	[[self folderTableView] reloadData];
}

#pragma mark - IBActions

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	[super setEditing:editing animated:animate];

	[folderTableView setEditing:editing animated:animate];
}

- (void)addNewEvent
{
	EventDetailController *edc = [[EventDetailController alloc] init];
	
	[edc setEvent:[[Event alloc] init]];
	[edc setRootFolder:rootFolder];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:edc];
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	
}

- (void)addNewFolder
{
	// Make new folder
	FolderDetailController *fdc = [[FolderDetailController alloc] init];
	[fdc setFolder:[[EventFolder alloc] init]];
	[fdc setRootFolder:rootFolder];
	
	UINavigationController *newNavController = [[UINavigationController alloc]
																							initWithRootViewController:fdc];
	
	[[self navigationController] presentModalViewController:newNavController
																								 animated:YES];
	
}

- (void)addNewItem:(id)sender
{

	if ([rootFolder isRoot] == NO) {
		[self addNewEvent];
	} else {
		UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"What would you like create?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Event", @"New Folder", nil];
		as.actionSheetStyle = UIActionSheetStyleDefault;
		[as showInView:self.view];		
	}	
}

// Action sheet delegate method.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		[self addNewEvent];
	} else if (buttonIndex == 1) {
		[self addNewFolder];
	}
}

#pragma mark -
#pragma mark TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	id item = [[rootFolder allItems] objectAtIndex:[indexPath row]];
		
	if ([item isMemberOfClass:[Event class]]) {
		
		if ([folderTableView isEditing]) {
			EventDetailController *edc = [[EventDetailController alloc] init];
			[edc setEvent:item];
			[edc setRootFolder:rootFolder];
			[[self navigationController] pushViewController:edc animated:YES];
			
			[folderTableView setEditing:NO animated:NO];

		} else {
			
			EventController *ec = [[EventController alloc] init];
			[ec setEvent:item];			
			[[self navigationController] pushViewController:ec animated:YES];
		}
		
		
	} else if ([item isMemberOfClass:[EventFolder class]]) {
		
		if ([folderTableView isEditing]) {
			FolderDetailController *fdc = [[FolderDetailController alloc] init];
			[fdc setFolder:item];
			[fdc setRootFolder:rootFolder];
			[[self navigationController] pushViewController:fdc animated:YES];
			
			[folderTableView setEditing:NO animated:NO];
			
		} else {
			FolderViewController *fvc = [[FolderViewController alloc] init];
			[fvc setRootFolder:item];
			[[self navigationController] pushViewController:fvc animated:YES];
			
		}
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id item = [[rootFolder allItems] objectAtIndex:[indexPath row]];
		[rootFolder removeItem:item];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];

		if ([[rootFolder allItems] count] == 0) {
			[[self navigationItem] setRightBarButtonItem:nil];
		}

	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[rootFolder allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *reuseString = nil;
	
	id item = [[rootFolder allItems] objectAtIndex:[indexPath row]];

	if ([item isMemberOfClass:[EventFolder class]]) {
		reuseString = @"FolderCell";
	} else {
		reuseString = @"EventCell";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseString];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseString];
	}
	
	if ([item isMemberOfClass:[EventFolder class]]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[[cell textLabel] setText:[item objectName]];
	[[cell detailTextLabel] setText:[item subtitle]];
	
	return cell;
}

@end
