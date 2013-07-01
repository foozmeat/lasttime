//
//  ReminderSwitchCell.h
//  Last Time
//
//  Created by James Moore on 2/17/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReminderSwitchCellDelegate <NSObject>

- (void)reminderSwitchChanged:(UISwitch *)sender;

@end

@interface ReminderSwitchCell : UITableViewCell

@property (nonatomic, strong) UISwitch *reminderSwitch;
@property (nonatomic, assign) UITableViewController <ReminderSwitchCellDelegate> *delegate;
@property (nonatomic) BOOL drawBorder;
@property (nonatomic, strong) UIView *lineView;

+ (ReminderSwitchCell *)newReminderCellWithTag:(NSInteger)tag withDelegate:(id) delegate;

@end
