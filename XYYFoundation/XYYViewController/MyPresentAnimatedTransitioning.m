//
//  MyDimissAnimatedTransitioning.m
//  5idj
//
//  Created by LeslieChen on 14/10/23.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "MyPresentAnimatedTransitioning.h"
#import "XYYConst.h"

@implementation MyPresentAnimatedTransitioning
{
    void(^_animations)(void);
}

- (id)init {
    return [self initWithType:MyPresentAnimatedTransitioningTypePresent animations:nil];
}

- (id)initWithType:(MyPresentAnimatedTransitioningType)type {
    return [self initWithType:type animations:nil];
}

- (id)initWithType:(MyPresentAnimatedTransitioningType)type animations:(void(^)(void))animations
{
    self = [super init];
    
    if (self) {
        _type = type;
        _animations = [animations copy];
    }
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView * containerView = [transitionContext containerView];
    CGRect finalFrame   = [transitionContext finalFrameForViewController:toVC];
    
    //黑色遮罩
    UIView * maskView = [[UIView alloc] initWithFrame:containerView.bounds];
    maskView.backgroundColor = BlackColorWithAlpha(0.6f);
    
    //阴影动画
    CABasicAnimation * animation =[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    animation.duration = [self transitionDuration:transitionContext];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    if (self.type == MyPresentAnimatedTransitioningTypePresent) {
        
        maskView.alpha  = 0.f;
        toVC.view.frame = CGRectOffset(finalFrame, 0.f, CGRectGetHeight(finalFrame));
        
        //设置阴影并添加动画
        animation.fromValue = @(0.f);
        toVC.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:toVC.view.bounds].CGPath;
        toVC.view.layer.shadowOffset =  CGSizeMake(0.f, -2.f);
        toVC.view.layer.shadowOpacity = 0.5f;
        [toVC.view.layer addAnimation:animation forKey:nil];
        
        [containerView addSubview:maskView];
        [containerView addSubview:toVC.view];
        
    }else{
        
        toVC.view.frame = finalFrame;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        toVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
        
        //设置阴影并添加动画
        animation.fromValue = @(0.5f);
        fromVC.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:fromVC.view.bounds].CGPath;
        fromVC.view.layer.shadowOffset =  CGSizeMake(0.f, -2.f);
        fromVC.view.layer.shadowOpacity = 0.f;
        [fromVC.view.layer addAnimation:animation forKey:nil];

        
        [containerView insertSubview:maskView  belowSubview:fromVC.view];
        [containerView insertSubview:toVC.view belowSubview:maskView];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (self.type == MyPresentAnimatedTransitioningTypePresent) {
            
            toVC.view.frame = finalFrame;
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            toVC.view.transform   = CGAffineTransformIdentity;
#endif
            fromVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
            
            maskView.alpha = 1.f;
            
        }else{
            CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
            fromVC.view.frame = CGRectOffset(initialFrame, 0, CGRectGetHeight(initialFrame));
            
            //ios8以下SDK需如此不然会错乱
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            toVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
            toVC.view.transform = CGAffineTransformIdentity;
            
            maskView.alpha = 0.f;
        }
        
        //自定义动作
        if (_animations) {
            _animations();
        }
    }
    completion:^(BOOL finished) {
        
        [maskView removeFromSuperview];
        fromVC.view.transform = CGAffineTransformIdentity;
        toVC.view.transform   = CGAffineTransformIdentity;
        
        fromVC.view.layer.shadowOpacity = 0.f;
        fromVC.view.layer.shadowPath = nil;
        toVC.view.layer.shadowOpacity = 0.f;
        toVC.view.layer.shadowPath = nil;
        
        //通知完成
        [self didEndTransitioningAnimationWithContext:transitionContext finished:finished];
    }];
}

@end
