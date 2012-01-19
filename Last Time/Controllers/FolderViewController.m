//
//  LogEntryViewController.m
//  Last Time
//
//  Created by James Moore on 1/12/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderViewController.h"
#import "EventFolder.h"
#import "LogEntry.h"
#import "Event.h"

@implementation FolderViewController
- (id) init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	if (self) {
		UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																																				 target:self 
																																				 action:@selector(addNewItem:)];
		[[self navigationItem] setRightBarButtonItem:bbi];		
		[[self navigationItem] setTitle:@"Home"];
		[[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
		 
		rootFolder = [[EventFolder alloc] initWithRandomDataAsRoot:YES];
	}
		
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	NSLog(@"%@", style);
	return [self init];
}

#pragma mark IBActions

- (void)toggleEditingMode:(id)sender
{
	if ([self isEditing]) {
		[sender setTitle:@"Edit" forState:UIControlStateNormal];
		[self setEditing:NO animated:YES];
	} else {
		[sender setTitle:@"Done" forState:UIControlStateNormal];
		[self setEditing:YES animated:YES];
		
	}
}

- (void)addNewItem:(id)sender
{
	[rootFolder createEvent];
	[[self tableView] reloadData];
	
}
#pragma mark TableView Delegate methods

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
	
	[[cell textLabel] setText:[item objectName]];
	[[cell detailTextLabel] setText:[item subtitle]];
	
	return cell;
}

@end
