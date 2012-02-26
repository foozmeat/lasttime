//
//  FolderPickerCell.h
//  Last Time
//
//  Created by James Moore on 2/9/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FolderPickerCellDelegate <NSObject>

- (void)folderPickerDidChange:(EventFolder *)folder;
- (void)endEditing;
- (EventFolder *)folderPickerCurrentFolder;

@end

@interface FolderPickerCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate, UIKeyInput>

@property (nonatomic, strong) UIToolbar *inputAccessoryView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, assign) UITableViewController <FolderPickerCellDelegate> *delegate;

+ (FolderPickerCell *)newFolderCellWithTag:(NSInteger)tag 
															withDelegate:(id) delegate;

- (void)setFolder;
- (void)done:(id)sender;

@end
