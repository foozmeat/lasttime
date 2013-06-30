//
//  HelpViewController.h
//  Last Time
//
//  Created by James Moore on 6/28/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

@interface HelpViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIButton *forumButton;
@property (weak, nonatomic) IBOutlet UILabel *versionString;

@end
