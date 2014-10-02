//
//  DatePickerCell.m
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "DatePickerCell.h"

@implementation DatePickerCell
@synthesize pickerView, df, delegate;

- (void)initalizeInputView
{
	[self initalizeBaseInputView];
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

	CGRect frame = self.inputView.frame;
	frame.size = [self.pickerView sizeThatFits:CGSizeZero];
	self.inputView.frame = frame;
	self.selectionStyle = UITableViewCellSelectionStyleGray;

}

#pragma mark - UIDatePicker

- (void)dateChanged:(id)sender
{
	[[self detailTextLabel] setText:[df stringFromDate:[pickerView date]]];
	[delegate pickerDidChange:[pickerView date]];
}

+ (DatePickerCell *)newDateCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{
	DatePickerCell *cell = [[DatePickerCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DatePickerCell"];

	[cell setDelegate:delegate];
	[[cell pickerView] setTag:tag];

	return cell;


}

@end
