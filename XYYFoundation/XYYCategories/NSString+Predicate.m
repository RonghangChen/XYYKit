//
//  NSString+Predicate.m
//  leslie
//
//  Created by 陈荣航 on 2017/1/12.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "NSString+Predicate.h"

@implementation NSString (Predicate)

- (BOOL)isMatchRegex:(NSString *)regex
{
    if (regex.length == 0) {
        return YES;
    }
    
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:self];
}

- (BOOL)isPhoneNumber
{
//    /**
//     * 手机号码
//     * 移动：134[0-8],135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,178,147
//     * 联通：130,131,132,155,156,185,186,176,145
//     * 电信：133,1349,153,180,181,189,177
//     * other:170
//     */
//    NSString * MOBILE = @"^1\\d{10}$";//@"^1(3[0-9]|5[0-35-9]|8[0-9]|7[0678]|4[57])\\d{8}$";
////    /**
////     * 中国移动：China Mobile
////     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,163,187,188
////     */
////    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0-27-9]|8[2-478]|77|47)\\d)\\d{7}$";
////    /**
////     * 中国联通：China Unicom
////     * 130,131,132,152,155,156,185,186
////     */
////    NSString * CU = @"^1(3[0-2]|5[56]|8[56]|76|45)\\d{8}$";
////    /**
////     * 中国电信：China Telecom
////     * 133,1349,153,180,189
////     */
////    NSString * CT = @"^1((33|53|8[019]|77)[0-9]|349)\\d{7}$";
////    /**
////     * 大陆地区固话及小灵通
////     * 区号：010,020,021,022,023,024,025,027,028,029
////     * 号码：七位或八位
////     */
////    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
//
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
////    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
////    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
////    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//
//    if ([regextestmobile evaluateWithObject:self]
////        || [regextestcm evaluateWithObject:self]
////        || [regextestct evaluateWithObject:self]
////        || [regextestcu evaluateWithObject:self]
//        ){
//        return YES;
//    }else{
//        return NO;
//    }
    
    return [self isMatchRegex:@"^1\\d{10}$"];
}

- (BOOL)isEmailAddress {
    return [self isMatchRegex:@"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"];
}

- (BOOL)isQQNumber {
    return [self isMatchRegex:@"^[1-9]\\d{4,10}$"];
}

- (BOOL)isNumber {
    return [self isMatchRegex:@"^\\d+$"];
}

- (BOOL)isInteger:(MySignOption)option
{
    if (option & MySignOptionZero) { //0
        if ([self isEqualToString:@"0"]) {
            return YES;
        }
    }
    
    if (option & MySignOptionNegative) {
        if (option & MySignOptionPositive) { //正和负
            return [self isMatchRegex:@"^-?[1-9]\\d*$"];
        }else { //负数
            return [self isMatchRegex:@"^-[1-9]\\d*$"];
        }
    }else if (option & MySignOptionPositive) { //正数
        return [self isMatchRegex:@"^[1-9]\\d*$"];
    }
    
    return NO;
}

- (BOOL)isDouble:(MySignOption)option
{
    if (option & MySignOptionZero) { //0
        if ([self isMatchRegex:@"^0(\\.0+)?$"]) {
            return YES;
        }
    }
    
    if (option & MySignOptionNegative) {
        if (option & MySignOptionPositive) { //正和负
            return [self isMatchRegex:@"^-?(([1-9]\\d*(\\.\\d+)?)|(0\\.\\d*[1-9]\\d*))$"];
        }else { //负数
            return [self isMatchRegex:@"^-(([1-9]\\d*(\\.\\d+)?)|(0\\.\\d*[1-9]\\d*))$"];
        }
    }else if (option & MySignOptionPositive) { //正数
        return [self isMatchRegex:@"^([1-9]\\d*(\\.\\d+)?)|(0\\.\\d*[1-9]\\d*)$"];
    }
    
    return NO;
}

- (BOOL)isMoney:(MySignOption)option
{
    if (option & MySignOptionZero) { //0
        if ([self isMatchRegex:@"^0(\\.0{1,2})?$"]) {
            return YES;
        }
    }
    
    if (option & MySignOptionNegative) {
        if (option & MySignOptionPositive) { //正和负
            return [self isMatchRegex:@"^-?(([1-9]\\d*(\\.\\d{1,2})?)|(0\\.(([1-9]\\d?)|(?[1-9]))))$"];
        }else { //负数
            return [self isMatchRegex:@"^-(([1-9]\\d*(\\.\\d{1,2})?)|(0\\.(([1-9]\\d?)|(\\d?[1-9]))))$"];
        }
    }else if (option & MySignOptionPositive) { //正数
        return [self isMatchRegex:@"^([1-9]\\d*(\\.\\d{1,2})?)|(0\\.(([1-9]\\d?)|(\\d?[1-9])))$"];
    }
    
    return NO;
}


@end
