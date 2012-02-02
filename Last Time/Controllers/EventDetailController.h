//
//  EventDetailController.h
//  Last Time
//
//  Created by James Moore on 2/2/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@class LogEntry;

@interface EventDetailController : UIViewController <UITextFieldDelegate>
{
	NSDateFormatter *df;
	IBOutlet UIDatePicker *datePicker;
}

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *noteField;

- (IBAction)backgroundTapped:(id)sender;
- (IBAction)dateButtonTapped:(id)sender;
- (IBAction)dateChanged:(id)sender;
@end

