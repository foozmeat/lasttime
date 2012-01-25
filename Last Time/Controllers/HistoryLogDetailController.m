//
//  HistoryLogDetailController.m
//  Last Time
//
//  Created by James Moore on 1/25/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HistoryLogDetailController.h"
#import "LogEntry.h"

@implementation HistoryLogDetailController
@synthesize logEntry;

- (id)initForNewItem:(BOOL)isNew
{
	self = [super initWithStyle:UITableViewStyleGrouped];

	if (self) {
		if (isNew) {
			UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
			[[self navigationItem] setRightBarButtonItem:doneItem];
			
			UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
			[[self navigationItem] setLeftBarButtonItem:cancelItem];
			
			[[self navigationItem] setTitle:@"Log Entry"];
		}
		
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

#pragma mark TableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
	}
	
	if ([indexPath row] == 0) {
		cell.textLabel.text = [logEntry logEntryNote];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
	} else if ([indexPath row] == 1) {
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		
		[df setDateStyle:NSDateFormatterMediumStyle];
		[df setTimeStyle:NSDateFormatterNoStyle];
		
		cell.textLabel.text = [df stringFromDate:[logEntry logEntryDateOccured]];
		
	}
	
	return cell;
}


@end
