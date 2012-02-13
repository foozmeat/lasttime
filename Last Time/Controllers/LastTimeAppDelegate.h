//
//  LastTimeAppDelegate.h
//  LastTime
//
//  Created by James Moore on 1/10/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FolderViewController;

@interface LastTimeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) FolderViewController *rootFolderViewController;
@end

