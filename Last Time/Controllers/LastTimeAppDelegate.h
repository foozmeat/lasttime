//
//  LastTimeAppDelegate.h
//  LastTime
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGSplitViewController;
@class SegmentsController;

@interface LastTimeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) MGSplitViewController *splitViewController;
@property (nonatomic, strong) SegmentsController * segmentsController;
@property (nonatomic, strong) UISegmentedControl * segmentedControl;

@end

