//
//  MyViewControllerTransitioningDelegate.h
//  5idj
//
//  Created by LeslieChen on 14-10-22.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyBasicViewControllerAnimatedTransitioning.h"

//----------------------------------------------------------

NS_AVAILABLE_IOS(7_0)@interface MyViewControllerTransitioningDelegate : NSObject <
                                                                UIViewControllerTransitioningDelegate,
                                                                UIGestureRecognizerDelegate,
                                                                MyBasicViewControllerAnimatedTransitioningDelegate >

- (void)presentViewController:(UIViewController *)viewControllerToPresent;

//是否正在交互dimsmissing
@property(nonatomic,readonly,getter = isInteractiveDismissing) BOOL interactiveDismissing;
//是否正在过渡
@property(nonatomic,readonly,getter = isTransitioning) BOOL transitioning;


@property(nonatomic,weak,readonly) UIViewController * presentedViewController;

@end

//----------------------------------------------------------

NS_AVAILABLE_IOS(7_0) @protocol MyViewControllerTransitioningProtocol

//返回Present动画,返回nil则为默认动画
- (MyBasicViewControllerAnimatedTransitioning *)viewControllerAnimatedTransitioningForPresented;
//返回Dismiss动画,返回nil则为默认动画
- (MyBasicViewControllerAnimatedTransitioning *)viewControllerAnimatedTransitioningForDismissed;

//是否允许交互
@property(nonatomic,getter = isInteractiveDismissEnabled) BOOL interactiveDismissEnable;
//是否正在交互
@property(nonatomic,readonly,getter = isInteractiveDismissing) BOOL interactiveDismissing;
@property(nonatomic,readonly,getter = isPresentTransitioning) BOOL presentTransitioning;


//开始收到touch,返回NO取消
- (BOOL)interactiveDismissGestureShouldReceiveTouch:(UITouch *)touch;

//开始移动，返回NO取消
- (BOOL)interactiveDismissGestureShouldBeginWithTranslation:(CGPoint)translation;

//位移和开始点返回进度
- (float)interactiveDismissCompletePercentForTranslation:(CGPoint)translation
                                          withStartPoint:(CGPoint)startPoint;

//开始
- (void)startInteractiveDismiss;
//完成
- (void)finishInteractiveDismiss;
//取消
- (void)cancelInteractiveDismiss;

//用于NavigationControllerTransitioning的子视图控制器，默认为nil
- (UIViewController *)childViewControllerForViewControllerTransitioning;

@end

//----------------------------------------------------------

@interface UIViewController (MyViewControllerTransitioning)<MyViewControllerTransitioningProtocol>

//动画代理
@property(nonatomic,readonly) MyViewControllerTransitioningDelegate * viewControllerTransitioningDelegate NS_AVAILABLE_IOS(7_0);

@end
