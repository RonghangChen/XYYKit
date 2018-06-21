//
//  NSURL+MyCategory.h
//  
//
//  Created by LeslieChen on 15/4/3.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MyCategory)

//返回查询信息的字典 k1=v1&k2=v2
@property(nonatomic,strong,readonly) NSDictionary * queryInfos;

@end
