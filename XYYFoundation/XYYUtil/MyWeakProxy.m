//
//  MyWeakProxy.m
//  
//
//  Created by LeslieChen on 16/1/7.
//  Copyright © 2016年 ED. All rights reserved.
//

#import "MyWeakProxy.h"

@implementation MyWeakProxy
{
    id __weak _object;
}

+ (instancetype)weakProxyWithObject:(id)object {
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    _object = object;
    return self;
}


#pragma mark Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector {
    return _object;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // Fallback for when target is nil. Don't do anything, just return 0/NULL/nil.
    // The method signature we've received to get here is just a dummy to keep `doesNotRecognizeSelector:` from firing.
    // We can't really handle struct return types here because we don't know the length.
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    // We only get here if `forwardingTargetForSelector:` returns nil.
    // In that case, our weak target has been reclaimed. Return a dummy method signature to keep `doesNotRecognizeSelector:` from firing.
    // We'll emulate the Obj-c messaging nil behavior by setting the return value to nil in `forwardInvocation:`, but we'll assume that the return value is `sizeof(void *)`.
    // Other libraries handle this situation by making use of a global method signature cache, but that seems heavier than necessary and has issues as well.
    // See https://www.mikeash.com/pyblog/friday-qa-2010-02-26-futures.html and https://github.com/steipete/PSTDelegateProxy/issues/1 for examples of using a method signature cache.
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}


@end
