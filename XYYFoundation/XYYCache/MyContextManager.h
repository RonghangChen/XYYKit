//
//  MyContextManager.h
//  
//
//  Created by LeslieChen on 15/7/3.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyContextManager : NSObject

//设置上下文,content为nil则移除
+ (void)setContext:(id)context forObject:(id)object;
+ (void)setContext:(id)context forkey:(NSString *)key;

//返回上下文
+ (id)contextForObject:(id)object;
+ (id)contextForKey:(NSString *)key;

@end
