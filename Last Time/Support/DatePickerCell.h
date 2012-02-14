//
//  DatePickerCell.h
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerCellDelegate <NSObject>

- (void)pickerDidChange:(NSDate *)date;
- (void)endEditing;

@end

@interface DatePickerCell : UITableViewCell

@property (nonatomic, strong) UIToolbar *inputAccessoryView;
@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, assign) UITableViewController <DatePickerCellDelegate> *delegate;

+ (DatePickerCell *)newDateCellWithTag:(NSInteger)tag withDelegate:(id) delegate;

- (void)dateChanged:(id)sender;
- (void)done:(id)sender;

@end
