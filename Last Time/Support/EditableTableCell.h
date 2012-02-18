//
//  EditableTableCell.h
//  Last Time
//
//  Created by James Moore on 2/6/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableTableCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) UITextField *cellTextField;

+ (EditableTableCell *)newDetailCellWithTag:(NSInteger)tag withDelegate:(id)delegate;

@end
