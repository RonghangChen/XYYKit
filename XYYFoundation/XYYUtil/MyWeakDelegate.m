//
//  MyWeakDelegate.m
//  
//
//  Created by LeslieChen on 15/11/7.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "MyWeakDelegate.h"
#import "XYYBaseDef.h"

@implementation MyWeakDelegate

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _delegateKey = [[self class] keyForDelegate:delegate];
    }
    
    return self;
}


- (id)initWithDelegateForSearch:(id)delegate
{
    self = [super init];
    if (self) {
        _delegateKey = [[self class] keyForDelegate:delegate];
    }
    
    return self;
}

+ (id<NSCopying>)keyForDelegate:(id)delegate {
    return NSNumberWithPointer(delegate);
}

- (BOOL)isEqual:(id)object
{
    BOOL bRet = NO;
    if ([object isKindOfClass:[self class]]) {
        bRet = [(id)self.delegateKey isEqual:(id)[object delegateKey]];
    }
    
    return bRet;
}

- (NSUInteger)hash {
    return [(id)self.delegateKey hash];
}

@end
