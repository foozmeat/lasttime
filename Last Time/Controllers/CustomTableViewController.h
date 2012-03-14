//
//  CustomTableViewController.h
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "EditableTableCell.h"
#import "DatePickerCell.h"
#import "FolderPickerCell.h"
#import "LocationSwitchCell.h"
#import "NumberCell.h"

@class CustomTableViewController;

@protocol ItemDetailViewControllerDelegate <NSObject>

@optional
-(void)itemDetailViewControllerWillDismiss:(CustomTableViewController *)ctvc;

@end

@interface CustomTableViewController : UITableViewController <UITextFieldDelegate, DatePickerCellDelegate, LocationSwitchCellDelegate, FolderPickerCellDelegate,CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;
	BOOL _shouldStoreLocation;
	NSNumberFormatter *numberFormatter;
}

@property (nonatomic, assign)id <ItemDetailViewControllerDelegate> delegate;

@property (nonatomic) NSInteger requiredField;
@property (nonatomic) BOOL shouldStoreLocation;
@property (nonatomic, strong) CLLocation *bestLocation;

@property (nonatomic, strong) EditableTableCell *nameCell;
@property (nonatomic, strong) NumberCell *numberCell;
@property (nonatomic, strong) LocationSwitchCell *locationCell;
@property (nonatomic, strong) UIPopoverController *popover;

- (BOOL)isModal;

- (void)viewFinishedLoading;

- (void)stopUpdatingLocation:(NSString *)state;
- (void)startUpdatingLocation:(NSString *)state;
- (void)updateObjectLocation;
- (BOOL)locationServicesEnabled;

//  Action Methods
//
- (void)save;
- (void)cancel;

@end
