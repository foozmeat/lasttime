//
//  HistoryLogDetailController.h
//  Last Time
//
//  Created by James Moore on 1/26/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LogEntry;

@interface HistoryLogDetailController : UIViewController <UITextFieldDelegate>
{
	NSDateFormatter *df;
	IBOutlet UITextField *noteField;
	IBOutlet UIButton *dateButton;
	IBOutlet UIDatePicker *datePicker;
}

@property (nonatomic, assign) LogEntry *logEntry;

- (IBAction)backgroundTapped:(id)sender;
- (IBAction)dateButtonPressed:(id)sender;
- (IBAction)dateChanged:(id)sender;
@end
