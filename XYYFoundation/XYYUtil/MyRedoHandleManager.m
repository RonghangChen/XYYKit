//
//  MyRedoHandleManager.m
//  leslie
//
//  Created by 陈荣航 on 2017/11/22.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyRedoHandleManager.h"
#import "MyNetReachability.h"

//----------------------------------------------------------

@interface MyRedoHandleManager()

//网络观察对象
@property(nonatomic,strong) id netObserver;
//是否开始了操作
@property(nonatomic) BOOL didStartHandle;
//重做的次数
@property(nonatomic) NSUInteger redoTimes;

@end


//----------------------------------------------------------

@implementation MyRedoHandleManager

- (void)dealloc {
    [self cancleHandle];
}

- (BOOL)startHandleWithSource:(id<MyRedoHandleManagerHandleSource>)handleSource
                      options:(MyRedoHandleOptions)options
{
    return [self startHandleWithSource:handleSource
                               options:options
                          conRedoTimes:3
                        totalRedoTimes:15
                          intervalTime:5.0];
}

- (BOOL)startHandleWithSource:(id<MyRedoHandleManagerHandleSource>)handleSource
                      options:(MyRedoHandleOptions)options
                 conRedoTimes:(NSUInteger)conRedoTimes
               totalRedoTimes:(NSUInteger)totalRedoTimes
                 intervalTime:(NSTimeInterval)intervalTime
{
    if (self.isHandling) {
        return NO;
    }
    
    if (handleSource == nil || ![handleSource respondsToSelector:@selector(redoHandleManagerNeedStartHandle:)]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"handleSource必须实现redoHandleManagerNeedStartHandle" userInfo:nil];
    }
    
    _handleSource = handleSource;
    _options = options;
    _conRedoTimes = conRedoTimes;
    _totalRedoTimes = totalRedoTimes;
    _intervalTime = intervalTime;
    
    _isHandling = YES;
    self.redoTimes = 0;
    self.didStartHandle = NO;
    
    //开始操作
    [self _startHandle];
    
    return YES;
}

- (void)_startHandle
{
    //首先判断网络
    if (self.options & MyRedoHandleOptionNeedNet) {
        if (!NetworkAvailable()) { //网络不可用
            
            //观察网络改变通知
            self.netObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NetReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                [[NSNotificationCenter defaultCenter] removeObserver:self.netObserver];
                self.netObserver = nil;
                
                [self _startHandle];
            }];
            
            return;
        }
    }
    
    //开始操作
    self.didStartHandle = YES;
    [self.handleSource redoHandleManagerNeedStartHandle:self];
}

- (void)cancleHandle
{
    if (self.isHandling) {
        _isHandling = NO;
        
        //移除网络观察
        if (self.netObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.netObserver];
            self.netObserver = nil;
        }
        
        //移除时间回调
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_startHandle) object:nil];
        
         //发送通知
        
        id<MyRedoHandleManagerHandleSource> handleSource = self.handleSource;
        if (self.didStartHandle) {
            
            //需要取消操作
            if(handleSource && [handleSource respondsToSelector:@selector(redoHandleManagerNeedCancleHandle:)]) {
                [handleSource redoHandleManagerNeedCancleHandle:self];
            }
        }
        
        //已经取消操作
        if(handleSource && [handleSource respondsToSelector:@selector(redoHandleManagerDidCancleHandle:)]) {
            [handleSource redoHandleManagerDidCancleHandle:self];
        }
    }
}


- (void)handleEnd:(BOOL)completed {
    [self handleEnd:completed forceEnd:NO];
}

- (void)handleEnd:(BOOL)completed forceEnd:(BOOL)forceEnd
{
    if(!self.isHandling || !self.didStartHandle) {
        return;
    }
    self.didStartHandle = NO;
    
    if(completed) { //发送结束通知
       [self _didEndHandle:completed];
    }else {
        
        ++ self.redoTimes;
        
        if(!forceEnd &&
           (self.options & MyRedoHandleOptionRedoForever ||
           (self.options & MyRedoHandleOptionRedoTimes &&
            self.redoTimes <= self.totalRedoTimes))) { //可以重做
               
               if (self.intervalTime > 0.0 &&
                   self.conRedoTimes > 0 &&
                   self.redoTimes % self.conRedoTimes == 0) { //判断是否已经做完一组任务
                   
                   //等待一定时间重做
                   [self performSelector:@selector(_startHandle)
                              withObject:nil
                              afterDelay:self.intervalTime];
                   
               }else { //直接开始重做
                   [self _startHandle];
               }
            
        }else {
            [self _didEndHandle:NO];
        }
    }
}

- (void)_didEndHandle:(BOOL)completed
{
    _isHandling = NO;
    
    //发送通知
    id<MyRedoHandleManagerHandleSource> handleSource = self.handleSource;
    if(handleSource && [handleSource respondsToSelector:@selector(redoHandleManager:didEndHandleWithCompleted:)]) {
        [handleSource redoHandleManager:self didEndHandleWithCompleted:completed];
    }
}

@end
