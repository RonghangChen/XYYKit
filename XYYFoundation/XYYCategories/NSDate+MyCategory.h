//
//  NSDate+MyCategory.h
//  5idj
//
//  Created by LeslieChen on 14-10-14.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MyCategory)

//获取同秒钟的最小时间
- (NSDate *)dateWithSameSec;
//获取移动了几秒钟的最小时间
- (NSDate *)dateWithMoveSec:(NSInteger)sec;


//获取同分钟的最小时间(即忽略秒）
- (NSDate *)dateWithSameMin;
//获取移动了几分钟的最小时间
- (NSDate *)dateWithMoveMin:(NSInteger)min;

//获取同小时的最小时间(即忽略分秒）
- (NSDate *)dateWithSameHour;
//获取移动了几小时的最小时间
- (NSDate *)dateWithMoveHour:(NSInteger)hour;

//获取同天的最小时间(即忽略时时分秒）
- (NSDate *)dateWithSameDay;
//移动多少天
- (NSDate *)dateWithMoveDay:(NSInteger)day;

- (BOOL)isSameMin:(NSDate *)date;
- (BOOL)isSameHour:(NSDate *)date;
- (BOOL)isSameDay:(NSDate *)date;

//是否是当前分钟
- (BOOL)isToMin;

//是否是当前小时
- (BOOL)isToHour;

//判断是否是今天
- (BOOL)isToday;

//获取当前时间分割信息
- (NSDateComponents *)dateComponentsWithCalendarUnit:(NSCalendarUnit)calendarUnit;
- (NSDateComponents *)dateComponentsWithCalendar:(NSCalendar *)calendar andUnit:(NSCalendarUnit)calendarUnit;

//通过分割消息创建时间
+ (NSDate *)dateWithDateComponents:(NSDateComponents *)dateComponents;
+ (NSDate *)dateWithDateComponents:(NSDateComponents *)dateComponents calendar:(NSCalendar *)calendar;

//获取时间分量
@property(nonatomic,readonly) NSInteger era;
@property(nonatomic,readonly) NSInteger year;
@property(nonatomic,readonly) NSInteger month;
@property(nonatomic,readonly) NSInteger day;
@property(nonatomic,readonly) NSInteger hour;
@property(nonatomic,readonly) NSInteger minute;
@property(nonatomic,readonly) NSInteger second;

//星期数
@property(nonatomic,readonly) NSInteger weekday;
//星期的汉字（一到日）
@property(nonatomic,strong,readonly) NSString * weekdayString;

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;


//格式化
- (NSString *)dateStringWithFormat:(NSString *)dateFormat;
+ (NSDate *)dateWithString:(NSString *)dateString dateFormat:(NSString *)dateFormat;

@end
