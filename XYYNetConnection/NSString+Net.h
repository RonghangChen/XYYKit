//
//  NSString+Net.h
//  QingYang_iOS
//
//  Created by 陈荣航 on 2018/3/29.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Net)

//添加路径参数
- (NSString *)stringByAddPathArguments:(NSDictionary *)arguments;
- (NSString *)stringByAddPathArguments:(NSDictionary *)arguments defaultValue:(id)defaultValue;

//添加查询参数
- (NSString *)stringByAddQueryArguments:(NSDictionary *)arguments;

@end
