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

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:style reuseIdentifier:identifier];
	
	if (self == nil)
	{ 
		return nil;
	}
	
	CGRect rect = CGRectMake(83, 11, self.contentView.bounds.size.width-113, 23);
	UITextField *textField = [[UITextField alloc] initWithFrame:rect];
	
	//  Set the keyboard's return key label to 'Next'.
	//
	[textField setReturnKeyType:UIReturnKeyNext];
	[textField setTextAlignment:UITextAlignmentRight];
	//  Make the clear button appear automatically.
	[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[textField setBackgroundColor:[UIColor clearColor]];
	[textField setOpaque:NO];
	
	[[self contentView] addSubview:textField];
	[self setCellTextField:textField];
	
	return self;
}

//  Disable highlighting of currently selected cell.
//
- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated 
{
	[super setSelected:selected animated:NO];
	
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

//  Convenience method that returns a fully configured new instance of 
//  EditableDetailCell.

+ (EditableTableCell *)newDetailCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{
	
	EditableTableCell *cell = [[EditableTableCell alloc] initWithStyle:UITableViewCellStyleValue1 
																										 reuseIdentifier:@"EditableTableCell"];
	[[cell cellTextField] setDelegate:delegate];
	[[cell cellTextField] setTag:tag];
	
	return cell;
}

@end
