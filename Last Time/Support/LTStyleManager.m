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

#pragma mark -

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
    return [UIColor brownColor];
}

- (UIColor *) navBarBackgroundColor
{
	return [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:248.0/255.0 alpha:1.0];
//	return [UIColor whiteColor];

}
- (UIColor *) tableHeaderColor
{
	return [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:248.0/255.0 alpha:1.0];
//    return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];

}
- (UIFont *) mediumFontWithSize:(float) size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}
- (UIFont *) lightFontWithSize:(float) size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}


@end
