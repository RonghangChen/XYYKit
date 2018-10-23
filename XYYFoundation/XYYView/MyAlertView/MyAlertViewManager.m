//
//  MyAlertViewManager.m
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/10/13.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "MyAlertViewManager.h"
#import "NSObject+DeallocObserve.h"

@interface _MyAlertViewContext : NSObject

@property(nonatomic,weak) id<MyAlertViewProtocol> alertView;
@property(nonatomic,copy) void(^showBlock)(void);

@end

@implementation _MyAlertViewContext

@end



@interface MyAlertViewManager ()

//上下文
@property(nonatomic,strong,readonly) NSMutableArray<_MyAlertViewContext *> * alertViewContexts;
//正在显示的上下文
@property(nonatomic,strong) _MyAlertViewContext * showingAlertViewContext;

@end


@implementation MyAlertViewManager

@synthesize alertViewContexts = _alertViewContexts;

+ (instancetype)sharedManager
{
    static MyAlertViewManager * sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

- (NSMutableArray<_MyAlertViewContext *> *)alertViewContexts
{
    if (!_alertViewContexts) {
        _alertViewContexts = [NSMutableArray array];
    }
    return _alertViewContexts;
}

- (id<MyAlertViewProtocol>)showingAlertView {
    return self.showingAlertViewContext.alertView;
}

- (void)showAlertView:(id<MyAlertViewProtocol>)alertView withBlock:(void (^)(void))showBlock
{
    if (!alertView || !showBlock) {
        return;
    }
    
    //生成上下文
    _MyAlertViewContext * context = [_MyAlertViewContext new];
    context.alertView = alertView;
    context.showBlock = showBlock;
    
    //设置销毁回调
    [(NSObject *)alertView setDeallocBlock:^{
        [self _removeDeallocAlertView];
    }];
    
    //暂停显示或者已有显示的视图,加入队列
    if (self.pauseShowAlertView || self.showingAlertViewContext) {
        [self.alertViewContexts addObject:context];
    }else { //显示视图
        [self _showAlertViewWithContext:context];
    }
}

- (void)hideAlertView:(id<MyAlertViewProtocol>)alertView withAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    if (alertView == nil) {
        return;
    }
    
    //查找上下文
    _MyAlertViewContext * context = nil;
    if (self.showingAlertViewContext.alertView == alertView) {
        context = self.showingAlertViewContext;
    }else {
        NSInteger index = 0;
        for (_MyAlertViewContext * tmpContext in self.alertViewContexts) {
            if (tmpContext.alertView == alertView) {
                context = tmpContext;
                break;
            }
            ++ index;
        }
        
        if (context) {
            [self.alertViewContexts removeObjectAtIndex:index];
        }
    }
    
    if (context) {
        [self _hideAlertViewWithContext:context animated:animated completedBlock:^{
            
            if (context == self.showingAlertViewContext) {
                self.showingAlertViewContext = nil;
                [self _showNextAlertView];
            }
            
            if (completedBlock) {
                completedBlock();
            }
        }];
    }
    
}

- (void)hideAllAlertViews
{
    if (self.showingAlertViewContext) {
        [self _hideAlertViewWithContext:self.showingAlertViewContext animated:NO completedBlock:nil];
        self.showingAlertViewContext = nil;
    }
    
    for (_MyAlertViewContext * context in self.alertViewContexts) {
        [self _hideAlertViewWithContext:context animated:NO completedBlock:nil];
    }
    [self.alertViewContexts removeAllObjects];
}

- (void)setPauseShowAlertView:(BOOL)pauseShowAlertView
{
    _pauseShowAlertView = pauseShowAlertView;
    [self _showNextAlertView];
}

- (BOOL)isShowAlertView:(id<MyAlertViewProtocol>)alertView
{
    if (alertView == nil) {
        return NO;
    }
    
    if (self.showingAlertViewContext.alertView == alertView) {
        return YES;
    }else {
        for (_MyAlertViewContext * tmpContext in self.alertViewContexts) {
            if (tmpContext.alertView == alertView) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark -

- (void)_showNextAlertView
{
    if (self.showingAlertViewContext || self.pauseShowAlertView) {
        return;
    }
    
    if (self.alertViewContexts.count) {
        
        //显示第一个视图
        _MyAlertViewContext * context = self.alertViewContexts.firstObject;
        [self.alertViewContexts removeObjectAtIndex:0];
        [self _showAlertViewWithContext:context];
    }
}

- (void)_showAlertViewWithContext:(_MyAlertViewContext *)context
{
    //显示
    self.showingAlertViewContext = context;
    context.showBlock();
    context.showBlock = nil;
}

- (void)_hideAlertViewWithContext:(_MyAlertViewContext *)context animated:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    [(NSObject *)context.alertView setDeallocBlock:nil];
    if (context == self.showingAlertViewContext) {
        [context.alertView hideAlertViewWithAnimated:animated completedBlock:completedBlock];
    }else {
        if (completedBlock) {
            completedBlock();
        }
    }
}

- (void)_removeDeallocAlertView
{
    if (self.showingAlertViewContext.alertView == nil) {
        self.showingAlertViewContext = nil;
    }
    
    if (self.alertViewContexts.count) {
        NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        for (_MyAlertViewContext * context in self.alertViewContexts) {
            if (context.alertView == nil) {
                [indexSet addIndex:index];
            }
            ++ index;
        }
        [self.alertViewContexts removeObjectsAtIndexes:indexSet];
    }
    
    //显示下一个alert视图
    [self _showNextAlertView];
}


@end
