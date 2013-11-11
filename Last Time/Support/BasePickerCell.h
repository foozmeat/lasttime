//
//  BasePickerCell.h
//  Last Time
//
//  Created by James Moore on 6/24/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasePickerCell : UITableViewCell <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIToolbar *inputAccessoryView;
@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIPopoverController *pickerPopover;

- (void)valueChanged:(id)sender;
- (void)done:(id)sender;
- (void)initalizeBaseInputView;

@end
