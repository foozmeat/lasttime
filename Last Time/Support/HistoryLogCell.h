//
//  HistoryLogCell.h
//  Last Time
//
//  Created by James Moore on 2/19/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryLogCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *logEntryNoteCell;
@property (strong, nonatomic) IBOutlet UILabel *logEntryValueCell;
@property (strong, nonatomic) IBOutlet UILabel *logEntryDateCell;
@property (strong, nonatomic) IBOutlet UIImageView *locationMarker;
@property (strong, nonatomic) IBOutlet UILabel *logEntryLocationCell;
@end
