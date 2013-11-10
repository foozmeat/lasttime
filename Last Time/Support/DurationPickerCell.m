//
//  DurationPickerCell.m
//  Last Time
//
//  Created by James Moore on 6/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "DurationPickerCell.h"

@implementation DurationPickerCell
{
	NSInteger _durationValue;
	NSString *_durationUnit;
	NSArray *_unitRows;

}
@synthesize pickerView, delegate;
@synthesize duration;
@synthesize durationLabel;
@synthesize durationStringLabel;
@synthesize durationDateLabel;
@synthesize eventDate = _eventDate;

- (void)initalizeInputView {

	[self initalizeBaseInputView];
	_unitRows = @[@"day", @"week", @"month", @"year"];
	pickerView = [[UIPickerView alloc] init];
	pickerView.delegate = self;
	pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;

	_durationValue = 1;
	_durationUnit = @"day";
	self.eventDate = [NSDate date];

	LTStyleManager *sm = [LTStyleManager manager];

	self.durationStringLabel.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];
	self.durationStringLabel.text = [self durationString];

	self.durationLabel.text = NSLocalizedString(@"Duration",@"Duration");
	self.durationLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];

	self.durationDateLabel.text = [self reminderDateString];
	self.durationDateLabel.font = [sm cellDetailFontWithSize:12.0];

	CGRect frame = self.inputView.frame;
	frame.size = [self.pickerView sizeThatFits:CGSizeZero];
	self.inputView.frame = frame;

	self.selectionStyle = UITableViewCellSelectionStyleGray;

	self.drawBorder = NO;
}

- (void)setEventDate:(NSDate *)date
{
	_eventDate = date;
	[self updateDateStringColor];
}

#pragma mark - UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component == kNumber) {
		return [[NSNumber numberWithInt:(row + 1)] stringValue];
	} else if (component == kUnit) {

		return [self durationUnitFromNumber:_durationValue
															 withUnit:[_unitRows objectAtIndex:row]];

	} else {
		return @"Error";
	}

}

- (UIView *)pickerView:(UIPickerView *)pickerView
						viewForRow:(NSInteger)row
					forComponent:(NSInteger)component
					 reusingView:(UIView *)view {

  UILabel *pickerLabel = (UILabel *)view;

	LTStyleManager *sm = [LTStyleManager manager];

  if (pickerLabel == nil) {
    CGRect frame = CGRectMake(0.0, 0.0, 100, 32);
    pickerLabel = [[UILabel alloc] initWithFrame:frame];
		pickerLabel.adjustsFontSizeToFitWidth = NO;
    [pickerLabel setTextAlignment:UITextAlignmentLeft];
    [pickerLabel setBackgroundColor:[UIColor clearColor]];
    [pickerLabel setFont:[sm cellLabelFontWithSize:[UIFont labelFontSize]]];
  }

  [pickerLabel setText:[self pickerView:self.pickerView titleForRow:row forComponent:component]];

  return pickerLabel;
	
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == kNumber) {
		_durationValue = row + 1;
	} else if (component == kUnit) {
		_durationUnit = [_unitRows objectAtIndex:row];
	}
	self.duration = [self durationFromPicker];
	self.durationStringLabel.text = [self durationString];
	self.durationDateLabel.text = [self reminderDateString];

	[self updateDateStringColor];

	[delegate durationPickerDidChangeWithDuration:[self durationFromPicker]];

	[[self pickerView] reloadComponent:kUnit];

	DLog(@"Duration changed: %@", [self durationString]);
}



- (void)updateDateStringColor
{
	LTStyleManager *sm = [LTStyleManager manager];
	if ([self reminderExpired]) {
		self.durationDateLabel.textColor = [sm alarmColor];
	} else {
		self.durationDateLabel.textColor = [sm defaultColor];
	}

}

- (void)updateEventDate:(NSDate *)date
{
	self.eventDate = date;
	self.durationDateLabel.text = [self reminderDateString];

}

- (BOOL)reminderExpired
{
	if (self.eventDate == nil) {
		return NO;
	}

	NSDate *reminderDate = [[NSDate alloc] initWithTimeInterval:self.duration
																										sinceDate:self.eventDate];

	NSInteger interval = [reminderDate timeIntervalSinceNow];

	if (interval >= 0) {
		return NO;
	} else {
		return YES;
	}
}

- (NSString *)durationString
{
	return [NSString stringWithFormat:@"%d %@", _durationValue, [self durationUnitFromNumber:_durationValue withUnit:_durationUnit]];
}

- (NSString *)durationUnitFromNumber:(NSInteger)number
														withUnit:(NSString *)unit
{
	NSString *nbyear = nil;
	if(number != 1)
		nbyear = NSLocalizedString(@"years",@"more than one year");
	else
		nbyear = NSLocalizedString(@"year",@"one year");

	NSString *nbmonth = nil;
	if(number != 1)
		nbmonth = NSLocalizedString(@"months",@"more than one month");
	else
		nbmonth = NSLocalizedString(@"month",@"one month");

	NSString *nbweek = nil;
	if(number != 1)
		nbweek = NSLocalizedString(@"weeks",@"more than one week");
	else
		nbweek = NSLocalizedString(@"week",@"one week");

	NSString *nbday = nil;
	if(number != 1)
		nbday = NSLocalizedString(@"days",@"more than one day");
	else
		nbday = NSLocalizedString(@"day",@"one day");

	if ([unit isEqualToString:@"day"]) {
		return nbday;
	} else if ([unit isEqualToString:@"week"]) {
		return nbweek;
	} else if ([unit isEqualToString:@"month"]) {
		return nbmonth;
	} else if ([unit isEqualToString:@"year"]) {
		return nbyear;
	} else {
		return @"duration error";
	}
}


#pragma mark - UIPickerView Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return NUM_COMPONANTS;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == kNumber) {
		return 30;
	} else if (component == kUnit) {
		return NUM_UNITS;
	} else {
		return 0;
	}

}

#pragma mark - UIPicker

- (NSInteger)durationFromPicker
{

	NSInteger day = 60 * 60 * 24;

	if ([_durationUnit isEqualToString:@"day"]) {
		return day * _durationValue;
	} else if ([_durationUnit isEqualToString:@"week"]) {
		return day * 7 * _durationValue;
	} else if ([_durationUnit isEqualToString:@"month"]) {
		return day * 30 * _durationValue;
	} else if ([_durationUnit isEqualToString:@"year"]) {
		return day * 365 * _durationValue;
	} else {
		return 0;
	}

}

- (void)setupPickerComponants
{

	DLog(@"Duration: %d", self.duration);

	if (self.duration == 0) {
		_durationValue = 1;
		_durationUnit = @"day";
	} else {

		int day = 60 * 60 * 24;
		int week = 7;
		int month = 30;
		int year = day * 365;

		int days = self.duration / day;

		if (days % month == 0) {
			_durationValue = days / month;
			_durationUnit = @"month";

		} else if (days % week == 0) {
			_durationValue = days / week;
			_durationUnit = @"week";

		} else if (days % year == 0) {
			_durationValue = days / year;
			_durationUnit = @"year";

		} else {
			_durationValue = days;
			_durationUnit = @"day";

		}
	}
	self.durationStringLabel.text = [self durationString];
	self.durationDateLabel.text = [self reminderDateString];
	[[self pickerView] selectRow:(_durationValue - 1) inComponent:kNumber animated:NO];
	[[self pickerView] selectRow:[_unitRows indexOfObject:_durationUnit] inComponent:kUnit animated:NO];

	DLog(@"Picker set to %d, %@", _durationValue, _durationUnit);

	return;

}

- (NSString *)reminderDateString
{
	if (self.duration == 0 || self.eventDate == nil) {
		return @"";
	}

	NSDate *reminderDate = [[NSDate alloc] initWithTimeInterval:self.duration sinceDate:self.eventDate];

	NSDateFormatter *df = [[NSDateFormatter alloc] init];

	[df setDateStyle:NSDateFormatterFullStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];

	NSString *reminderDateString = [df stringFromDate:reminderDate];

	return reminderDateString;

}

+ (DurationPickerCell *)newDurationCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{
	UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"DurationPickerCell" bundle:nil];
	DurationPickerCell *cell = (DurationPickerCell *)temporaryController.view;

	[cell initalizeInputView];
	[cell setDelegate:delegate];
	[[cell pickerView] setTag:tag];

	return cell;


}

@end
