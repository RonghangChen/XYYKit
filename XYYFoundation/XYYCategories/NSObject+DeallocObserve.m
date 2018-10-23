//
//  NSObject+DeallocObserve.m
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/10/23.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "NSObject+DeallocObserve.h"
#import <objc/runtime.h>

static char DeallocObserveObjectKey;

@interface _XYY_DeallocObserveObject : NSObject

@property(nonatomic,copy) void(^deallocBlock)(void);

@end

@implementation _XYY_DeallocObserveObject

- (void)dealloc
{
    if (_deallocBlock) { //回调
        _deallocBlock();
    }
}

@end

@implementation NSObject (DeallocObserve)

- (_XYY_DeallocObserveObject *)_deallocObserveObject
{
    _XYY_DeallocObserveObject * deallocObserveObject = objc_getAssociatedObject(self, &DeallocObserveObjectKey);
    if (deallocObserveObject == nil) {
        deallocObserveObject = [_XYY_DeallocObserveObject new];
        objc_setAssociatedObject(self, &DeallocObserveObjectKey, deallocObserveObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return deallocObserveObject;
}

- (void)setDeallocBlock:(void (^)(void))deallocBlock {
    [self _deallocObserveObject].deallocBlock = deallocBlock;
}

- (void(^)(void))deallocBlock {
    return [self _deallocObserveObject].deallocBlock;
}



@end
