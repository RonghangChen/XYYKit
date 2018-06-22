//
//  MyBasicViewController.m
//
//
//  Created by LeslieChen on 14-4-2.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicViewController.h"
#import "MyNavigationTransitioningDelegate.h"
#import "MyViewControllerTransitioningDelegate.h"
#import "MyActivityIndicatorView.h"
#import "MBProgressHUD.h"
#import "XYYBaseDef.h"
#import "XYYMessageUtil.h"

//----------------------------------------------------------

@implementation MyBasicViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _viewShowing = YES;
    
    //更新视图
    if (_needUpdateViewWhenViewAppear) {
        _needUpdateViewWhenViewAppear = NO;
        [self updateView];
    }
    
    //更新数据
    if (_needRefreshDataWhenViewAppear) {
        _needRefreshDataWhenViewAppear = NO;
        [self tryRefreshData];
    }
    
    //观察键盘
    if (self.needObserveKeyboardFrameChange) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_keyboardWillChangeFrameNotification:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_keyboardDidChangeFrameNotification:)
                                                     name:UIKeyboardDidChangeFrameNotification
                                                   object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.needObserveKeyboardFrameChange) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillChangeFrameNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _viewShowing = NO;
}

- (void)_keyboardWillChangeFrameNotification:(NSNotification *)notification
{
    _keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardEndFrame = [self.view convertRect:_keyboardEndFrame fromView:self.view.window];
    
    if (_keyboardEndFrame.origin.y >= CGRectGetHeight(self.view.window.bounds)) {
        _keyboardEndFrame = CGRectZero;
    }
    
    _keyboardAnimationCurve = (UIViewAnimationCurve)[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    _keyboardAnimationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [self keyboardFrameWillChange];
}

- (void)_keyboardDidChangeFrameNotification:(NSNotification *)notification {
    [self keyboardFrameDidChange];
}


@end


#define _ACCESSOR(accessor, ctype, member) \
- (ctype)accessor{\
    return member;\
}

#define _MUTATOR(mutator, ctype, member) \
- (void)mutator (ctype)value{\
    member = value;\
}

#define _PROPERTY_IMP(accessor, mutator, ctype, member)\
_ACCESSOR(accessor, ctype, member)\
_MUTATOR(mutator, ctype, member)


@implementation MyBasicViewController (UpdateView)

- (void)setNeedUpdateView
{
    if (![self isViewShowing]) {
        _needUpdateViewWhenViewAppear = YES;
    }else{
        [self updateView];
    }
    
}

- (void)updateView {
    //do nothing
}

- (void)setNeedRefreshDataWhenViewAppear {
    _needRefreshDataWhenViewAppear = YES;
}

- (void)tryRefreshData {
    //do noting
}

@end



@implementation MyBasicViewController (Message)

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"知道了"
                                               otherButtonTitles:nil];
    
    [alertView show];
}


- (MBProgressHUD *)progressIndicatorView
{
    if (!_progressIndicatorView) {
        
        MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
        activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 30.f, 30.f);
        activityIndicatorView.tintColor = [UIColor whiteColor];
        [activityIndicatorView startAnimating];
        _progressIndicatorView = [[MBProgressHUD alloc] initWithView:self.view];
        _progressIndicatorView.mode = MBProgressHUDModeCustomView;
        _progressIndicatorView.customView = activityIndicatorView;
        _progressIndicatorView.removeFromSuperViewOnHide = YES;
    }
    
    return _progressIndicatorView;
}

- (void)showProgressIndicatorView:(NSString *)title {
    [self showProgressIndicatorViewWithAnimated:YES title:title];
}

- (void)showProgressIndicatorViewWithAnimated:(BOOL)animated title:(NSString *)title
{
    [self hideProgressIndicatorViewWithAnimated:NO completedBlock:nil];
    
    self.progressIndicatorView.labelText = title;
    self.progressIndicatorView.transform = CGAffineTransformIdentity;
    self.progressIndicatorView.animationType = MBProgressHUDAnimationFade;
    [self.view addSubview:self.progressIndicatorView];
    [self.progressIndicatorView show:animated];
}

- (void)hideProgressIndicatorView {
    [self hideProgressIndicatorViewWithAnimated:YES completedBlock:nil];
}

- (void)hideProgressIndicatorViewWithAnimated:(BOOL)animated completedBlock:(void(^)())completedBlock
{
    if (_progressIndicatorView.superview) {
        _progressIndicatorView.animationType = MBProgressHUDAnimationZoom;
        _progressIndicatorView.completionBlock = completedBlock;
        [_progressIndicatorView hide:animated];
    }
}

@end



@implementation MyBasicViewController (NetStatus)

- (NetworkStatus)currentNetworkStatus:(BOOL)showMSgWhenNoNetwork
{
    NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
    if (showMSgWhenNoNetwork && status == NotReachable) {
        showErrorMessage(nil, nil, @"网络似乎断开了连接");
    }
    
    return status;
}

_ACCESSOR(needObserveNetworkStatusChange, BOOL, _needObserveNetworkStatusChange);

- (void)setNeedObserveNetworkStatusChange:(BOOL)needObserveNetworkStatusChange
{
    if (_needObserveNetworkStatusChange != needObserveNetworkStatusChange) {
        
        if (_needObserveNetworkStatusChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NetReachabilityChangedNotification
                                                          object:nil];
        }
        
        _needObserveNetworkStatusChange = needObserveNetworkStatusChange;
        
        //添加通知
        if (_needObserveNetworkStatusChange) {
            
            //开始监听
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_networkStatusChangeNotification:)
                                                         name:NetReachabilityChangedNotification
                                                       object:nil];
        }
    }
}

- (void)_networkStatusChangeNotification:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [self networkStatusChangeHandle];
    }else{
        [self performSelectorOnMainThread:@selector(networkStatusChangeHandle)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)networkStatusChangeHandle {
    //do noting
}

@end



@implementation  MyBasicViewController (Keyboard)

_PROPERTY_IMP(needObserveKeyboardFrameChange, setNeedObserveKeyboardFrameChange:, BOOL, _needObserveKeyboardFrameChange)

_ACCESSOR(keyboardAnimationCurve, UIViewAnimationCurve, _keyboardAnimationCurve)
_ACCESSOR(keyboardEndFrame, CGRect, _keyboardEndFrame)
_ACCESSOR(keyboardAnimationDuration, NSTimeInterval, _keyboardAnimationDuration)


- (void)setAdjustFrameBasicKeyboardView:(UIView *)adjustFrameBasicKeyboardView
{
    if (_adjustFrameBasicKeyboardView != adjustFrameBasicKeyboardView) {
        
        if (_adjustFrameBasicKeyboardView) {
            _adjustFrameBasicKeyboardView.frame = [self adjustFrameViewInitFrame];
        }
        
        _adjustFrameBasicKeyboardView = adjustFrameBasicKeyboardView;
        
        if (_adjustFrameBasicKeyboardView) {
            [self adjustViewFrameBasicKeyboard];
        }
    }
}

_ACCESSOR(adjustFrameBasicKeyboardView, UIView *, _adjustFrameBasicKeyboardView)

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self adjustViewFrameBasicKeyboard];
}

- (CGRect)adjustFrameViewInitFrame {
    return self.adjustFrameBasicKeyboardView.superview.bounds;
}

- (void)adjustViewFrameBasicKeyboard
{
    UIView * adjustFrameBasicKeyboardView = self.adjustFrameBasicKeyboardView;
    
    if (adjustFrameBasicKeyboardView) {
        
        if (CGRectIsEmpty(self.keyboardEndFrame)) {
            adjustFrameBasicKeyboardView.frame = [self adjustFrameViewInitFrame];
        }else{
            
            CGFloat keyboardOriginY = [adjustFrameBasicKeyboardView.superview convertPoint:self.keyboardEndFrame.origin fromView:self.view].y;
            
            CGRect initFrame = [self adjustFrameViewInitFrame];
            if (CGRectGetMaxY(initFrame) > keyboardOriginY) {
                initFrame.size.height -= (CGRectGetMaxY(initFrame) - keyboardOriginY);
                initFrame.size.height = MAX(0.f, initFrame.size.height);
            }
            
            adjustFrameBasicKeyboardView.frame = initFrame;
        }
    }

}

- (void)keyboardFrameWillChange
{
    if (self.adjustFrameBasicKeyboardView) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:self.keyboardAnimationDuration];
        [UIView setAnimationCurve:self.keyboardAnimationCurve];
        
        [self adjustViewFrameBasicKeyboard];
        
        [UIView commitAnimations];
    }
}

- (void)keyboardFrameDidChange {
    
}

@end



