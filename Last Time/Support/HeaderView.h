//
//  HeaderView.h
//  Last Time
//
//  Created by James Moore on 4/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView

@property (nonatomic, strong) NSString *headerLabel;

- (id)initWithWidth:(CGFloat)width label:(NSString *)label;

+ (CGFloat)height;

@end
