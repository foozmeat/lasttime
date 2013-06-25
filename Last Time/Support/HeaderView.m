//
//  HeaderView.m
//  Last Time
//
//  Created by James Moore on 4/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HeaderView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat height = 28;

@implementation HeaderView
@synthesize headerLabel;

- (id)initWithWidth:(CGFloat)width label:(NSString *)label
{
	CGRect frame = CGRectMake(0, 0, width, height);
	self = [self initWithFrame:frame];
	self.headerLabel = label;
    LTStyleManager *sm = [LTStyleManager new];
    self.backgroundColor = [sm tableHeaderColor];
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    LTStyleManager *sm = [LTStyleManager new];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, height)];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0, rect.size.width,height)];
	label.text = self.headerLabel;
	label.textAlignment = UITextAlignmentLeft;
    label.backgroundColor = [sm tableHeaderColor];
    label.font = [sm cellLabelFontWithSize:17.0];

    [headerView addSubview:label];

	[self addSubview:headerView];

}

+ (CGFloat)height
{
	return height;
}

@end
