//
//  FolderListCell.m
//  Last Time
//
//  Created by James Moore on 2/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderListCell.h"

@implementation FolderListCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ( !(self = [super initWithCoder:aDecoder]) ) return nil;

    LTStyleManager *sm = [LTStyleManager manager];

	self.cellTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	self.cellTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.cellTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	self.cellTextField.textAlignment = NSTextAlignmentLeft;
	self.cellTextField.textColor = [sm defaultColor];
	self.cellTextField.clearButtonMode = UITextFieldViewModeNever;
	self.cellTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.cellTextField.returnKeyType = UIReturnKeyDone;
	self.cellTextField.hidden = YES;
	self.cellTextField.font = [sm cellLabelFontWithSize:[UIFont labelFontSize]];

	[self.contentView addSubview:self.cellTextField];
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	
	if (selected && self.editing == YES) {
		[self.cellTextField becomeFirstResponder];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

	self.cellTextField.text = self.textLabel.text;
	self.cellTextField.frame = self.contentView.frame;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing) {
		self.textLabel.hidden = YES;
		self.detailTextLabel.hidden = YES;
		self.cellTextField.hidden = NO;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.textLabel.hidden = NO;
		self.detailTextLabel.hidden = NO;
		self.cellTextField.hidden = YES;
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		[[self cellTextField] resignFirstResponder];
	}
}
@end
