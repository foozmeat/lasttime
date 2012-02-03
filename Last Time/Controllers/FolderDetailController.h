//
//  FolderDetailController.h
//  Last Time
//
//  Created by James Moore on 2/3/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventFolder;

@interface FolderDetailController : UIViewController <UITextFieldDelegate>
{
	
}

@property (strong, nonatomic) EventFolder *folder;
@property (strong, nonatomic) EventFolder *rootFolder;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
- (IBAction)backgroundTapped:(id)sender;
@end
