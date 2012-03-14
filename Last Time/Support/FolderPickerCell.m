//
//  FolderPickerCell.m
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderPickerCell.h"
#import "EventFolder.h"

@implementation FolderPickerCell
@synthesize pickerView, delegate, inputAccessoryView,folderPopover;

- (void)initalizeInputView {
	self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	self.pickerView.showsSelectionIndicator = YES;
//	self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[pickerView setDataSource:self];
	[pickerView setDelegate:self];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		UIViewController *folderPickerViewController = [[UIViewController alloc] init];
		
		[[folderPickerViewController view] addSubview:pickerView];
		folderPopover = [[UIPopoverController alloc] initWithContentViewController:folderPickerViewController];
		[folderPopover setPopoverContentSize:pickerView.frame.size];
		[folderPopover setDelegate:self];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self initalizeInputView];
	}
	return self;
}

- (void)setFolder
{
	EventFolder *currentFolder = [[self delegate] folderPickerCurrentFolder];
	NSInteger folderIndex = [[[EventStore defaultStore] allFolders] indexOfObject:currentFolder];
	
	[pickerView selectRow:folderIndex inComponent:0 animated:NO];
		
}

#pragma mark - KeyInput
- (UIView *)inputView {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return self.pickerView;
	} else {
		return nil;
	}
}

- (UIView *)inputAccessoryView {
	if (!inputAccessoryView) {
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			inputAccessoryView = [[UIToolbar alloc] init];
			inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
	//		inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[inputAccessoryView sizeToFit];
			CGRect frame = inputAccessoryView.frame;
			frame.size.height = 44.0f;
			inputAccessoryView.frame = frame;
			
			UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
			UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			
			NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
			[inputAccessoryView setItems:array];
		}
	}
	return inputAccessoryView;
}

- (void)done:(id)sender {
	[self resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[self.pickerView setNeedsLayout];
	} else {
		[folderPopover presentPopoverFromRect:[self bounds] 
																 inView:self 
							 permittedArrowDirections:UIPopoverArrowDirectionLeft 
															 animated:YES];
		[delegate popoverController:folderPopover isShowing:YES];
	}
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	UITableView *tableView = (UITableView *)self.superview;
	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
	return [super resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - TableView
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	if (selected) {
		[self setFolder];
		[self becomeFirstResponder];
	}
}

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}

#pragma mark - PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	return [[[EventStore defaultStore] allFolders] count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[[[EventStore defaultStore] allFolders] objectAtIndex:row] folderName];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	EventFolder *folder = [[[EventStore defaultStore] allFolders] objectAtIndex:row];
	[[self delegate] folderPickerDidChange:folder];
	
//	NSLog(@"Selected Folder: %@. Index of selected folder: %i", [folder folderName], row);
	[[self detailTextLabel] setText:[folder folderName]];

}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self resignFirstResponder];
	[delegate popoverController:folderPopover isShowing:NO];
}

+ (FolderPickerCell *)newFolderCellWithTag:(NSInteger)tag 
															withDelegate:(id)delegate 
{
	FolderPickerCell *cell = [[FolderPickerCell alloc] initWithStyle:UITableViewCellStyleValue1 
																							 reuseIdentifier:@"FolderPickerCell"];
	
	[cell setDelegate:delegate];
	[cell setTag:tag];
	
	return cell;

	
}

@end
