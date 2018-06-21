//
//  NSString+Extend.h
//  
//
//  Created by 陈荣航 on 16/4/20.
//  Copyright © 2016年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)

//返回所有出现string的范围
- (NSArray *)allRangeOfString:(NSString *)string;

//space长度添加一个间距
- (NSString *)stringByInsertMark:(NSString *)mark withSpace:(NSUInteger)space;
- (NSString *)stringByInsertMark:(NSString *)mark withSpace:(NSUInteger)space reverse:(BOOL)reverse;

//返回首字母（如果存在）大写字符串
- (NSString *)firstUppercaseString;
//返回首字母（如果存在）小写字符串
- (NSString *)firstLowercaseString;

//获取唯一ID
+ (NSString *)uniqueIDString;
//获取随机字符串
+ (NSString *)randomStringWithLength:(NSUInteger)length;

//app版本的浮点值
- (float)versionFloatVaule;

@end
