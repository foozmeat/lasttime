//
//  HelpViewController.m
//  Last Time
//
//  Created by James Moore on 6/28/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "HelpViewController.h"

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

    self.emailButton.titleLabel.font = [sm cellLabelFontWithSize:[UIFont buttonFontSize]];
    self.tweetButton.titleLabel.font = [sm cellLabelFontWithSize:[UIFont buttonFontSize]];
    self.forumButton.titleLabel.font = [sm cellLabelFontWithSize:[UIFont buttonFontSize]];
    self.versionString.font = [sm cellLabelFontWithSize:[UIFont buttonFontSize]];

    self.emailButton.titleLabel.textColor = [sm tintColor];

    self.emailButton.tintColor = [sm tintColor];

	NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

	self.versionString.text = [NSString stringWithFormat:@"Version %@ (%@)", version, build];
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
