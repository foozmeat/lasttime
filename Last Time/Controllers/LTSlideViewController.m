//
//  LTSlideViewController.m
//  Last Time
//
//  Created by James Moore on 6/13/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LTSlideViewController.h"

#import "MenuCell.h"
#import "FolderListViewController.h"
#import "TimelineViewController.h"
#import "HelpViewController.h"

@interface LTSlideViewController () <SASlideMenuDataSource,SASlideMenuDelegate> 

@end

@implementation LTSlideViewController
#pragma mark -
#pragma mark Setup
- (void) viewWillAppear:(BOOL)animated
{

    MenuCell *cell = (MenuCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.itemDescription.text = NSLocalizedString(@"Lists", @"Lists");

    cell = (MenuCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.itemDescription.text = NSLocalizedString(@"Timeline", @"Timeline");

    cell = (MenuCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.itemDescription.text = NSLocalizedString(@"Help", @"Help");

    [super viewWillAppear:animated];
}
#pragma mark -
#pragma mark SASlideMenuDataSource
// The SASlideMenuDataSource is used to provide the initial segueid that represents the initial visibile view controller and to provide eventual additional configuration to the menu button

// This is the indexPath selected at start-up
-(NSIndexPath*) selectedIndexPath{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

-(NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {

        if (indexPath.row == 0) {
            return @"folders";
        } else if (indexPath.row == 1){
            return @"timeline";
        }

    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return @"help";
        }
    }

    return @"error";
}

-(Boolean) allowContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(Boolean) disablePanGestureForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        return YES;
    }
    return NO;
}

// This is used to configure the menu button. The beahviour of the button should not be modified
-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    LTStyleManager *sm = [LTStyleManager manager];
    
    [menuButton setImage:[sm menuButtonImage] forState:UIControlStateNormal];
}

-(void) configureSlideLayer:(CALayer *)layer{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.3;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

-(CGFloat) leftMenuVisibleWidth{
    return 280;
}
@end
