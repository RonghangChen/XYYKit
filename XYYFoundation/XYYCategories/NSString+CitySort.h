//
//  NSString+CitySort.h
//  
//
//  Created by 陈荣航 on 16/6/30.
//  Copyright © 2016年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CitySort)

//用于排序的城市名称（解决多音字问题）
- (NSString *)cityNameForSort;

@end
