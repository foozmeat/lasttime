//
//  FolderListCell.m
//  Last Time
//
//  Created by James Moore on 2/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FolderListCell.h"

@implementation FolderListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing) {
		[[self detailTextLabel] setHidden:YES];
	} else {
		[[self detailTextLabel] setHidden:NO];
	}
}
@end
