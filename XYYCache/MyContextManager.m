//
//  MyContextManager.m
//  
//
//  Created by LeslieChen on 15/7/3.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyContextManager.h"
#import <pthread.h>
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface MyContextManager ()

+ (id)shareManager;
@property(nonatomic,strong,readonly) NSMutableDictionary * contexts;

@end

//----------------------------------------------------------

@implementation MyContextManager
{
    pthread_mutex_t _lock;
}

@synthesize contexts = _contexts;

+ (id)shareManager
{
    static MyContextManager * shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[super allocWithZone:nil] init];
    });
    
    return shareManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

#pragma mark -

+ (void)setContext:(id)context forObject:(id)object {
    [[self shareManager] _setContext:context forkey:object ? NSNumberWithPointer(object) : nil];
}

+ (void)setContext:(id)context forkey:(NSString *)key {
    [[self shareManager] _setContext:context forkey:key];
}

+ (id)contextForObject:(id)object {
    return [[self shareManager] _contextForKey:object ? NSNumberWithPointer(object) : nil];
}

+ (id)contextForKey:(NSString *)key {
    return [[self shareManager] _contextForKey:key];
}

#pragma mark -

- (NSMutableDictionary *)contexts
{
    if (!_contexts) {
        _contexts = [NSMutableDictionary dictionary];
    }
    
    return _contexts;
}

- (void)_setContext:(id)context forkey:(id<NSCopying>)key
{
    if (key == nil) {
//        @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                       reason:@"设置上下文的对象或key不能为nil"
//                                     userInfo:nil];
        return;
    }
    
    //上锁
    pthread_mutex_lock(&_lock);
    
    if (context) {
        [self.contexts setObject:context forKey:key];
    }else {
        [self.contexts removeObjectForKey:key];
    }
    
    //解锁
    pthread_mutex_unlock(&_lock);
}

- (id)_contextForKey:(id)key
{
    if (key == nil) {
//        @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                       reason:@"获取上下文的对象或key不能为nil"
//                                     userInfo:nil];
        return nil;
    }
    
    //上锁
    pthread_mutex_lock(&_lock);
    
    id context = [self.contexts objectForKey:key];
    
    //解锁
    pthread_mutex_unlock(&_lock);
    
    return context;
}


@end
