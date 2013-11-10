//
//  LTStyleManager.m
//  Last Time
//
//  Created by James Moore on 6/18/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "LTStyleManager.h"

static LTStyleManager *manager = nil;

@implementation LTStyleManager

+ (LTStyleManager *)manager
{
	if (!manager) {
		manager = [[super allocWithZone:NULL] init];
	}

	return manager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [self manager];
}

- (id)init
{
	if (manager) {
		return manager;
	}

	self = [super init];
	return self;
}

#pragma mark - Images
- (UIImageView *) disclosureArrowImageView
{
    return [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"disclosure arrow.png" ]];
}

- (UIImage *) backArrowImage
{
    return [[UIImage imageNamed:@"back arrow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 4)];
}

- (UIImage *) menuButtonImage
{
    return [UIImage imageNamed:@"menu button.png"];
}


#pragma mark - Colors

- (UIColor *) defaultColor
{
    return [UIColor blackColor];
}

- (UIColor *) alarmColor
{
    return [UIColor redColor];
}

- (UIColor *) tintColor
{
    return [UIColor colorWithRed:236.0/255.0 green:124.0/255.0 blue:0/255.0 alpha:1.0];
//    return [UIColor brownColor];
}

- (UIColor *) detailTextColor
{
    return [self tintColor];
//    return [UIColor brownColor];
//    return [UIColor colorWithWhite:40.0/100.0 alpha:1.0];
//	return [UIColor colorWithRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0];
}

- (UIColor *) disabledTextColor
{
	return [UIColor grayColor];
}

- (UIColor *) navBarBackgroundColor
{
    return [UIColor colorWithWhite:96.0/100.0 alpha:1.0];
//	return [UIColor whiteColor];

}
- (UIColor *) tableHeaderColor
{
   return [self navBarBackgroundColor];
//    return [UIColor colorWithWhite:90.0/100.0 alpha:1.0];
}

#pragma mark - Fonts

- (UIFont *) cellLabelFontWithSize:(float) size
{
    return [self mediumFontWithSize:size];
}

- (UIFont *) cellDetailFontWithSize:(float) size
{
    return [self lightFontWithSize:size];
}

- (UIFont *) mediumFontWithSize:(float) size
{
	return [UIFont fontWithName:@"Avenir-Medium" size:size];
}
- (UIFont *) lightFontWithSize:(float) size
{
	return [UIFont fontWithName:@"Avenir-Light" size:size];
}
@end
