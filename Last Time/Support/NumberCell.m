//
//  NumberCell.m
//  Last Time
//
//  Created by James Moore on 2/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "NumberCell.h"
#import "EditableTableCell.h"

@implementation NumberCell

+ (NumberCell *)newNumberCellWithTag:(NSInteger)tag withDelegate:(id)delegate
{
	
	NumberCell *cell = [[NumberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NumberCell"];
	[[cell cellTextField] setDelegate:delegate];
	[[cell cellTextField] setTag:tag];
	[[cell cellTextField] setKeyboardType:UIKeyboardTypeDecimalPad];

	return cell;
}

@end
