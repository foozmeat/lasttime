//
//  FolderPickerCell.m
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderPickerCell.h"

@implementation FolderPickerCell
@synthesize pickerView, delegate, inputAccessoryView;
@synthesize rootFolder;

- (void)initalizeInputView {
	self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	self.pickerView.showsSelectionIndicator = YES;
	self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[pickerView setDataSource:self];
	[pickerView setDelegate:self];

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
	NSInteger folderIndex = [[rootFolder allFolders] indexOfObject:currentFolder];
	
	[pickerView selectRow:folderIndex inComponent:0 animated:NO];
		
}

#pragma mark - KeyInput
- (UIView *)inputView {
	return self.pickerView;
}

- (UIView *)inputAccessoryView {
	if (!inputAccessoryView) {
		inputAccessoryView = [[UIToolbar alloc] init];
		inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
		inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[inputAccessoryView sizeToFit];
		CGRect frame = inputAccessoryView.frame;
		frame.size.height = 44.0f;
		inputAccessoryView.frame = frame;
		
		UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
		UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
		[inputAccessoryView setItems:array];
	}
	return inputAccessoryView;
}

- (void)done:(id)sender {
	[self resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
	[self.pickerView setNeedsLayout];
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
	[cell setTag:tag];
	
	return cell;

	
}

@end