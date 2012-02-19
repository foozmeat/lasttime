//
//  NumberCell.h
//  Last Time
//
//  Created by James Moore on 2/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "EditableTableCell.h"

@interface NumberCell : EditableTableCell

+ (NumberCell *)newNumberCellWithTag:(NSInteger)tag withDelegate:(id)delegate;

@end
