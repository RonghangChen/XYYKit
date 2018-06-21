//
//  NSString+Predicate.h
//  leslie
//
//  Created by 陈荣航 on 2017/1/12.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import <Foundation/Foundation.h>

//符号选项
typedef NS_OPTIONS(NSUInteger, MySignOption){
    MySignOptionZero     = 1 << 0, //零
    MySignOptionPositive = 1 << 1, //正数
    MySignOptionNegative = 1 << 2, //负数
    MySignOptionUnNegative = MySignOptionZero | MySignOptionPositive, //非负数
    MySignOptionUnPositive = MySignOptionZero | MySignOptionNegative, //非正数
    MySignOptionAll = ~0UL
};

@interface NSString (Predicate)

//是否匹配正则
- (BOOL)isMatchRegex:(NSString *)regex;

//是否是手机号
- (BOOL)isPhoneNumber;
//是否是邮箱地址
- (BOOL)isEmailAddress;
//是否是QQ号
- (BOOL)isQQNumber;

//是否是数字
- (BOOL)isNumber;

//是否是整数
- (BOOL)isInteger:(MySignOption)option;
//是否是浮点数字
- (BOOL)isDouble:(MySignOption)option;

//是否是金钱
- (BOOL)isMoney:(MySignOption)option;


@end
