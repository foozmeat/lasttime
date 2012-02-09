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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
			df = [[NSDateFormatter alloc] init];
			[df setDateStyle:NSDateFormatterMediumStyle];
			[df setTimeStyle:NSDateFormatterShortStyle];
			
			pickerView = [[UIDatePicker alloc] init];
			
			
			NSDate *now = [[NSDate alloc] init];
			[pickerView setDate:now];
			[pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
			
			[[self textLabel] setText:[df stringFromDate:[pickerView date]]];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	
	if (selected == NO) {
		return;
	}
	
	[delegate endEditing];
	
	[super setSelected:selected animated:animated];
	
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	
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

- (void)dateChanged:(id)sender
{
	[[self textLabel] setText:[df stringFromDate:[pickerView date]]];
	[delegate pickerDidChange:[pickerView date]];
}

+ (DatePickerCell *)newDateCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{
	DatePickerCell *cell = [[DatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault 
																							 reuseIdentifier:@"DatePickerCell"];
	
	[cell setDelegate:delegate];
	
	return cell;

	
}

@end
