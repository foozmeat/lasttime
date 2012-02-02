//
//  LogEntryViewController.m
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderViewController.h"
#import "EventController.h"

@implementation FolderViewController
@synthesize rootFolder;


- (id) init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	if (self) {
		UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																																				 target:self 
																																				 action:@selector(addNewItem:)];


		[[self navigationItem] setRightBarButtonItem:bbi];		
		 
	}
		
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

#pragma mark IBActions

- (void)toggleEditingMode:(id)sender
{
	if ([self isEditing]) {
//		[sender setTitle:@"Edit" forState:UIControlStateNormal];
		[self setEditing:NO animated:YES];
	} else {
//		[sender setTitle:@"Done" forState:UIControlStateNormal];
		[self setEditing:YES animated:YES];
		
	}
}

- (void)addNewItem:(id)sender
{
	[rootFolder createEvent];
	[[self tableView] reloadData];
	
}
#pragma mark TableView Delegate methods

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!rootFolder) {			
		rootFolder = [[EventFolder alloc] initWithRandomDataAsRoot:YES];
	}
	[[self navigationItem] setTitle:[rootFolder folderName]];
	[[self tableView] reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	id item = [[rootFolder allItems] objectAtIndex:[indexPath row]];
		
	if ([item isMemberOfClass:[Event class]]) {
		EventController *ec = [[EventController alloc] init];
		
		[ec setEvent:item];
		
		[[self navigationController] pushViewController:ec animated:YES];
		
	} else if ([item isMemberOfClass:[EventFolder class]]) {
		
		FolderViewController *fdc = [[FolderViewController alloc] init];
		[fdc setRootFolder:item];
		[[self navigationController] pushViewController:fdc animated:YES];

	}
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id item = [[rootFolder allItems] objectAtIndex:[indexPath row]];
		[rootFolder removeItem:item];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[rootFolder allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
	}
	
	id item = [[rootFolder allItems] objectAtIndex:[indexPath row]];
	
	if ([item isMemberOfClass:[EventFolder class]]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[[cell textLabel] setText:[item objectName]];
	[[cell detailTextLabel] setText:[item subtitle]];
	
	return cell;
}

@end
