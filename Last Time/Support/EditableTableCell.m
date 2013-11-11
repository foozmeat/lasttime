//
//  EditableTableCell.m
//  Last Time
//
//  Created by James Moore on 2/6/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EditableTableCell.h"


@implementation EditableTableCell

@synthesize cellTextField;
@synthesize drawBorder;

- (void)initalizeInputView {
	// Initialization code
	LTStyleManager *sm = [LTStyleManager manager];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.cellTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	self.cellTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.cellTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	self.cellTextField.textAlignment = UITextAlignmentRight;
	self.cellTextField.clearButtonMode = UITextFieldViewModeNever;
	self.cellTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.cellTextField.returnKeyType = UIReturnKeyNext;
	self.cellTextField.textColor = [sm defaultColor];
	self.cellTextField.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];

	self.detailTextLabel.textColor = [sm tintColor];

	self.textLabel.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];
	self.detailTextLabel.font = [sm cellDetailFontWithSize:[UIFont labelFontSize]];

	[self addSubview:self.cellTextField];

	self.accessoryType = UITableViewCellAccessoryNone;

	if (![[UIDevice currentDevice].systemVersion hasPrefix:@"7"]) {
		self.drawBorder = YES;
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

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (selected) {
		[self.cellTextField becomeFirstResponder];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	if (selected) {
		[self.cellTextField becomeFirstResponder];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.cellTextField resignFirstResponder];
	return YES;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect editFrame = CGRectInset(self.contentView.frame, 10, 10);

	if (self.textLabel.text && [self.textLabel.text length] != 0) {
		CGSize textSize = [self.textLabel sizeThatFits:CGSizeZero];
		editFrame.origin.x += textSize.width + 10;
		editFrame.size.width -= textSize.width + 10;
		self.cellTextField.textAlignment = UITextAlignmentRight;
	} else {
		self.cellTextField.textAlignment = UITextAlignmentLeft;
	}
	
	self.cellTextField.frame = editFrame;

	if (self.drawBorder) {
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 1.0, self.contentView.frame.size.width + 10.0, 1)];
		lineView.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1.0];
		[self.contentView addSubview:lineView];
	}
}

- (void)setStringValue:(NSString *)value {
	self.cellTextField.text = value;
}

- (NSString *)stringValue {
	return self.cellTextField.text;
}

//  Convenience method that returns a fully configured new instance of
//  EditableDetailCell.

+ (EditableTableCell *)newDetailCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{

	EditableTableCell *cell = [[EditableTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditableTableCell"];
	[[cell cellTextField] setDelegate:delegate];
	[[cell cellTextField] setTag:tag];

	return cell;
}

@end
