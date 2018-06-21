//
//  MyNavigationTransitionDelegate.h
//  YHDemo
//
//  Created by LeslieChen on 14-9-28.
//  Copyright (c) 2014年 hldw. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyBasicViewControllerAnimatedTransitioning.h"

//----------------------------------------------------------

NS_CLASS_AVAILABLE_IOS(7_0)@interface MyNavigationTransitioningDelegate :
                                                            NSObject < UINavigationControllerDelegate,
                                                                       UIGestureRecognizerDelegate,
                                                                       MyBasicViewControllerAnimatedTransitioningDelegate >

//design init
- (id)initWithNavigationController:(UINavigationController *)navigationController;

//是否正在交互弹出
@property(nonatomic,readonly,getter = isInteractivePoping) BOOL interactivePoping;
//是否正在过渡动画
@property(nonatomic,readonly,getter = isTransitioning) BOOL transitioning;


@property(nonatomic,weak,readonly) UINavigationController * navigationController;

@end


//----------------------------------------------------------

NS_AVAILABLE_IOS(7_0) @protocol MyNavigationTransitioningProtocol

//返回动画,返回nil则为默认动画
- (MyBasicViewControllerAnimatedTransitioning *)navigationControllerAnimatedTransitioningForOperation:(UINavigationControllerOperation)operation interactive:(BOOL)interactive;

//是否允许交互pop
@property(nonatomic,getter = isNavigationInteractivePopEnabled) BOOL navigationInteractivePopEnable;
//是否正在交互pop
@property(nonatomic,readonly,getter = isNavigationInteractivePoping) BOOL navigationInteractivePoping;
//是否正在过渡
@property(nonatomic,readonly,getter = isNavigationTransitioning) BOOL navigationTransitioning;

//开始收到touch,返回NO取消
- (BOOL)interactivePopGestureShouldReceiveTouch:(UITouch *)touch;

//开始移动，返回NO取消
- (BOOL)interactivePopGestureShouldBeginWithTranslation:(CGPoint)translation;

//位移和开始点返回进度
- (float)navigationInteractivePopCompletePercentForTranslation:(CGPoint)translation withStartPoint:(CGPoint)startPoint;

//开始
- (void)startInteractivePop;
//完成
- (void)finishInteractivePop;
//取消
- (void)cancelInteractivePop;

//用于NavigationControllerTransitioning的子视图控制器，默认为nil
- (UIViewController *)childViewControllerForNavigationControllerTransitioning;

@end


//----------------------------------------------------------

@interface UIViewController (NavigationTransitioning) <MyNavigationTransitioningProtocol>

@property(nonatomic,readonly) MyNavigationTransitioningDelegate * navigationTransitioningDelegate NS_AVAILABLE_IOS(7_0);

@end


