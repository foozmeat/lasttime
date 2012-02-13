//
//  FolderPickerCell.m
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderPickerCell.h"

@implementation FolderPickerCell
@synthesize pickerView, delegate;
@synthesize rootFolder;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

			pickerView = [[UIPickerView alloc] init];
			[pickerView setDataSource:self];
			[pickerView setDelegate:self];
			[pickerView setShowsSelectionIndicator:YES];
			
			[[self detailTextLabel] setTextColor:[UIColor blackColor]];

    }
    return self;
}

- (void)setFolder
{
	EventFolder *currentFolder = [[self delegate] folderPickerCurrentFolder];
	NSInteger folderIndex = [[rootFolder allFolders] indexOfObject:currentFolder];
	
	[pickerView selectRow:folderIndex inComponent:0 animated:NO];
		
}

#pragma mark - TableView
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	
	if (selected == NO) {
		return;
	}
	
	[delegate endEditing];
	
	[super setSelected:selected animated:animated];
	
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	[self setFolder];
	
	if (self.pickerView.superview == nil)
	{
		[self.delegate.view.superview addSubview: self.pickerView];

		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = self.delegate.view.frame;
		CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
																	screenRect.origin.y + screenRect.size.height,
																	pickerSize.width, pickerSize.height);
		self.pickerView.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
																	 screenRect.origin.y + screenRect.size.height - pickerSize.height,
																	 pickerSize.width,
																	 pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		// we need to perform some post operations after the animation is complete
		[UIView setAnimationDelegate:self];
		
		self.pickerView.frame = pickerRect;
		
		// shrink the table vertical size to make room for the date picker
		CGRect newFrame = delegate.tableView.frame;
		newFrame.size.height -= self.pickerView.frame.size.height;
		delegate.tableView.frame = newFrame;
		[UIView commitAnimations];
	}
}

#pragma mark - PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	return [[rootFolder allFolders] count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[[rootFolder allFolders] objectAtIndex:row] folderName];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	EventFolder *folder = [[rootFolder allFolders] objectAtIndex:row];
	[[self delegate] folderPickerDidChange:folder];
	
	NSLog(@"Selected Folder: %@. Index of selected folder: %i", [folder folderName], row);
	[[self detailTextLabel] setText:[folder folderName]];

}

+ (FolderPickerCell *)newFolderCellWithTag:(NSInteger)tag 
															withDelegate:(id)delegate 
{
	FolderPickerCell *cell = [[FolderPickerCell alloc] initWithStyle:UITableViewCellStyleValue1 
																							 reuseIdentifier:@"FolderPickerCell"];
	
	[cell setDelegate:delegate];
	[cell setRootFolder:[delegate folderPickerRootFolder]];
	
	return cell;

	
}

@end
