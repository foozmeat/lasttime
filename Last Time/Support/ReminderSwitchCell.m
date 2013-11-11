//
//  ReminderSwitchCell.m
//  Last Time
//
//  Created by James Moore on 2/17/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "ReminderSwitchCell.h"

@implementation ReminderSwitchCell
@synthesize reminderSwitch, delegate, drawBorder, lineView;

- (void)initalizeInputView {
	// Initialization code
	self.selectionStyle = UITableViewCellSelectionStyleNone;

	self.reminderSwitch = [[UISwitch alloc] init];
	[reminderSwitch addTarget:delegate action:@selector(reminderSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	[reminderSwitch setOn:NO];

	self.accessoryView = reminderSwitch;
	LTStyleManager *sm = [LTStyleManager manager];

	[reminderSwitch setOnTintColor:[sm tintColor]];

	self.textLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];
	self.textLabel.text = NSLocalizedString(@"Reminder?",@"Reminder?");
	if (![[UIDevice currentDevice].systemVersion hasPrefix:@"7"]) {
		self.drawBorder = YES;
	}
	self.lineView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 1.0, self.contentView.frame.size.width + 10.0, 1)];
	self.lineView.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1.0];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self initalizeInputView];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (self.drawBorder) {
		[self.contentView addSubview:self.lineView];
	} else {
		[self.lineView removeFromSuperview];
	}
}


+ (ReminderSwitchCell *)newReminderCellWithTag:(NSInteger)tag withDelegate:(id) delegate
{
	ReminderSwitchCell *cell = [[ReminderSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reminderSwitchCell"];
	[cell setDelegate:delegate];
	[cell setTag:tag];

	return cell;

}

@end
