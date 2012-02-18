//
//  CustomTableViewController.h
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableTableCell.h"
#import "DatePickerCell.h"
#import "FolderPickerCell.h"
#import "LocationSwitchCell.h"

@interface CustomTableViewController : UITableViewController <UITextFieldDelegate, DatePickerCellDelegate, LocationSwitchCellDelegate, FolderPickerCellDelegate,CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;
	BOOL _shouldStoreLocation;
}

@property (strong, nonatomic) EventFolder *rootFolder;
@property (nonatomic) NSInteger requiredField;
@property (nonatomic) BOOL shouldStoreLocation;
@property (nonatomic, strong) CLLocation *bestLocation;

- (BOOL)isModal;

- (void)viewFinishedLoading;

- (void)stopUpdatingLocation:(NSString *)state;
- (void)startUpdatingLocation:(NSString *)state;
- (void)updateObjectLocation;

//  Action Methods
//
- (void)save;
- (void)cancel;

@end
