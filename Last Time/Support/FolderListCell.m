//
//  FolderListCell.m
//  Last Time
//
//  Created by James Moore on 2/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderListCell.h"

@implementation FolderListCell
@synthesize cellTextField;
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ( !(self = [super initWithCoder:aDecoder]) ) return nil;

	self.cellTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	self.cellTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.cellTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	self.cellTextField.textAlignment = UITextAlignmentLeft;
	self.cellTextField.textColor = [UIColor blackColor];
	self.cellTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
	self.cellTextField.clearButtonMode = UITextFieldViewModeNever;
	self.cellTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.cellTextField.returnKeyType = UIReturnKeyDone;
	self.cellTextField.hidden = YES;

//	self.detailTextLabel.textColor = [UIColor brownColor];
	[self addSubview:self.cellTextField];
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	
//	[super setSelected:selected animated:animated];
	if (selected && self.editing == YES) {
		[self.cellTextField becomeFirstResponder];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

	self.cellTextField.text = self.textLabel.text;

	CGRect editFrame = CGRectInset(self.contentView.frame, 10, 11);
	
	self.cellTextField.frame = editFrame;
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
