//
//  TimelineViewController.h
//  Last Time
//
//  Created by James Moore on 4/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class EventController;

@interface TimelineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) EventController *detailViewController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UITableView *timelineTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *exportButton;

- (IBAction)exportTimeline:(id)sender;

@end
