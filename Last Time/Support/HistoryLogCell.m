//
//  HistoryLogCell.m
//  Last Time
//
//  Created by James Moore on 2/19/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HistoryLogCell.h"

@implementation HistoryLogCell
@synthesize logEntryNoteCell;
@synthesize logEntryValueCell;
@synthesize logEntryDateCell;
@synthesize locationMarker;

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

@end
