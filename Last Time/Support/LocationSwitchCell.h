//
//  LocationSwitchCell.h
//  Last Time
//
//  Created by James Moore on 2/17/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationSwitchCellDelegate <NSObject>

- (void)locationSwitchChanged:(UISwitch *)sender;

@end

@interface LocationSwitchCell : UITableViewCell

@property (nonatomic, strong) UISwitch *locationSwitch;
@property (nonatomic, assign) UITableViewController <LocationSwitchCellDelegate> *delegate;

+ (LocationSwitchCell *)newLocationCellWithTag:(NSInteger)tag withDelegate:(id) delegate;

@end
