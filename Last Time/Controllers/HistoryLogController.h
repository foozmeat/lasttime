//
//  HistoryLogController.h
//  Last Time
//
//  Created by James Moore on 1/25/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryLogController : UITableViewController
{
}

@property (nonatomic, strong) Event *event;

- (IBAction)addNewItem:(id)sender;

@end
