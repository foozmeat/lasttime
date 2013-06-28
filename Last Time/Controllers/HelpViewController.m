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
