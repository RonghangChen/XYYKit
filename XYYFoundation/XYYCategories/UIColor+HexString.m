//
//  UIColor+HexString.m
//  5idj_ios
//
//  Created by LeslieChen on 14-7-30.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "UIColor+HexString.h"
#import "XYYConst.h"

@implementation UIColor (HexString)

+ (UIColor *)colorWithHexStr:(NSString *)hexString {
    return [self colorWithHexStr:hexString alpha:1.f];
}

+ (UIColor *)colorWithHexStr:(NSString *)hexString alpha:(CGFloat)alpha
{
    if (hexString.length == 0) {
        return nil;
    }
    
    if ([hexString characterAtIndex:0] == '#') {
        hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"0x"];
    }else if (hexString.length == 6) {
        hexString = [@"0x" stringByAppendingString:hexString];
    }
    
    if (hexString.length == 8 && [hexString hasPrefix:@"0x"]){
        
        unsigned hexNumber = 0.f;
        NSScanner * hexValueScanner = [NSScanner scannerWithString:hexString];
        if ([hexValueScanner scanHexInt:&hexNumber]) {
            return [ColorWithNumberRGB(hexNumber) colorWithAlphaComponent:alpha];
        }
    }
    
    return nil;
}

- (NSString *)hexString
{
    CGFloat red,green,blue;
    
    if ([self getRed:&red green:&green blue:&blue alpha:nil]) {
        
        UInt8 _red   = red * UINT8_MAX;
        UInt8 _green = red * UINT8_MAX;
        UInt8 _blue  = red * UINT8_MAX;
        
        return [NSString stringWithFormat:@"0x%02X%02X%02X",_red,_green,_blue];
    }
    
    return nil;
}

@end
