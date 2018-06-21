//
//  NSString+Net.m
//  QingYang_iOS
//
//  Created by 陈荣航 on 2018/3/29.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "NSString+Net.h"

@implementation NSString (Net)

- (NSString *)stringByAddPathArguments:(NSDictionary *)arguments {
    return [self stringByAddPathArguments:arguments defaultValue:nil];
}

- (NSString *)stringByAddPathArguments:(NSDictionary *)arguments defaultValue:(id)defaultValue
{
    if (self.length == 0) {
        return self;
    }
    
    NSRegularExpression * expression = [[NSRegularExpression alloc] initWithPattern:@"\\$\\{.*?\\}" options:0 error:NULL];
    
    NSMutableString * string = [NSMutableString string];
    
    NSUInteger location = 0;
    while (location < self.length) {
        
        //查找标签属性
        NSRange range = [expression rangeOfFirstMatchInString:self options:0 range:NSMakeRange(location, self.length - location)];
        
        if (range.location == NSNotFound) { //结束
            
            [string appendString:[self substringWithRange:NSMakeRange(location, self.length - location)]];
            break;
            
        }else {
            
            //拼接
            if (location < range.location) {
                [string appendString:[self substringWithRange:NSMakeRange(location, range.location - location)]];
            }
            
            //拼接value
            NSString * key = [self substringWithRange:NSMakeRange(range.location + 2, range.length - 3)];
            if (key.length) {
                id value = arguments[key];
                value = value ?: defaultValue;
                if (value != nil) {
                    [string appendString:[[value description] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
                }
            }
            
            location = range.location + range.length;
        }
    }
    
    return string;
}

- (NSString *)stringByAddQueryArguments:(NSDictionary *)arguments
{
    NSString * string = [NSString stringWithQueryArguments:arguments];
    if (string.length) {
        return [self stringByAppendingFormat:@"?%@",string];
    }
    
    return self;
}

+ (NSString *)stringWithQueryArguments:(NSDictionary *)arguments
{
    if (arguments.count == 0) {
        return nil;
    }
    
    //拼接参数
    NSMutableArray * queryArgumentStrArrary = [[NSMutableArray alloc] initWithCapacity:arguments.count];
    for (NSString * key in arguments.allKeys) {
        
        NSString * keyString = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString * valueString = [[arguments[key] description] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  
        [queryArgumentStrArrary addObject:[NSString stringWithFormat:@"%@=%@",keyString,valueString]];
    }
                                  
    return [queryArgumentStrArrary componentsJoinedByString:@"&"];
}

@end
