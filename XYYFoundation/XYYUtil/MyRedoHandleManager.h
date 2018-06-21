//
//  MyRedoHandleManager.h
//  leslie
//
//  Created by 陈荣航 on 2017/11/22.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

//重做操作选项
typedef NS_OPTIONS(NSUInteger,MyRedoHandleOptions) {
    MyRedoHandleOptionNone        = 0,
    MyRedoHandleOptionNeedNet     = 1,      //需要网络
    MyRedoHandleOptionRedoTimes   = 1 << 1, //重做一定次数
    MyRedoHandleOptionRedoForever = 1 << 2,  //不停重做直到成功
    
    //默认配置
    MyRedoHandleOptionDefault = MyRedoHandleOptionNeedNet | MyRedoHandleOptionRedoTimes
};

//----------------------------------------------------------


@class MyRedoHandleManager;
@protocol MyRedoHandleManagerHandleSource <NSObject>

//需要开始操作
- (void)redoHandleManagerNeedStartHandle:(MyRedoHandleManager *)redoHandleManager;

@optional

//需要取消操作
- (void)redoHandleManagerNeedCancleHandle:(MyRedoHandleManager *)redoHandleManager;

//操作结束了
- (void)redoHandleManager:(MyRedoHandleManager *)redoHandleManager didEndHandleWithCompleted:(BOOL)completed;
//已经取消操作
- (void)redoHandleManagerDidCancleHandle:(MyRedoHandleManager *)redoHandleManager;

@end

//----------------------------------------------------------


@interface MyRedoHandleManager : NSObject


/**
 * 开始连续操作
 * @param handleSource handleSource是操作源
 * @param options options是操作选项，默认为MyRedoHandleOptionDefault
 * @param conRedoTimes conRedoTimes连续重做次数，默认为3
 * @param totalRedoTimes totalRedoTimes总重做次数，默认为15
 * @param intervalTime intervalTime连续重做时间间隔，默认为5s
 */
- (BOOL)startHandleWithSource:(id<MyRedoHandleManagerHandleSource>)handleSource
                      options:(MyRedoHandleOptions)options
                 conRedoTimes:(NSUInteger)conRedoTimes
               totalRedoTimes:(NSUInteger)totalRedoTimes
                 intervalTime:(NSTimeInterval)intervalTime;

- (BOOL)startHandleWithSource:(id<MyRedoHandleManagerHandleSource>)handleSource
                      options:(MyRedoHandleOptions)options;

//操作源
@property(nonatomic,weak,readonly) id<MyRedoHandleManagerHandleSource> handleSource;
//操作选项
@property(nonatomic,readonly) MyRedoHandleOptions options;
//连续重做次数
@property(nonatomic,readonly) NSUInteger conRedoTimes;
//总重做次数
@property(nonatomic,readonly) NSUInteger totalRedoTimes;
//连续重做时间间隔
@property(nonatomic,readonly) NSTimeInterval intervalTime;

//是否正在进行操作
@property(nonatomic,readonly) BOOL isHandling;

//取消操作
- (void)cancleHandle;

//操作完成
- (void)handleEnd:(BOOL)completed forceEnd:(BOOL)forceEnd;
- (void)handleEnd:(BOOL)completed;

@end
