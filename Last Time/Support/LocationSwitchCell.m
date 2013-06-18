//
//  LocationSwitchCell.m
//  Last Time
//
//  Created by James Moore on 2/17/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "LocationSwitchCell.h"

@implementation LocationSwitchCell
@synthesize locationSwitch, delegate;

- (void)initalizeInputView {
	// Initialization code
	self.selectionStyle = UITableViewCellSelectionStyleNone;

	self.locationSwitch = [[UISwitch alloc] init];
	[locationSwitch addTarget:delegate action:@selector(locationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	[locationSwitch setOn:NO];

    LTStyleManager *sm = [LTStyleManager manager];

    [locationSwitch setOnTintColor:[sm tintColor]];

	self.accessoryView = locationSwitch;
	
	self.textLabel.text = NSLocalizedString(@"Store Location?",@"Store Location?");
    self.textLabel.font = [sm lightFontWithSize:17.0];
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

+ (LocationSwitchCell *)newLocationCellWithTag:(NSInteger)tag withDelegate:(id) delegate
{
	LocationSwitchCell *cell = [[LocationSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"LocationSwitchCell"];
	[cell setDelegate:delegate];
	[cell setTag:tag];
	
	return cell;

}

@end
