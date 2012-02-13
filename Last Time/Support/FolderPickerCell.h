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
- (EventFolder *)folderPickerRootFolder;
- (EventFolder *)folderPickerCurrentFolder;

@end

@interface FolderPickerCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) EventFolder *rootFolder;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, assign) UITableViewController <FolderPickerCellDelegate> *delegate;

+ (FolderPickerCell *)newFolderCellWithTag:(NSInteger)tag 
															withDelegate:(id) delegate;

- (void)setFolder;

@end
