//
//  HeaderView.m
//  Last Time
//
//  Created by James Moore on 4/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "HeaderView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat height = 21;

@implementation HeaderView
@synthesize headerLabel;

- (id)initWithWidth:(CGFloat)width label:(NSString *)label
{
	CGRect frame = CGRectMake(0, 0, width, height);
	self = [self initWithFrame:frame];
	self.headerLabel = label;
	
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

- (CAGradientLayer *) brownGradient {
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.startPoint = CGPointMake(0.5, 0.0);
	gradient.endPoint = CGPointMake(0.5, 1.0);

	UIColor *color1 = [UIColor brownColor];
//	UIColor *color2 = [UIColor colorWithRed:203.0f/255.0f green:177.0f/255.0f blue:151.0f/255.0f alpha:1.0];
	UIColor *color2 = [UIColor whiteColor];

	[gradient setColors:[NSArray arrayWithObjects:(id)color1.CGColor, (id)color2.CGColor, nil]];
	return gradient;
}

- (void)drawRect:(CGRect)rect
{
		
	CAGradientLayer *gradient = [self brownGradient];
	gradient.frame = self.bounds;
	[self.layer addSublayer:gradient];
//	
//	CALayer *topLine = [CALayer layer];
//	topLine.frame = CGRectMake(0, 0, rect.size.width, 1);
//	topLine.backgroundColor = [UIColor grayColor].CGColor;
//	[self.layer addSublayer:topLine];
//	
	CALayer *border = [CALayer layer];
//	border.borderColor = [UIColor brownColor].CGColor;
	border.borderColor = [[UIColor colorWithRed:203.0f/255.0f green:177.0f/255.0f blue:151.0f/255.0f alpha:1.0] CGColor];

	border.borderWidth = 1;
	border.frame = CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height+2);
	
	[self.layer addSublayer:border];

    LTStyleManager *sm = [LTStyleManager manager];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, rect.size.width,height)];
	label.text = self.headerLabel;
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
    label.font = [sm lightFontWithSize:17.0];

	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor darkGrayColor];
	label.shadowOffset = CGSizeMake(0, 1);
	
	[self addSubview:label];
	
}

+ (CGFloat)height
{
	return height;
}

@end
