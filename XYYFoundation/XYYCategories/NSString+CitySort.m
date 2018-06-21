//
//  NSString+CitySort.m
//  
//
//  Created by 陈荣航 on 16/6/30.
//  Copyright © 2016年 ED. All rights reserved.
//

#import "NSString+CitySort.h"

@implementation NSString (CitySort)

- (NSString *)cityNameForSort
{
    if ([self isEqualToString:@"长春"]) {
        return @"尝春";
    }else if ([self isEqualToString:@"长沙"]) {
        return @"尝沙";
    }else if ([self isEqualToString:@"厦门"]) {
        return @"下门";
    }else {
        return self;
    }
}

@end
