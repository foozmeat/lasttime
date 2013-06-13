//
//  DatePickerCell.m
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "DatePickerCell.h"

@implementation DatePickerCell
@synthesize pickerView, df, delegate, pickerPopover;

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
//	self.detailTextLabel.textColor = [UIColor brownColor];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		UIViewController *datePickerViewController = [[UIViewController alloc] init];
		
		[[datePickerViewController view] addSubview:pickerView];
		pickerPopover = [[UIPopoverController alloc] initWithContentViewController:datePickerViewController];
		[pickerPopover setPopoverContentSize:pickerView.frame.size];
		[pickerPopover setDelegate:self];
		
	} else {
		CGRect frame = self.inputView.frame;
		frame.size = [self.pickerView sizeThatFits:CGSizeZero];
		self.inputView.frame = frame;
	}
}

#pragma mark - KeyInput

- (BOOL)becomeFirstResponder {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[self.pickerView setNeedsLayout];
	} else {
		[pickerPopover presentPopoverFromRect:[self bounds] 
																 inView:self 
							 permittedArrowDirections:UIPopoverArrowDirectionLeft 
															 animated:YES];
		[delegate popoverController:pickerPopover isShowing:YES];
	}
	return [super becomeFirstResponder];
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self resignFirstResponder];
	[delegate popoverController:pickerPopover isShowing:NO];
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
