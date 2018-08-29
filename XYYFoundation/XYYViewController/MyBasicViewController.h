//
//  MyBasicViewController.h
//
//
//  Created by LeslieChen on 14-4-2.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyNetReachability.h"
#import "XYYMessageUtil.h"

//----------------------------------------------------------

@interface MyBasicViewController : UIViewController
{
    
@private
    
    //UpdateView
    BOOL             _needUpdateViewWhenViewAppear;
    
    //refreshData
    BOOL             _needRefreshDataWhenViewAppear;
    
    //Messgae
    id<XYYProgressViewProtocol>  _progressIndicatorView;
    
    //NetStatus
    BOOL             _needObserveNetworkStatusChange;
    
    //观察键盘
    BOOL                 _needObserveKeyboardFrameChange;
    CGRect               _keyboardEndFrame;
    NSTimeInterval       _keyboardAnimationDuration;
    UIViewAnimationCurve _keyboardAnimationCurve;
    
    
    UIView         * _adjustFrameBasicKeyboardView;
}

//视图是否显示
@property(nonatomic,readonly,getter = isViewShowing) BOOL viewShowing;

//// 是否隐藏tabbar当视图出现的时候，默认为NO,
//// 当使用UITabBarController作为容器，且需要动态改变tabbar隐藏与否的一定需要将属性hidesBottomBarWhenPushed设置为NO
//// 并用该属性替代
//@property(nonatomic, getter = isHiddenTabBarWhenViewDidAppear) BOOL hiddenTabBarWhenViewDidAppear;
//
////是否记忆tabbar隐藏状态，默认为NO，即当手势改变tabbar隐藏状态时是否记忆状态到下次视图出现
////通过改变hiddenTabBarWhenViewDidAppear实现
//@property(nonatomic, getter = isMemoryTabBarHiddenStatus) BOOL memoryTabBarHiddenStatus;


@end


//======================================
/**
 * 视图更新
 */
//======================================
@interface MyBasicViewController (UpdateView)

//发起更新视图
- (void)setNeedUpdateView;

//具体更新什么内容
- (void)updateView;

//标识更新数据
- (void)setNeedRefreshDataWhenViewAppear;

//尝试更新数据
- (void)tryRefreshData;

@end

//======================================
/**
 * 消息通知
 */
//======================================
@interface MyBasicViewController (Message)

//显示警告视图
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

//活动指示器视图
@property(nonatomic,readonly,strong) id<XYYProgressViewProtocol> progressIndicatorView;

//活动指示器显示基于的视图
- (UIView *)showProgressIndicatorViewBaseView;

//显示进度指示视图
- (void)showProgressIndicatorView:(NSString *)title;
- (void)showProgressIndicatorViewWithAnimated:(BOOL)animated title:(NSString *)title;

//隐藏进度指示视图
- (void)hideProgressIndicatorView;
- (void)hideProgressIndicatorViewWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

@end


//======================================
/**
 * 网络状态
 */
//======================================

#define CurrentNetworkAvailable(showMSgWhenNoNetwork) \
    ([self currentNetworkStatus:showMSgWhenNoNetwork] != NotReachable)

@interface MyBasicViewController (NetStatus)

//是否监听网络改变,默认为NO
@property(nonatomic) BOOL needObserveNetworkStatusChange;

//获取当前网络状况
- (NetworkStatus)currentNetworkStatus:(BOOL)showMSgWhenNoNetwork;

//网络状况改变通知
- (void)networkStatusChangeHandle;

@end

//======================================
/**
 * 键盘相关
 */
//======================================

@interface MyBasicViewController (Keyboard)

//default no
@property(nonatomic) BOOL needObserveKeyboardFrameChange;

@property(nonatomic,readonly) CGRect keyboardEndFrame;
@property(nonatomic,readonly) NSTimeInterval keyboardAnimationDuration;
@property(nonatomic,readonly) UIViewAnimationCurve keyboardAnimationCurve;

- (void)keyboardFrameWillChange:(BOOL)frameChange;
- (void)keyboardFrameDidChange;

//需要基于键盘改变frame的视图，需要needObserveKeyboardFrameChange不为NO
@property(nonatomic,weak) UIView * adjustFrameBasicKeyboardView;

//初始frmae,即无键盘时的frame
- (CGRect)adjustFrameViewInitFrame;

//
- (void)adjustViewFrameBasicKeyboard;

@end




