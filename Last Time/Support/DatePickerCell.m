//
//  DatePickerCell.m
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "DatePickerCell.h"

@implementation DatePickerCell
@synthesize pickerView, df, delegate, inputAccessoryView, datePopover;

- (void)initalizeInputView {
	df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterFullStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];
	
	pickerView = [[UIDatePicker alloc] init];
	[pickerView setMinuteInterval:15];
	[pickerView setMaximumDate:[NSDate date]];
	[pickerView setDatePickerMode:UIDatePickerModeDate];
	 
	NSDate *now = [[NSDate alloc] init];
	[pickerView setDate:now];
	[pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	
	[[self detailTextLabel] setText:[df stringFromDate:[pickerView date]]];
	self.detailTextLabel.textColor = [UIColor brownColor];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		UIViewController *datePickerViewController = [[UIViewController alloc] init];
		
		[[datePickerViewController view] addSubview:pickerView];
		datePopover = [[UIPopoverController alloc] initWithContentViewController:datePickerViewController];
		[datePopover setPopoverContentSize:pickerView.frame.size];
		[datePopover setDelegate:self];
		
	} else {
		CGRect frame = self.inputView.frame;
		frame.size = [self.pickerView sizeThatFits:CGSizeZero];
		self.inputView.frame = frame;
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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return self.pickerView;
	} else {
		return nil;
	}
}

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}

- (BOOL)becomeFirstResponder {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[self.pickerView setNeedsLayout];
	} else {
		[datePopover presentPopoverFromRect:[self bounds] 
																 inView:self 
							 permittedArrowDirections:UIPopoverArrowDirectionLeft 
															 animated:YES];
		[delegate popoverController:datePopover isShowing:YES];
	}
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	UITableView *tableView = (UITableView *)self.superview;
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

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self resignFirstResponder];
	[delegate popoverController:datePopover isShowing:NO];
}


#pragma mark - UIDatePicker

- (void)dateChanged:(id)sender
{
	[[self detailTextLabel] setText:[df stringFromDate:[pickerView date]]];
	[delegate pickerDidChange:[pickerView date]];
}

+ (DatePickerCell *)newDateCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{
	DatePickerCell *cell = [[DatePickerCell alloc] initWithStyle:UITableViewCellStyleValue1 
																							 reuseIdentifier:@"DatePickerCell"];
	
	[cell setDelegate:delegate];
	[[cell pickerView] setTag:tag];
	
	return cell;

	
}

@end
