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
@synthesize delegate, pickerView;

- (void)initalizeInputView {
	self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	self.pickerView.showsSelectionIndicator = YES;
	[pickerView setDataSource:self];
	[pickerView setDelegate:self];

	LTStyleManager *sm = [LTStyleManager manager];

	self.textLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];
	self.detailTextLabel.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];

	self.detailTextLabel.textColor = [sm defaultColor];
	self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)setFolder
{
	EventFolder *currentFolder = [[self delegate] folderPickerCurrentFolder];
	NSInteger folderIndex = [[[EventStore defaultStore] allFolders] indexOfObject:currentFolder];

	[pickerView selectRow:folderIndex inComponent:0 animated:NO];

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

- (UIView *)pickerView:(UIPickerView *)pickerView
						viewForRow:(NSInteger)row
					forComponent:(NSInteger)component
					 reusingView:(UIView *)view {

  UILabel *pickerLabel = (UILabel *)view;

	LTStyleManager *sm = [LTStyleManager manager];

  if (pickerLabel == nil) {
    CGRect frame = CGRectMake(0.0, 0.0, self.superview.frame.size.width - 40, 32);
    pickerLabel = [[UILabel alloc] initWithFrame:frame];
		pickerLabel.adjustsFontSizeToFitWidth = NO;
    [pickerLabel setTextAlignment:UITextAlignmentLeft];
    [pickerLabel setBackgroundColor:[UIColor clearColor]];
    [pickerLabel setFont:[sm cellLabelFontWithSize:[UIFont labelFontSize]]];
  }

  [pickerLabel setText:[self pickerView:self.pickerView titleForRow:row forComponent:component]];

  return pickerLabel;

}

#pragma mark - Popover Delegate

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
