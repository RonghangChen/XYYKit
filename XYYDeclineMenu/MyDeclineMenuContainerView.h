//
//  ED_FilterContainerView.h

//
//  Created by LeslieChen on 15/3/2.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "XYYFoundation.h"

//----------------------------------------------------------

@class MyDeclineMenuContainerView;
@class MyBasicDeclineMenuContentView;

//----------------------------------------------------------

@protocol MyDeclineMenuContainerViewDelegate <NSObject>

@optional

//将要点击隐藏
- (BOOL)declineMenuContainerViewShouldTapHidden:(MyDeclineMenuContainerView *)declineMenuContainerView;
//将要开始滑动隐藏
- (BOOL)declineMenuContainerViewShouldBeginSwipeHidden:(MyDeclineMenuContainerView *)declineMenuContainerView;
//将要滑动隐藏
- (BOOL)declineMenuContainerViewShouldSwipeHidden:(MyDeclineMenuContainerView *)declineMenuContainerView;

//已经滑动隐藏
- (void)declineMenuContainerViewDidTapHidden:(MyDeclineMenuContainerView *)declineMenuContainerView;
//已经点击隐藏
- (void)declineMenuContainerViewDidSwipeHidden:(MyDeclineMenuContainerView *)declineMenuContainerView;
//已经隐藏，点击和滑动都会调用该方法
- (void)declineMenuContainerViewDidHidden:(MyDeclineMenuContainerView *)declineMenuContainerView;

@end

//----------------------------------------------------------

@interface MyDeclineMenuContainerView : MyBlurredView

- (void)showWithView:(MyBasicDeclineMenuContentView *)declineMenuContentView
            animated:(BOOL)animated;
- (void)showWithView:(MyBasicDeclineMenuContentView *)declineMenuContentView
            animated:(BOOL)animated
      completedBlock:(void(^)())completedBlock;

- (void)hideWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated completedBlock:(void(^)())completedBlock;

@property(nonatomic,readonly,getter = isAnimating) BOOL animating;
@property(nonatomic,readonly,getter=isShowing) BOOL showing;
@property(nonatomic,strong,readonly) MyBasicDeclineMenuContentView * declineMenuContentView;

//显示下端的滑动视图
@property(nonatomic) BOOL showBottomSwipeView;
@property(nonatomic,strong) UIColor * bottomSwipeViewColor;

//代理
@property(nonatomic,weak) id<MyDeclineMenuContainerViewDelegate> delegate;

//动画时长
@property(nonatomic) NSTimeInterval animatedDuration;

@end

//----------------------------------------------------------

@interface UIView (MyDeclineMenuContainerView)

@property(nonatomic,strong,readonly) MyDeclineMenuContainerView * declineMenuContainerView;

@end



