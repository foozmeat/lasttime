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

@implementation LTScreenshotManager

@synthesize initialViewController;

- (void)setupScreenshotActions
{

    KSScreenshotAction *listsAction = [KSScreenshotAction actionWithName:@"01_lists" asynchronous:NO actionBlock:^{
    } cleanupBlock:^{
    }];

    [self addScreenshotAction:listsAction];

    KSScreenshotAction *timelineAction = [KSScreenshotAction actionWithName:@"02_timeline" asynchronous:YES actionBlock:^{

        SASlideMenuViewController *ltsvc = [initialViewController leftMenu];

        [ltsvc selectContentAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] scrollPosition:0];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self actionIsReady];
        });
    } cleanupBlock:nil];

    [self addScreenshotAction:timelineAction];

}

@end

#endif
