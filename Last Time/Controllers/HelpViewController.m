//
//  HelpViewController.m
//  Last Time
//
//  Created by James Moore on 6/28/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "HelpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	LTStyleManager *sm = [LTStyleManager manager];

	NSArray *buttons = @[self.emailButton, self.tweetButton, self.forumButton];

	for (UIButton *b in buttons) {
		b.titleLabel.font = [sm cellDetailFontWithSize:[UIFont buttonFontSize]];
		[b setTitleColor:[sm tintColor] forState:UIControlStateNormal];
		[b setTitleColor:[sm defaultColor] forState:UIControlStateHighlighted];

		[b setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];

		b.layer.cornerRadius = 8.0;
		b.layer.masksToBounds = YES;
		b.layer.borderColor = [sm tintColor].CGColor;
		b.layer.borderWidth = 1;

		b.tintColor = [sm tintColor];

	}

	self.versionString.font = [sm cellLabelFontWithSize:[UIFont buttonFontSize]];
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	self.versionString.text = [NSString stringWithFormat:@"Version %@", version];
}

- (IBAction)openMail:(id)sender
{
  if ([MFMailComposeViewController canSendMail])  {
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;

    NSArray *toRecipients = [NSArray arrayWithObjects:@"lasttimeapp@jmoore.me", nil];
    [mailer setToRecipients:toRecipients];

    [self presentModalViewController:mailer animated:YES];
  }
  else
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
																										message:@"You need to add a mail account in Settings"
																									 delegate:nil
																					cancelButtonTitle:@"OK"
																					otherButtonTitles: nil];
    [alert show];
  }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  switch (result)
  {
    case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
			break;
    case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the drafts folder.");
			break;
    case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
			break;
    case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
			break;
    default:
			NSLog(@"Mail not sent.");
			break;
  }
		// Remove the mail view
  [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)tweetButtonPressed:(id)sender {
		//Create the tweet sheet
	TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];

	[tweetSheet setInitialText:@"@LastTimeApp "];

		//Set a blocking handler for the tweet sheet
	tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
		[self dismissModalViewControllerAnimated:YES];
	};

		//Show the tweet sheet!
	[self presentModalViewController:tweetSheet animated:YES];
}

- (IBAction) openForum:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://moot.it/jmoore/#!/lasttime"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEmailButton:nil];
    [self setTweetButton:nil];
    [self setForumButton:nil];
    [self setVersionString:nil];
    [super viewDidUnload];
}
@end
