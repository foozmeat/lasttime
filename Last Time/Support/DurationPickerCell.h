//
//  DurationPickerCell.h
//  Last Time
//
//  Created by James Moore on 6/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "BasePickerCell.h"

@protocol DurationPickerCellDelegate <NSObject>

- (void)durationPickerDidChangeWithDuration:(NSTimeInterval)duration;
- (void)endEditing;
- (void)popoverController:(UIPopoverController *)poc isShowing:(BOOL)isShowing;

@end

enum PickerComponants {
	kNumber = 0,
	kUnit,
	NUM_COMPONANTS
};

enum UnitRows {
	kDay = 0,
	kWeek,
	kMonth
};

@interface DurationPickerCell : BasePickerCell <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, assign) UITableViewController <DurationPickerCellDelegate> *delegate;
@property	(nonatomic) NSInteger duration;
@property (nonatomic, strong) NSDate *eventDate;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationDateLabel;
+ (DurationPickerCell *)newDurationCellWithTag:(NSInteger)tag withDelegate:(id) delegate;

- (void)setupPickerComponants;

@end
