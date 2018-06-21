//
//  MyPopoverView.m
//
//
//  Created by LeslieChen on 14/12/1.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import "MyPopoverView.h"
#import "UIView+Screenshot.h"
#import "UIImage+ImageEffects.h"
#import "UIView+IntervalAnimation.h"
#import "XYYConst.h"

//----------------------------------------------------------

@interface _MyPopoverViewController : UIViewController

@end

//----------------------------------------------------------

@implementation _MyPopoverViewController

- (BOOL)prefersStatusBarHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIApplication sharedApplication].statusBarStyle;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end

//----------------------------------------------------------

@interface MyPopoverView ()

@property(nonatomic,strong) UIWindow * s_window;
@property(nonatomic) CGRect keyboardFrame;


@property(nonatomic,readonly) BOOL isAnimating;
@property(nonatomic,strong,readonly) NSMutableArray * actionsArray;

@end

//----------------------------------------------------------

@implementation MyPopoverView

@synthesize actionsArray = _actionsArray;

#pragma mark - life circle

- (id)initWithFrame:(CGRect)frame {
    return [self initWithContentView:nil];
}

- (id)initWithContentView:(UIView *)contentView
{
    self = [super initWithFrame:CGRectZero];
    if(self) {
        super.hidden            = YES;
        self.backgroundColor    = BlackColorWithAlpha(0.5f);
        _tapHiddenEnable        = YES;
        _contentViewAnchorPoint = CGPointMake(0.5f, 0.5f);
        _locationAnchorPoint    = CGPointMake(0.5f, 0.5f);
        self.contentView        = contentView;
        
        [self _registerKVO];
    }
    
    return self;
}

- (void)dealloc
{
    [self _unregisterKVO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setHidden:(BOOL)hidden {
    // do nothing
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[@"contentViewAnchorPoint",
             @"locationAnchorPoint",
             @"contentViewSize",
             @"contentViewSizeScale",
             @"adjustContentViewFrameWhenNoContain"];
}

- (void)_registerKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)_unregisterKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self == object && ![change[@"old"] isEqual:change[@"new"]]) {
     
        //update UI
        if ([NSThread isMainThread]) {
            [self _updateUIForKeypath:keyPath];
        }else{
            [self performSelectorOnMainThread:@selector(_updateUIForKeypath:)
                                   withObject:keyPath
                                waitUntilDone:NO];
        }
    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath {
    [self setNeedsLayout];
}

#pragma mark - contentView

- (void)setContentView:(UIView *)contentView
{
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    if (_contentView) {
        [self addSubview:_contentView];
        [self setNeedsLayout];
    }
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showing) {
        [self _updateContentViewFrame];
    }
}

- (void)_updateContentViewFrame
{
    if (self.contentView) {
        
        CGFloat boundsWidth = CGRectGetWidth(self.bounds);
        CGFloat boundsHeight = CGRectGetHeight(self.bounds);
        CGSize contentViewSize = self.contentViewSize;
        
        if (CGSizeEqualToSize(contentViewSize, CGSizeZero)) {
            if (!CGSizeEqualToSize(self.contentViewSizeScale, CGSizeZero)) {
                contentViewSize.width  = boundsWidth  * self.contentViewSizeScale.width;
                contentViewSize.height = boundsHeight * self.contentViewSizeScale.height;
            }else{
                contentViewSize = [self.contentView sizeThatFits:self.bounds.size];
            }
        }
        
        
        CGRect contentViewFrame = CGRectMake(boundsWidth  * self.locationAnchorPoint.x -
                                             contentViewSize.width   * self.contentViewAnchorPoint.x,
                                             boundsHeight * self.locationAnchorPoint.y -
                                             contentViewSize.height  * self.contentViewAnchorPoint.y,
                                             contentViewSize.width, contentViewSize.height);
        
        //不能完全显示调节
        if (self.adjustContentViewFrameWhenNoContain && !CGRectContainsRect(self.bounds, contentViewFrame)) {
            
            //水平不能完全显示
            if (CGRectGetMinX(contentViewFrame) < 0 ||
                CGRectGetMaxX(contentViewFrame) > boundsWidth) {
                
                if (CGRectGetMaxX(contentViewFrame) > boundsWidth) {
                    contentViewFrame.origin.x = boundsWidth - CGRectGetWidth(contentViewFrame);
                }
                
                if (CGRectGetMinX(contentViewFrame) < 0) {
                    contentViewFrame.origin.x = 0.f;
                }
                
                contentViewFrame.size.width = MIN(boundsWidth, CGRectGetWidth(contentViewFrame));
            }
            
            //竖直不能完全显示
            if (CGRectGetMinY(contentViewFrame) < 0 ||
                CGRectGetMaxY(contentViewFrame) > boundsHeight) {
                
                if (CGRectGetMaxY(contentViewFrame) > boundsHeight) {
                    contentViewFrame.origin.y = boundsHeight - CGRectGetHeight(contentViewFrame);
                }
                
                if (CGRectGetMinX(contentViewFrame) < 0) {
                    contentViewFrame.origin.y = 0.f;
                }
                
                contentViewFrame.size.height = MIN(boundsHeight, CGRectGetHeight(contentViewFrame));
            }
        }
        
        if ([self.contentView needObserverKeyboardChangePosition] &&
            !CGRectEqualToRect(self.keyboardFrame, CGRectZero)) {
            
            CGFloat offset = CGRectGetMaxY(contentViewFrame) - CGRectGetMinY(self.keyboardFrame);
            if (offset > 0) {
                contentViewFrame.origin.y -= offset;
                CGPoint offset = [self.contentView contentFrameOffsetForKeyboardChange];
                contentViewFrame = CGRectOffset(contentViewFrame, offset.x, offset.y);
            }
        }
        
        self.contentView.frame = contentViewFrame;
    }
}

#pragma mark - observer keyboard change

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_keyboardWillChangeFrameNotification:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_keyboardDidChangeFrameNotification:)
                                                     name:UIKeyboardDidChangeFrameNotification
                                                   object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillChangeFrameNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:nil];
        
    }
}

- (void)_keyboardWillChangeFrameNotification:(NSNotification *)notification
{
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardFrame = [self convertRect:self.keyboardFrame fromView:self.window];
    if (self.keyboardFrame.origin.y >= CGRectGetHeight(self.window.bounds)) {
        self.keyboardFrame = CGRectZero;
    }
    
    if ([self.contentView needObserverKeyboardChangePosition]) {
       
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]];
        
        [self _updateContentViewFrame];
        
        [UIView commitAnimations];
        
    }else if ([self.contentView needObserverKeyboardChange]) {
        
        CGRect keyboardFrame = CGRectEqualToRect(self.keyboardFrame, CGRectZero) ? CGRectZero : [self.contentView convertRect:self.keyboardFrame fromView:self];
        
        //开始
        [self.contentView keyboardWillChangeToFrame:keyboardFrame];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]];
        
        //动画
        [self.contentView animationWhenKeyboardChangeToFrame:keyboardFrame];
        
        [UIView commitAnimations];
        
    }
}

- (void)_keyboardDidChangeFrameNotification:(NSNotification *)notification
{
    if([self.contentView needObserverKeyboardChange] &&
       ![self.contentView needObserverKeyboardChangePosition])
    {
        //结束
        [self.contentView keyboardDidChangeToFrame:CGRectEqualToRect(self.keyboardFrame, CGRectZero) ? CGRectZero : [self.contentView convertRect:self.keyboardFrame fromView:self]];
    }
}

#pragma mark - show && hide

- (void)show:(BOOL)animated {
    [self showInView:nil animated:animated completedBlock:nil];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated completedBlock:(void(^)(void))completedBlock
{
    if (view && ![view isKindOfClass:[UIWindow class]] && !view.window) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"MyPopoverView必须加入window"
                                     userInfo:nil];
    }
    
    //正在显示则隐藏
    if (_showing) {
        [self hide:NO completedBlock:nil];
    }
    
    //如果正在动画中则加入动作block,等待动画完毕后执行
    if (self.isAnimating) {
        typeof(self) __weak weak_self = self;
        [self _addActionBlock:^{
            [weak_self showInView:view animated:animated completedBlock:completedBlock];
        }];
        return;
    }
    
    _showing = YES;
    
    //更新毛玻璃效果
    UIWindow * basedWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : (view.window ?: [UIApplication sharedApplication].keyWindow);
    [self updateBlurredWithWindow:basedWindow];
    
    self.s_window = nil;
    if (view == nil) {
        
        //创建窗口并显示
        UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = self.contentView ? [self.contentView showPopoverWindowLevel] : (basedWindow ?  basedWindow.windowLevel : UIWindowLevelNormal);
        window.tintColor = basedWindow.tintColor;

        _MyPopoverViewController * vc = [[_MyPopoverViewController alloc] init];
        vc.automaticallyAdjustsScrollViewInsets = NO;
        vc.view.frame = window.bounds;
        window.rootViewController = vc;
        
        view = vc.view;
        self.s_window = window;
        
        [window makeKeyAndVisible];
    }
    
    //设置frame和可见性
    super.hidden = NO;
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view addSubview:self];
    
    //更新内容的大小
    [self _updateContentViewFrame];
    
    //开始显示回调
    [self.contentView startPopoverViewShow:YES animated:animated];
    
    if (animated) {
        
        void (^_completedBlock)(void) = ^{
            
            [self.contentView endPopoverViewShow:YES animated:animated];
            
            if (completedBlock) {
                completedBlock();
            }
            
            _isAnimating = NO;
            [self _commitAction];
        };
        
        //执行自定义动画
        if (![self.contentView customAnimationForPopoverView:self
                                                        show:YES
                                              animationBlock:^{
                                                _isAnimating = YES;
                                            } completedBlock:_completedBlock]) {
                                                     
            //无自定义动画则使用默认动画
            self.alpha = 0.f;
            [UIView animateWithDuration:0.5
                                  delay:0.0
                 usingSpringWithDamping:2.f
                  initialSpringVelocity:1.f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 _isAnimating = YES;
                                 self.alpha = 1.f;
                             } completion:^(BOOL finished) {
                                 _completedBlock();
                             }];
        }
        
    }else{
        
        [self.contentView endPopoverViewShow:YES animated:animated];
        if (completedBlock) {
            completedBlock();
        }
    }

}

- (void)hide:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    if (_showing) {
        
        //如果正在动画中则加入动作block,等待动画完毕后执行
        if (self.isAnimating) {
            typeof(self) __weak weak_self = self;
            [self _addActionBlock:^{
                [weak_self hide:animated completedBlock:completedBlock];
            }];
            return;
        }
        
        //通知开始显示
        _showing = NO;
        [self.contentView startPopoverViewShow:NO animated:animated];
        
        //完成blcok
        void(^_completeBlock)(void) = ^{
            [self removeFromSuperview];
            self.s_window.hidden = YES;
            self.s_window = nil;
            [self clearBlurred];
            [self.contentView endPopoverViewShow:NO animated:animated];
            
            super.hidden = YES;
            
            if (completedBlock) {
                completedBlock();
            }
        };
        
        if (animated) {
            
            void(^__completeBlock)(void) = ^{
                _completeBlock();
                _isAnimating = NO;
                [self _commitAction];
            };
            
            if (![self.contentView customAnimationForPopoverView:self
                                                            show:NO
                                                  animationBlock:^{
                                                    _isAnimating = YES;
                                                } completedBlock:__completeBlock])
            {
                [UIView animateWithDuration:0.5
                                      delay:0.0
                     usingSpringWithDamping:2.f
                      initialSpringVelocity:1.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     _isAnimating = YES;
                                     self.alpha = 0.f;
                                     
                                 } completion:^(BOOL finished) {
                                     __completeBlock();
                                 }];
            }
            
        }else{
            _completeBlock();
        }
    }
}


#pragma mark - touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isTapHiddenEnabled) {
        
        UITouch * touch = [touches anyObject];
        CGPoint point = self.contentView ? [touch locationInView:self.contentView] : CGPointZero;
        
        //触摸了以外区域
        if (!self.contentView || !CGRectContainsPoint(self.contentView.popoverContentBounds, point)) {
            
            BOOL bRet = YES;
            if (self.contentView) {
                bRet = [self.contentView popoverViewWillTapHiddenAtPoint:point];
            }
            
            if (bRet) {
                
                //询问代理
                id<MyPopoverViewDelegate> delegate = self.delegate;
                ifRespondsSelector(delegate, @selector(popoverViewWillTapHidden:)){
                    bRet = [delegate popoverViewWillTapHidden:self];
                }
             
                if (bRet) {
                    
                    BOOL animated = YES;
                    if (self.contentView) {
                        animated = [self.contentView popoverViewTapHiddenNeedAnimated];
                    }
                    
                    //隐藏
                    [self hide:animated completedBlock:nil];
                    
                    //发送消息
                    [self.contentView popoverViewDidTapHidden];
                    ifRespondsSelector(delegate, @selector(popoverViewDidTapHidden:)){
                        [delegate popoverViewDidTapHidden:self];
                    }
                    
                }
            }
            
            if (!bRet) {
                [super touchesBegan:touches withEvent:event];
            }
        }
    }else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (NSMutableArray *)actionsArray
{
    if (!_actionsArray) {
        _actionsArray = [NSMutableArray array];
    }
    
    return _actionsArray;
}

- (void)_addActionBlock:(void(^)(void))block {
    [self.actionsArray addObject:[block copy]];
}

- (void)_commitAction
{
    if (self.actionsArray.count) {
        
       void(^actionBlock)(void) = self.actionsArray.firstObject;
        [self.actionsArray removeObjectAtIndex:0];
        actionBlock();
    }
}


- (NSArray *)needAnimatedViewsForShow:(BOOL)show context:(id)context {
    return @[self.contentView];
}

@end

//----------------------------------------------------------


@implementation UIView (MyPopoverView)

- (MyPopoverView *)popoverView
{
    if ([self isKindOfClass:[MyPopoverView class]]) {
        return (MyPopoverView *)self;
    }else {
        return [self.superview popoverView];
    }
}

- (void)popoverContentViewSizeInvaild {
    [self.popoverView setNeedsLayout];
}

- (UIWindowLevel)showPopoverWindowLevel
{
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    return keyWindow ? keyWindow.windowLevel : UIWindowLevelNormal;
}

- (BOOL)needObserverKeyboardChangePosition {
    return NO;
}

- (CGPoint)contentFrameOffsetForKeyboardChange {
    return CGPointZero;
}

- (BOOL)needObserverKeyboardChange {
    return NO;
}

- (void)keyboardWillChangeToFrame:(CGRect)keyboardFrame {
    //do nothing
}

- (void)animationWhenKeyboardChangeToFrame:(CGRect)keyboardFrame {
    //do nothing
}

- (void)keyboardDidChangeToFrame:(CGRect)keyboardFrame {
    //do nothing
}

- (CGRect)popoverContentBounds {
    return self.bounds;
}

- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point {
    return YES;
}

- (BOOL)popoverViewTapHiddenNeedAnimated {
    return YES;
}

- (void)popoverViewDidTapHidden {
    // do nothing
}

- (BOOL)customAnimationForPopoverView:(MyPopoverView *)popoverView
                                 show:(BOOL)show
                       animationBlock:(void(^)(void))animationBlock
                       completedBlock:(void(^)(void))completedBlock
{
    return NO;
}

- (void)defaultPushCustomAnimationForPopoverView:(MyPopoverView *)popoverView
                                       direction:(MyMoveAnimatedDirection)direction
                                            show:(BOOL)show
                                  animationBlock:(void(^)(void))animationBlock
                                  completedBlock:(void(^)(void))completedBlock
{
    CGRect startFrame = self.frame;
    CGRect endFrame = self.frame;
    
    switch (direction) {
        case MyMoveAnimatedDirectionDown:
            
            if (show) {
                startFrame.origin.y += CGRectGetHeight(startFrame);
            }else {
                endFrame.origin.y += CGRectGetHeight(endFrame);
            }
            
            break;
        
        case MyMoveAnimatedDirectionUp:
            
            if (show) {
                startFrame.origin.y -= CGRectGetHeight(startFrame);
            }else {
                endFrame.origin.y -= CGRectGetHeight(endFrame);
            }
            
            break;

        case MyMoveAnimatedDirectionLeft:
            
            if (show) {
                startFrame.origin.x -= CGRectGetWidth(startFrame);
            }else {
                endFrame.origin.x -= CGRectGetWidth(endFrame);
            }
            
            break;
        
        case MyMoveAnimatedDirectionRight:
            
            if (show) {
                startFrame.origin.x += CGRectGetWidth(startFrame);
            }else {
                endFrame.origin.x += CGRectGetWidth(endFrame);
            }
            
            break;
    }
    
    if (show) {
        
        self.frame = startFrame;
        
        UIColor * backgroundColor = popoverView.backgroundColor;
        popoverView.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.3 animations:^{
            popoverView.backgroundColor = backgroundColor;
        }];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:show ? 0.8f : 1.2f
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (animationBlock) {
                             animationBlock();
                         }
                         
                         if (!show) {
                             popoverView.backgroundColor = [UIColor clearColor];
                         }
                         
                         self.frame = endFrame;
                         
                     } completion:^(BOOL finished) {
                         if (completedBlock) {
                             completedBlock();
                         }
                     }];
}

- (void)startPopoverViewShow:(BOOL)show animated:(BOOL)animated {
    // do nothing
}

- (void)endPopoverViewShow:(BOOL)show animated:(BOOL)animated {
    // do nothing
}


@end


