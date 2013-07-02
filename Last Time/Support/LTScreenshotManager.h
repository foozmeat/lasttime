//
//  LTScreenshotManager.h
//  Last Time
//
//  Created by James Moore on 7/1/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#if CREATING_SCREENSHOTS

#import <UIKit/UIKit.h>
#import "KSScreenshotManager.h"
#import "SASlideMenuRootViewController.h"

@interface LTScreenshotManager : KSScreenshotManager

@property (nonatomic, strong) SASlideMenuRootViewController *initialViewController;

@end

#endif
