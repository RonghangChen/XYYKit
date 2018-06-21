//
//  MyPopoverView.h
//
//
//  Created by LeslieChen on 14/12/1.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyBlurredView.h"
#import "NSObject+IntervalAnimation.h"

//----------------------------------------------------------
@class MyPopoverView;
//----------------------------------------------------------

@protocol MyPopoverViewDelegate <NSObject>

@optional

//将要点击隐藏，返回YES确定,NO取消
- (BOOL)popoverViewWillTapHidden:(MyPopoverView *)popoverView;
- (void)popoverViewDidTapHidden:(MyPopoverView *)popoverView;

@end

//----------------------------------------------------------


//弹出视图，该视图显示后会在内部建立循环保留，无需对其引用

@interface MyPopoverView : MyBlurredView

//design init
- (id)initWithContentView:(UIView *)contentView;

//内容视图
@property(nonatomic,strong) UIView * contentView;

//内容视图的锚点，默认是（0.5f，0.5f）中心
@property(nonatomic) CGPoint contentViewAnchorPoint;
//定位的锚点，默认是（0.5f，0.5f）中心
@property(nonatomic) CGPoint locationAnchorPoint;

//以下两个属性决定内容视图的大小,优先级为contentViewSize > contentViewSizeScale
//如果两者都为CGSizeZero,会调用视图的sizeThatFits方法获取大小

//内容视图的大小,默认为CGSizeZero
@property(nonatomic) CGSize contentViewSize;
//内容视图大小的所占比例MyPopoverView视图大小的比例,默认为CGSizeZero
@property(nonatomic) CGSize contentViewSizeScale;

//是否调节内容视图的frame当不包含时（即不能全部显示），默认为NO
@property(nonatomic) BOOL adjustContentViewFrameWhenNoContain;

//是否在显示
@property(nonatomic,readonly,getter = isShowing) BOOL showing;

- (void)show:(BOOL)animated;
- (void)showInView:(UIView *)view animated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;
- (void)hide:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

//是否允许点击内容视图的外围区域隐藏，默认为YES
@property(nonatomic, getter = isTapHiddenEnabled) BOOL tapHiddenEnable;

@property(nonatomic,weak) id<MyPopoverViewDelegate> delegate;


@end

//----------------------------------------------------------


@interface UIView (MyPopoverView)

@property(nonatomic,strong,readonly) MyPopoverView * popoverView;
//大小失效
- (void)popoverContentViewSizeInvaild;

//返回显示popoverView的窗口等级
- (UIWindowLevel)showPopoverWindowLevel;

//是否需要观察键盘改变位置，避免遮掩，默认为NO
- (BOOL)needObserverKeyboardChangePosition;
//返回改变位置时的偏移
- (CGPoint)contentFrameOffsetForKeyboardChange;

//是否需要观察键盘改变，默认为NO
- (BOOL)needObserverKeyboardChange;
//需要needObserverKeyboardChange返回YES且needObserverKeyboardChangePosition返回NO
//键盘将要改变到keyboardFrame
- (void)keyboardWillChangeToFrame:(CGRect)keyboardFrame;
//键盘将要改变到keyboardFrame时的动画
- (void)animationWhenKeyboardChangeToFrame:(CGRect)keyboardFrame;
//键盘改变到keyboardFrame
- (void)keyboardDidChangeToFrame:(CGRect)keyboardFrame;


//内容区域，内容区域外可点击隐藏
- (CGRect)popoverContentBounds;
//点击隐藏相关
- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point;
- (BOOL)popoverViewTapHiddenNeedAnimated;
- (void)popoverViewDidTapHidden;

//自定义动画，没有实现返回NO使用自定义动画
- (BOOL)customAnimationForPopoverView:(MyPopoverView *)popoverView
                                 show:(BOOL)show
                       animationBlock:(void(^)(void))animationBlock
                       completedBlock:(void(^)(void))completedBlock;

//默认的push自定义动画
- (void)defaultPushCustomAnimationForPopoverView:(MyPopoverView *)popoverView
                                       direction:(MyMoveAnimatedDirection)direction
                                            show:(BOOL)show
                                  animationBlock:(void(^)(void))animationBlock
                                  completedBlock:(void(^)(void))completedBlock;

//开始显示时调用
- (void)startPopoverViewShow:(BOOL)show animated:(BOOL)animated;
//结束显示时调用
- (void)endPopoverViewShow:(BOOL)show animated:(BOOL)animated;

@end


