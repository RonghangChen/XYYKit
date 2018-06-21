//
//  NSDate+MyCategory.m
//  5idj
//
//  Created by LeslieChen on 14-10-14.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "NSDate+MyCategory.h"
#import "XYYConst.h"

@implementation NSDate (MyCategory)

- (NSDate *)dateWithSameSec {
   return [self dateWithMoveSec:0];
}

- (NSDate *)dateWithMoveSec:(NSInteger)sec {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:floor([self timeIntervalSinceReferenceDate]) + sec];
}

- (NSDate *)dateWithSameMin {
    return [self dateWithMoveMin:0];
}

- (NSDate *)dateWithMoveMin:(NSInteger)min
{
    //计算本地时间戳
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate] + timezoneFix;
    
    //生成偏移后时间
    return [NSDate dateWithTimeIntervalSinceReferenceDate:(MinForTimeInterval(timeInterval) + min) * SecPerMin - timezoneFix];
}


- (NSDate *)dateWithSameHour {
    return [self dateWithMoveHour:0];
}

- (NSDate *)dateWithMoveHour:(NSInteger)hour
{
    //计算本地时间戳
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate] + timezoneFix;
    
    return [NSDate dateWithTimeIntervalSinceReferenceDate:(HourForTimeInterval(timeInterval) + hour) * SecPerHour - timezoneFix];
}

- (NSDate *)dateWithSameDay {
    return [self dateWithMoveDay:0];
}

- (NSDate *)dateWithMoveDay:(NSInteger)day
{
    //计算本地时间戳
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate] + timezoneFix;
    
    return [NSDate dateWithTimeIntervalSinceReferenceDate:(DayForTimeInterval(timeInterval) + day) * SecPerDay - timezoneFix];
}

- (BOOL)isSameMin:(NSDate *)date
{
    BOOL bRet = NO;
    
    if (date) {
        
        double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
        bRet = MinForTimeInterval([self timeIntervalSinceReferenceDate] + timezoneFix) ==
               MinForTimeInterval([date timeIntervalSinceReferenceDate] + timezoneFix);
    }
    
    return bRet;
}

- (BOOL)isSameHour:(NSDate *)date
{
    BOOL bRet = NO;
    
    if (date) {
        
        double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
        bRet = HourForTimeInterval([self timeIntervalSinceReferenceDate] + timezoneFix) ==
               HourForTimeInterval([date timeIntervalSinceReferenceDate] + timezoneFix);
    }
    
    return bRet;
}

- (BOOL)isSameDay:(NSDate *)date
{
    BOOL bRet = NO;
    
    if (date) {
        
        double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
        bRet = DayForTimeInterval([self timeIntervalSinceReferenceDate] + timezoneFix) ==
               DayForTimeInterval([date timeIntervalSinceReferenceDate] + timezoneFix);
    }
    
    return bRet;
}

- (BOOL)isToMin {
    return [self isSameMin:[NSDate date]];
}

- (BOOL)isToHour {
    return [self isSameHour:[NSDate date]];
}

- (BOOL)isToday {
    return [self isSameDay:[NSDate date]];
}

#pragma mark -

- (NSDateComponents *)dateComponentsWithCalendarUnit:(NSCalendarUnit)calendarUnit {
    return [self dateComponentsWithCalendar:nil andUnit:calendarUnit];
}

- (NSDateComponents *)dateComponentsWithCalendar:(NSCalendar *)calendar andUnit:(NSCalendarUnit)calendarUnit
{
    calendar = calendar ?: [NSCalendar currentCalendar];
    return [calendar components:calendarUnit fromDate:self];
}

+ (NSDate *)dateWithDateComponents:(NSDateComponents *)dateComponents {
    return [self dateWithDateComponents:dateComponents calendar:nil];
}

+ (NSDate *)dateWithDateComponents:(NSDateComponents *)dateComponents calendar:(NSCalendar *)calendar
{
    if (dateComponents) {
        calendar = calendar ?: [NSCalendar currentCalendar];
        [calendar dateFromComponents:dateComponents];
    }
    
    return nil;
}

#pragma mark -

- (NSInteger)era {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitEra fromDate:self] era];
}

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)second {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

- (NSInteger)weekday {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSString *)weekdayString
{
    switch (self.weekday) {
        case 1:
            return @"日";
        case 2:
            return @"一";
        case 3:
            return @"二";
        case 4:
            return @"三";
        case 5:
            return @"四";
        case 6:
            return @"五";
        case 7:
            return @"六";
        default:
            return nil;
    }
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    return [self dateWithYear:year month:month day:day hour:0 minute:0 second:0];
}
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.year = year;
    components.day = day;
    components.hour = hour;
    components.minute = minute;
    components.second = second;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSString *)dateStringWithFormat:(NSString *)dateFormat
{
    if (dateFormat.length == 0) {
        return nil;
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    
    return [formatter stringFromDate:self];
}


+ (NSDate *)dateWithString:(NSString *)dateString dateFormat:(NSString *)dateFormat
{
    if (dateString.length == 0 || dateFormat.length == 0) {
        return nil;
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    
    return [formatter dateFromString:dateString];
}

@end
