//
//  UIColor+HexString.h
//  5idj_ios
//
//  Created by LeslieChen on 14-7-30.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *)colorWithHexStr:(NSString *)hexString;

+ (UIColor *)colorWithHexStr:(NSString *)hexString alpha:(CGFloat)alpha;

- (NSString *)hexString;

@end
