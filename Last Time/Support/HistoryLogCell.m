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
@synthesize logEntry;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

-(void) layoutSubviews
{
	[super layoutSubviews];
    LTStyleManager *sm = [LTStyleManager manager];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.001];

    CGFloat fontSize = 13.0;
    
    if ([self.logEntry showValue]) {
        NSString *value = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[self.logEntry logEntryValue] floatValue]]];
        self.logEntryValueCell.text = value;
        self.logEntryValueCell.textColor = [sm defaultColor];
        self.logEntryValueCell.font = [sm lightFontWithSize:fontSize];
    } else {
        self.logEntryValueCell.text = NSLocalizedString(@"No Value", @"No Value");
        self.logEntryValueCell.textColor = [UIColor lightGrayColor];
        self.logEntryValueCell.font = [sm lightFontWithSize:fontSize];
    }

    if ([self.logEntry showNote]) {
        self.logEntryNoteCell.text = self.logEntry.logEntryNote;
        self.logEntryNoteCell.textColor = [sm defaultColor];
        self.logEntryNoteCell.font = [sm lightFontWithSize:fontSize];
    } else {
        self.logEntryNoteCell.text = NSLocalizedString(@"No Note", @"No Note");
        self.logEntryNoteCell.textColor = [UIColor lightGrayColor];
        self.logEntryNoteCell.font = [sm lightFontWithSize:fontSize];
    }

    self.logEntryDateCell.text = [self.logEntry dateString];
    self.logEntryDateCell.textColor = [sm defaultColor];
    self.logEntryDateCell.font = [sm lightFontWithSize:fontSize];

    self.locationMarker.hidden = ![self.logEntry hasLocation];
    self.logEntryLocationCell.text = [self.logEntry locationString];
    self.logEntryLocationCell.font = [sm lightFontWithSize:fontSize];

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

- (NSString *)accessibilityLabel
{
	return [NSString stringWithFormat:@"%@, %@, %@, %@", logEntryNoteCell.text, logEntryValueCell.text, logEntryDateCell.text, logEntryLocationCell.text];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"Note: %@, Value: %@, Date: %@, Location: %@", logEntryNoteCell.text, logEntryValueCell.text, logEntryDateCell.text, logEntryLocationCell.text];
}
@end
