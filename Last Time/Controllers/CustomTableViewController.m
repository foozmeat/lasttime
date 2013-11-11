//
//  CustomTableViewController.m
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "CustomTableViewController.h"
#import "EditableTableCell.h"

@implementation CustomTableViewController
@synthesize requiredField;
@synthesize bestLocation;
@synthesize shouldStoreLocation = _shouldStoreLocation;
@synthesize nameCell, numberCell, locationCell;
@synthesize delegate;
@synthesize isModal;

#pragma mark - UIViewController Methods

- (void)viewFinishedLoading
{
}

- (void)viewDidLoad
{

	if (locationManager == nil) {
		locationManager = [[CLLocationManager alloc] init];
	}

	numberFormatter = [[NSNumberFormatter alloc] init];

	_shouldStoreLocation = YES;
	// Subclasses need to call [locationManager startUpdatingLocation] in
	// their on viewDidLoad methods

	[locationManager setDelegate:self];
	[locationManager setDistanceFilter:50];
	[locationManager setDesiredAccuracy:5];

	if ([self isModal]) {
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                       target:self
                                       action:@selector(save)];
		if ([self requiredField] != -1) {
			[saveButton setEnabled:NO];
		}
		[[self navigationItem] setRightBarButtonItem:saveButton];

		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                         target:self
                                         action:@selector(cancel)];

		[[self navigationItem] setLeftBarButtonItem:cancelButton];

	}

	[self viewFinishedLoading];
}

#pragma mark - CLLocation Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	[[self tableView] reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// The location "unknown" error simply means the manager is currently unable to get the location.
	// We can ignore this error for the scenario of getting a single location fix, because we already have a
	// timeout that will stop the location manager to save power.
	if ([error code] != kCLErrorLocationUnknown) {
		[self stopUpdatingLocation:@"Error"];
	}
}

- (void)stopUpdatingLocation:(NSString *)state {

	if (locationManager.delegate) {
        //		NSLog(@"%@", state);
		[locationManager stopUpdatingLocation];
        //		locationManager.delegate = nil;
	}
}

- (void)startUpdatingLocation:(NSString *)state {

	if (locationManager.delegate && [self shouldStoreLocation]) {
        //		NSLog(@"%@", state);
		[locationManager startUpdatingLocation];
        [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:15];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	// test the age of the location measurement to determine if the measurement is cached
	// in most cases you will not want to rely on cached measurements
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	if (locationAge > 20.0) return;
	// test that the horizontal accuracy does not indicate an invalid measurement
	if (newLocation.horizontalAccuracy < 0) return;
	// test the measurement to see if it is more accurate than the previous measurement
	if (bestLocation == nil || bestLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
		// store the location as the "best effort"
		self.bestLocation = newLocation;
		NSLog(@"%f, %f, %f", bestLocation.horizontalAccuracy, newLocation.horizontalAccuracy, locationManager.desiredAccuracy);
		[self updateObjectLocation];
		// test the measurement to see if it meets the desired accuracy
		//
		// IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
		// accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
		// acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
		//
		if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			// we have a measurement that meets our requirements, so we can stop updating the location
			//
			// IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
			//
			[self stopUpdatingLocation:@"Acquired Location"];
			// we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Timed Out"];
		}
	}
	// update the display with the new location data
    //	[self.tableView reloadData];
}

- (void)updateObjectLocation
{
	@throw [NSException exceptionWithName:@"Called Delegate method in super class" reason:@"Override in subclass" userInfo:nil];
}

#pragma mark - Action Methods

- (void)save
{
	[self.navigationController popViewControllerAnimated:YES];
	if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)]) {
		[delegate itemDetailViewControllerWillDismiss:self];
	}
}

- (void)cancel
{
	[self.navigationController popViewControllerAnimated:YES];
	if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)]) {
		[delegate itemDetailViewControllerWillDismiss:self];
	}
}

#pragma mark - UIViewController Methods

- (id) init
{
//	self = [super initWithStyle:UITableViewStyleGrouped];
	[self setRequiredField:-1];
	return self;
}

//  Override inherited method to automatically place the insertion point in the
//  first field.
//
- (void)viewDidAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSUInteger indexes[] = { 0, 0 };
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
                                                        length:2];

	[[self tableView] selectRowAtIndexPath:indexPath animated:YES scrollPosition:0];
}

//  Force textfields to resign firstResponder so that our implementation of
//  -textFieldDidEndEditing: will be called. That'll ensure that all current
//  UI values are flushed to our model object before the detail view disappears.
//
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[self view] endEditing:YES];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

}
#pragma mark -
#pragma mark UITextFieldDelegate Protocol

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

	if ([self isModal] && [textField tag] == [self requiredField]) {
		NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
		BOOL isFieldEmpty = [newText isEqualToString:@""];
		self.navigationItem.rightBarButtonItem.enabled = !isFieldEmpty;
	}

	if ([textField keyboardType] == UIKeyboardTypeDecimalPad) {
		NSCharacterSet *acceptedInput = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
		if ([[string componentsSeparatedByCharactersInSet:acceptedInput] count] > 1 || [string isEqualToString:@""]) {
			return YES;
		} else {
			return NO;
		}
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	if ([self isModal] && [textField tag] == [self requiredField]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	return YES;
}


//  UITextField sends this message to its delegate when the return key
//  is pressed. Use this as a hook to navigate back to the list view
//  (by 'popping' the current view controller, or dismissing a modal nav
//  controller, as the case may be).
//
//  If the user is adding a new item rather than editing an existing one,
//  respond to the return key by moving the insertion point to the next cell's
//  textField, unless we're already at the last cell.
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField returnKeyType] == UIReturnKeyNext)
	{
		//  The keyboard's return key is currently displaying 'Next' instead of
		//  'Done', so just move the insertion point to the next field. The
		//  keyboard will display 'Done' when we're at the last field.
		//
		//  (See the implementation of -textFieldShouldBeginEditing:, above.)
		//
		NSInteger nextTag = [textField tag] + 1;
		UIView *nextTextField = [[self tableView] viewWithTag:nextTag];

		[nextTextField becomeFirstResponder];
	}
	else if ([self isModal])
	{
		//  We're in a modal navigation controller, which means the user is
		//  adding a new book rather than editing an existing one.
		//
		[self save];
	}
	else
	{
		[[self navigationController] popViewControllerAnimated:YES];
	}

	return YES;
}

- (void)throwException {
	@throw [NSException exceptionWithName:@"Called Delegate method in super class" reason:@"Override in subclass" userInfo:nil];
}
#pragma mark - EditableTableCellDelegate
- (void)stringDidChange:(NSString *)value {
	[self throwException];
}

#pragma mark - LocationCell

- (BOOL) locationServicesEnabled
{
	return [CLLocationManager locationServicesEnabled] &&
	([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized ||
	 [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined);

}

- (BOOL) shouldStoreLocation
{
	return _shouldStoreLocation && [self locationServicesEnabled] && [[[self locationCell] locationSwitch] isOn];
}

- (void) locationSwitchChanged:(UISwitch *)sender
{
	_shouldStoreLocation = sender.on;

	if (sender.on == NO) {
		[self stopUpdatingLocation:@"Switched Off"];
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Timed Out"];
	} else {
		[self startUpdatingLocation:@"Switched on"];
        [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:15];
	}
	[self updateObjectLocation];

}

#pragma mark - DatePickerDelegate

- (void)pickerDidChange:(NSDate *)date
{
	[self throwException];
}

#pragma mark - FolderPickerDelegate
- (void)folderPickerDidChange:(EventFolder *)folder
{
	[self throwException];
}

- (EventFolder *)folderPickerCurrentFolder
{
	[self throwException];
	return nil;
}

- (void)endEditing
{
	[[self view] endEditing:YES];
}

@end
