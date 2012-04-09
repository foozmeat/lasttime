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
@synthesize logEntryLocationCell;

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

-(void) layoutSubviews
{
	[super layoutSubviews];
//	float inset = 5.0;
	CGRect bounds = [[self contentView] bounds];
	
	const float cellWidth = bounds.size.width - 20.0;
	const float maxNoteWidth = cellWidth * 0.6;
	
	// Size note up to max if need be
	CGSize newNoteSize = [logEntryNoteCell sizeThatFits:logEntryNoteCell.frame.size];
	if (newNoteSize.width > maxNoteWidth) {
		// handle the overflow some way
		newNoteSize.width = maxNoteWidth;
	}
	// resize the label
	CGRect frame = logEntryNoteCell.frame;
	frame.size = newNoteSize;
	logEntryNoteCell.frame = frame;
	
		// Resize the date
	CGSize newDateSize = [logEntryDateCell sizeThatFits:logEntryDateCell.frame.size];
	CGSize dateSize = logEntryDateCell.frame.size;
	
	const float maxDateSize = cellWidth - newNoteSize.width - 10.0;
	if (newDateSize.width > maxDateSize) {
		newDateSize.width = maxDateSize;
	}

	float sizeDifference = dateSize.width - newDateSize.width;
	
		// resize the label
	CGRect dateFrame = logEntryDateCell.frame;
	dateFrame.size = newDateSize;
	dateFrame.origin.x = dateFrame.origin.x + sizeDifference;
	logEntryDateCell.frame = dateFrame;
	
}

-(NSString *)description
{
	return [[NSString alloc] initWithFormat:@"Note: %@, Value: %@, Date: %@, Location: %@", logEntryNoteCell.text, logEntryValueCell.text, logEntryDateCell.text, logEntryLocationCell.text];
}
@end
