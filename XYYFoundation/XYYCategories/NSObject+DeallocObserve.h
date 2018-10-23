//
//  NSObject+DeallocObserve.h
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/10/23.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (DeallocObserve)

//销毁的回调block
@property(nonatomic,copy) void(^deallocBlock)(void);

@end
