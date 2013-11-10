//
//  BasePickerCell.m
//  Last Time
//
//  Created by James Moore on 6/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "BasePickerCell.h"

@implementation BasePickerCell
@synthesize inputAccessoryView, pickerView, pickerPopover, drawBorder;

- (void)initalizeBaseInputView {

	LTStyleManager *sm = [LTStyleManager manager];
	self.textLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];
	self.detailTextLabel.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];
	self.detailTextLabel.textColor = [sm defaultColor];
	self.drawBorder = YES;
	return;
}

- (void) initalizeInputView
{
    [self initalizeBaseInputView];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self initalizeInputView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (self.drawBorder) {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 1.0, self.contentView.frame.size.width + 10.0, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1.0];
    [self.contentView addSubview:lineView];
	}
}

- (UIView *)inputAccessoryView {
	if (!inputAccessoryView) {
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			
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
	}
	return inputAccessoryView;
}

- (void)done:(id)sender {
	[self resignFirstResponder];
}

#pragma mark - KeyInput
- (UIView *)inputView {
	return self.pickerView;
}

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}

- (BOOL)resignFirstResponder {
	UITableView *tableView;

	if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"]) {
		// On iOS 7 the textfield get's put inside of a scrollview
		tableView = (UITableView *)self.superview.superview;
	} else {
		tableView = (UITableView *)self.superview;
	}

	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:NO];
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
		[self becomeFirstResponder];
	}
}

#pragma mark - PickerCell Delegate
- (void)valueChanged:(id)sender
{
#ifdef DEBUG
	NSLog(@"Base Picker Changed");
#endif
}


@end
