//
//  LTScreenshotManager.m
//  Last Time
//
//  Created by James Moore on 7/1/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#if CREATING_SCREENSHOTS

#import "LTScreenshotManager.h"
#import "KSScreenshotAction.h"
#import "FolderListViewController.h"
#import "EventListViewController.h"
#import "EventDetailController.h"

@implementation LTScreenshotManager

@synthesize initialViewController;


- (dispatch_time_t) popTime
{
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
}

- (void)setupScreenshotActions
{
// Timeline

    KSScreenshotAction *timelineAction = [KSScreenshotAction actionWithName:@"02_timeline" asynchronous:YES actionBlock:^{

        SASlideMenuViewController *ltsvc = [initialViewController leftMenu];

        [ltsvc selectContentAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] scrollPosition:0];

        dispatch_after([self popTime], dispatch_get_main_queue(), ^(void){
            [self actionIsReady];
        });
    } cleanupBlock:^{
        SASlideMenuViewController *ltsvc = [initialViewController leftMenu];
        [ltsvc selectContentAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] scrollPosition:0];

    }];

    [self addScreenshotAction:timelineAction];

    // Lists

    KSScreenshotAction *listsAction = [KSScreenshotAction actionWithName:@"01_lists" asynchronous:YES actionBlock:^{
        dispatch_after([self popTime], dispatch_get_main_queue(), ^(void){
            [self actionIsReady];
        });
    } cleanupBlock:^{
    }];

    [self addScreenshotAction:listsAction];

    
    // Event List
    KSScreenshotAction *eventListAction = [KSScreenshotAction actionWithName:@"03_event_list" asynchronous:YES actionBlock:^{

        UINavigationController *nc = (UINavigationController *) self.initialViewController.selectedContent;
        FolderListViewController *flvc = (FolderListViewController *) nc.topViewController;

        // Select Health
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        [flvc.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [flvc performSegueWithIdentifier:@"viewFolder" sender:self];
        [flvc.tableView deselectRowAtIndexPath:indexPath animated:NO];

        dispatch_after([self popTime], dispatch_get_main_queue(), ^(void){
            [self actionIsReady];
        });

    } cleanupBlock:^{
    }];

    [self addScreenshotAction:eventListAction];

    // Event Detail
    KSScreenshotAction *eventDetailAction = [KSScreenshotAction actionWithName:@"04_event_detail" asynchronous:YES actionBlock:^{

        UINavigationController *nc = (UINavigationController *) self.initialViewController.selectedContent;
        EventListViewController *elvc = (EventListViewController *) nc.topViewController;

        // Select Running
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [elvc.eventTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [elvc performSegueWithIdentifier:@"viewDetail" sender:self];
        [elvc.eventTableView deselectRowAtIndexPath:indexPath animated:NO];


        dispatch_after([self popTime], dispatch_get_main_queue(), ^(void){
            [self actionIsReady];
        });
    } cleanupBlock:^{
        UINavigationController *nc = (UINavigationController *) self.initialViewController.selectedContent;
        [nc popViewControllerAnimated:NO]; // Health
        [nc popViewControllerAnimated:NO]; // Lists

    }];
    [self addScreenshotAction:eventDetailAction];


    // Edit Event
    KSScreenshotAction *editEventAction = [KSScreenshotAction actionWithName:@"05_edit_event" asynchronous:YES actionBlock:^{
        UINavigationController *nc = (UINavigationController *) self.initialViewController.selectedContent;

        FolderListViewController *flvc = (FolderListViewController *) nc.topViewController;

        // Select Car
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [flvc.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [flvc performSegueWithIdentifier:@"viewFolder" sender:self];
        [flvc.tableView deselectRowAtIndexPath:indexPath animated:NO];


        EventListViewController *elvc = (EventListViewController *) nc.topViewController;
        [elvc setEditing:YES animated:NO];

        dispatch_after([self popTime], dispatch_get_main_queue(), ^(void){
            NSIndexPath *editIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [elvc.eventTableView selectRowAtIndexPath:editIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [elvc performSegueWithIdentifier:@"editEvent" sender:self];
        });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            EventDetailController *edc = (EventDetailController *) nc.topViewController;
            [edc endEditing];
        });


        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self actionIsReady];
        });
    } cleanupBlock:^{

    }];
    [self addScreenshotAction:editEventAction];



}

@end

#endif
