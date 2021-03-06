//
//  LTStyleManager.h
//  Last Time
//
//  Created by James Moore on 6/18/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTStyleManager : NSObject

+ (LTStyleManager *) manager;

- (UIColor *) tintColor;
- (UIColor *) defaultColor;
- (UIColor *) detailTextColor;
- (UIColor *) disabledTextColor;
- (UIColor *) alarmColor;
- (UIColor *) navBarBackgroundColor;
- (UIColor *) tableHeaderColor;
- (UIFont *) mediumFontWithSize:(float) size;
- (UIFont *) lightFontWithSize:(float) size;
- (UIFont *) cellLabelFontWithSize:(float) size;
- (UIFont *) cellDetailFontWithSize:(float) size;
- (UIImageView *) disclosureArrowImageView;
- (UIImage *) backArrowImage;
- (UIImage *) menuButtonImage;

@end
