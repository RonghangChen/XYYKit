//
//  NSURL+MyCategory.m
//  
//
//  Created by LeslieChen on 15/4/3.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "NSURL+MyCategory.h"

@implementation NSURL (MyCategory)

- (NSDictionary *)queryInfos
{
    NSArray * params = [[self query] componentsSeparatedByString:@"&"];
    NSMutableDictionary * queryInfos = [NSMutableDictionary dictionaryWithCapacity:params.count];
    
    for (NSString * param in params) {
        NSArray * components = [param componentsSeparatedByString:@"="];
        if (components.count == 2) {
            [queryInfos setObject:[components[1] stringByRemovingPercentEncoding] forKey:[components[0] stringByRemovingPercentEncoding]];
        }
    }
    
    return queryInfos;
}

@end
