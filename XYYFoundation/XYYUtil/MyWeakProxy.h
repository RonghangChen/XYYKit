//
//  MyWeakProxy.h
//  
//
//  Created by LeslieChen on 16/1/7.
//  Copyright © 2016年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyWeakProxy : NSProxy

+ (instancetype)weakProxyWithObject:(id)object;
- (id)initWithObject:(id)object;

@end
