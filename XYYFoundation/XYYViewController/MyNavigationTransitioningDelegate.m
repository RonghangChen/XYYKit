//
//  MyNavigationTransitionDelegate.m
//  YHDemo
//
//  Created by LeslieChen on 14-9-28.
//  Copyright (c) 2014年 hldw. All rights reserved.
//

#import "MyNavigationTransitioningDelegate.h"
#import "MyPushPopAnimatedTransitioning.h"
#import "XYYConst.h"
#import  <objc/runtime.h>

@implementation MyNavigationTransitioningDelegate
{
    UIPercentDrivenInteractiveTransition * _interactiveTransition;
    UIPanGestureRecognizer               * _interactiveGestureRecognizer;
    UIViewController                     * _interactivetTopViewController;
}

#pragma mark - life circle

- (id)init
{
    @throw [NSException exceptionWithName:@"方法调用错误"
                                   reason:
            [NSString stringWithFormat:@"%@类不支持默认初始化",NSStringFromClass([self class])
             ]
                                 userInfo:nil];

}

- (id)initWithNavigationController:(UINavigationController *)navigationController
{
    if (!navigationController) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"navigationController不能为nil"
                                     userInfo:nil];
    }
    
    self = [super init];
    
    if (self) {
        
        //添加手势识别
        _interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_interactiveGestureHandle:)];
        _interactiveGestureRecognizer.delegate = self;
        [navigationController.view addGestureRecognizer:_interactiveGestureRecognizer];
        
        //设置代理
        navigationController.delegate = self;
        _navigationController = navigationController;
    }
    
    return self;
}

- (void)dealloc
{
    //移除手势识别
    [self.navigationController.view removeGestureRecognizer:_interactiveGestureRecognizer];
}

- (BOOL)_checkDelegate
{
    if (self.navigationController.delegate != self) {
        
        [_interactiveGestureRecognizer removeTarget:self action:@selector(_interactiveGestureHandle:)];
        [self.navigationController.view removeGestureRecognizer:_interactiveGestureRecognizer];
        
        _navigationController = nil;
        _interactivePoping = NO;
        _transitioning = NO;
        _interactivetTopViewController = nil;
        _interactiveTransition = nil;
        _interactiveGestureRecognizer = nil;
        
        NSLog(@"由于更改了delegate,MyNavigationTransitioningDelegate已失效");
        
        return NO;
    }
    
    return YES;
}

#pragma mark - gestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //其它滑动手势需要交互手势失败
    if (gestureRecognizer == _interactiveGestureRecognizer) {
        return [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ||
                [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]];
    }

    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (gestureRecognizer == _interactiveGestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(gestureRecognizer == _interactiveGestureRecognizer ){
        
        if ([self _checkDelegate]) {
            
            UINavigationController * navigationController = self.navigationController;
            if(!_transitioning && navigationController.viewControllers.count > 1){
                
                UIViewController * topViewController = navigationController.topViewController;
                if ([topViewController isNavigationInteractivePopEnabled]) {
                    return [topViewController interactivePopGestureShouldReceiveTouch:touch];
                }
            }
        }
        return NO;
    }
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (_interactiveGestureRecognizer == gestureRecognizer) {
        
        UINavigationController * navigationController = self.navigationController;
        CGPoint translation = [_interactiveGestureRecognizer translationInView:navigationController.view];
        
        return [navigationController.topViewController interactivePopGestureShouldBeginWithTranslation:translation];
    }
    return YES;
}

- (void)_interactiveGestureHandle:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    UINavigationController * navigationController = self.navigationController;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        if ([self _checkDelegate]) {
            
            _interactivetTopViewController = navigationController.topViewController;
            _interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            _interactiveTransition.completionCurve = UIViewAnimationCurveLinear;
            _interactivePoping = YES;
            
            [navigationController popViewControllerAnimated:YES];
            
            //调用开始通知
            [_interactivetTopViewController startInteractivePop];
        }
        
    }else{
        
        CGPoint locationPoint = [gestureRecognizer locationInView:navigationController.view];
        CGPoint translation   = [gestureRecognizer translationInView:navigationController.view];
        
        //完成的比例
        CGFloat fraction = [_interactivetTopViewController navigationInteractivePopCompletePercentForTranslation:translation withStartPoint:locationPoint] + [_interactiveTransition percentComplete];
        
        if (state == UIGestureRecognizerStateChanged) {
            [_interactiveTransition updateInteractiveTransition:ChangeInMinToMax(fraction, 0.f, 1.f)];
        }else{
            
            //速度
            CGPoint velocity = [gestureRecognizer velocityInView:navigationController.view];
            
            //加上速度
            fraction += [_interactivetTopViewController navigationInteractivePopCompletePercentForTranslation:velocity withStartPoint:locationPoint];
            
            //完成
            if ( state == UIGestureRecognizerStateEnded && fraction >= 0.5f) {
                [_interactiveTransition finishInteractiveTransition];
                [_interactivetTopViewController finishInteractivePop];
            }else{//取消
                [_interactiveTransition cancelInteractiveTransition];
                [_interactivetTopViewController cancelInteractivePop];
            }
            
            _interactiveTransition = nil;
            _interactivetTopViewController = nil;
            _interactivePoping = NO;
        }
        
        //置0
        [gestureRecognizer setTranslation:CGPointZero inView:navigationController.view];
    }
}


- (void)viewControllerAnimatedTransitioning:(MyBasicViewControllerAnimatedTransitioning *)viewControllerAnimatedTransitioning didEndTransitioning:(BOOL)completed
{
//    _interactivePoping = NO;
    _transitioning = NO;
}

#pragma mark - NavigationController delegate

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return _interactiveTransition;
}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    MyBasicViewControllerAnimatedTransitioning * transitioning  = nil;
    
    switch (operation) {
            
        case UINavigationControllerOperationPush:
        {
            transitioning = [toVC navigationControllerAnimatedTransitioningForOperation:operation interactive:_interactiveTransition != nil];
            transitioning = transitioning ? : [[MyPushPopAnimatedTransitioning alloc] initWithType:PushPopAnimatedTypeNavigationPush];
        }
            break;
            
        case UINavigationControllerOperationPop:
        {
            transitioning  = [fromVC navigationControllerAnimatedTransitioningForOperation:operation interactive:_interactiveTransition != nil];
            transitioning = transitioning ? : [[MyPushPopAnimatedTransitioning alloc] initWithType:PushPopAnimatedTypeNavigationPop];
        }
            
            break;
            
        default:
            break;
    }
    
    transitioning.delegate = self;
    if (transitioning) _transitioning = YES;
    
    return transitioning;
}

@end

//----------------------------------------------------------

static char navigationInteractivePopEnabledKey;

//----------------------------------------------------------

@implementation UIViewController (NavigationTransitioning)

- (MyNavigationTransitioningDelegate *)navigationTransitioningDelegate
{
    UINavigationController * navigationController = nil;
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)self;
    }else{
        navigationController = [self navigationController];
    }
    
    if (navigationController && [navigationController.delegate isKindOfClass:[MyNavigationTransitioningDelegate class]]) {
        return (MyNavigationTransitioningDelegate *)navigationController.delegate;
    }else{
        return [self.parentViewController navigationTransitioningDelegate];
    }
}

- (MyBasicViewControllerAnimatedTransitioning *)navigationControllerAnimatedTransitioningForOperation:(UINavigationControllerOperation)operation interactive:(BOOL)interactive
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    return childViewController ? [childViewController navigationControllerAnimatedTransitioningForOperation:operation interactive:interactive] : nil;
}


- (BOOL)isNavigationInteractivePopEnabled
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    
    return childViewController ? [childViewController isNavigationInteractivePopEnabled] :[objc_getAssociatedObject(self, &navigationInteractivePopEnabledKey) boolValue];
}

- (void)setNavigationInteractivePopEnable:(BOOL)navigationInteractivePopEnable
{
    objc_setAssociatedObject(self, &navigationInteractivePopEnabledKey, navigationInteractivePopEnable ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isNavigationInteractivePoping {
    return [self navigationTransitioningDelegate].isInteractivePoping;
}

- (BOOL)isNavigationTransitioning {
    return [self navigationTransitioningDelegate].isTransitioning;
}

- (BOOL)interactivePopGestureShouldBeginWithTranslation:(CGPoint)translation
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    
    if (childViewController) {
        return  [childViewController interactivePopGestureShouldBeginWithTranslation:translation];
    }else{
        //水平向右移动
        return (translation.x > 0 && fabs(translation.x) > fabs(translation.y));
    }
}

- (BOOL)interactivePopGestureShouldReceiveTouch:(UITouch *)touch
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    return childViewController ? [childViewController interactivePopGestureShouldReceiveTouch:touch] : YES;
}

- (float)navigationInteractivePopCompletePercentForTranslation:(CGPoint)translation  withStartPoint:(CGPoint)startPoint
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    
    if (childViewController) {
        return [childViewController navigationInteractivePopCompletePercentForTranslation:translation  withStartPoint:startPoint];
    }else{
        return translation.x / CGRectGetWidth(self.view.bounds);
    }
}

- (void)startInteractivePop
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    [childViewController startInteractivePop];
}

- (void)finishInteractivePop
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    [childViewController finishInteractivePop];
}

- (void)cancelInteractivePop
{
    UIViewController * childViewController = [self childViewControllerForNavigationControllerTransitioning];
    [childViewController cancelInteractivePop];
}

- (UIViewController *)childViewControllerForNavigationControllerTransitioning
{
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [(UITabBarController *)self selectedViewController];
    }
    
    return nil;
}

@end
