//
//  ED_FilterContentView.h

//
//  Created by LeslieChen on 15/3/2.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "XYYFoundation.h"

//----------------------------------------------------------

UIKIT_EXTERN NSString * const MyDeclineMenuContentViewSizeInvalidateNotification;

//----------------------------------------------------------

@class MyDeclineMenuContainerView;

//----------------------------------------------------------

@interface MyBasicDeclineMenuContentView : UIView

//返回显示高度
- (CGFloat)heightForViewWithContainerSize:(CGSize)containerSize;
//大小无效
- (void)sizeInvalidate;


//将要点击隐藏，默认返回YES，返回NO阻止
- (BOOL)shouldTapHiddenInContainerView:(MyDeclineMenuContainerView *)containerView;
//将要开始滑动隐藏，默认返回YES，返回NO阻止
- (BOOL)shouldBeginSwipeHiddenInContainerView:(MyDeclineMenuContainerView *)containerView;
//将要滑动隐藏，默认返回YES，返回NO阻止
- (BOOL)shouldSwipeHiddenInContainerView:(MyDeclineMenuContainerView *)containerView;


//视图的显示过程，子类重载进行自定义动作
- (void)viewWillShow:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)viewDidShow:(BOOL)animated;
- (void)viewWillHide:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)viewDidHide:(BOOL)animated;

//显示时是否需要动画默认为YES
@property(nonatomic) BOOL needAnimatedWhenShow;
//显示动画的方向
@property(nonatomic) MyMoveAnimatedDirection showAnimtedMoveDirection;
//开始显示动画
- (void)startShowAnimatedWithDelay:(NSTimeInterval)delay;


@end
