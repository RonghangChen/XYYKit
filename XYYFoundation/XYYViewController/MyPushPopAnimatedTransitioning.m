//
//  MyPushPopAnimatedTransitioning.m
//
//
//  Created by LeslieChen on 14-4-1.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//


//----------------------------------------------------------

#import "MyPushPopAnimatedTransitioning.h"
#import "XYYConst.h"

//----------------------------------------------------------

@implementation MyPushPopAnimatedTransitioning
{
    void(^_animations)();
}

- (id)init {
    return [self initWithType:PushPopAnimatedTypeLeftPush animations:nil];
}

- (id)initWithType:(PushPopAnimatedType)type {
    return [self initWithType:type animations:nil];
}

- (id)initWithType:(PushPopAnimatedType)type animations:(void (^)(void))animations
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
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame   = [transitionContext finalFrameForViewController:toVC];
    CGFloat viewWidth   = CGRectGetWidth(finalFrame);
    
    //黑色mask视图
    UIView * maskView = [[UIView alloc] initWithFrame:containerView.bounds];
    maskView.backgroundColor = BlackColorWithAlpha(0.6f);
    
    //阴影视图
    UIView * shadowView = [[UIView alloc] init];
    shadowView.layer.shadowOpacity = 1.f;
    
    //阴影方向
    NSUInteger shadowsDirection;
    
    //初始位置
    if (self.type & PushPopAnimatedTypePush) {
        
        toVC.view.frame = CGRectOffset(finalFrame, (_type & PushPopAnimatedTypeLeft) ? viewWidth : -viewWidth, 0);
        
        maskView.alpha   = 0.f;
        shadowView.frame = toVC.view.frame;
        shadowView.alpha = 0.05f;
        shadowsDirection = (self.type & PushPopAnimatedTypeLeft) ? PushPopAnimatedTypeLeft : PushPopAnimatedTypeRight;
        
        [containerView addSubview:maskView];
        [containerView addSubview:shadowView];
        [containerView addSubview:toVC.view];
        
    }else{
        
        toVC.view.frame = CGRectOffset(finalFrame, ((self.type & PushPopAnimatedTypeLeft) ? viewWidth :  - viewWidth) * 0.5f, 0.f);
        
        shadowView.frame = fromVC.view.frame;
        shadowView.alpha = 0.7f;
        shadowsDirection = (self.type & PushPopAnimatedTypeRight) ? PushPopAnimatedTypeLeft : PushPopAnimatedTypeRight;
        
        [containerView insertSubview:toVC.view belowSubview:fromVC.view];
        [containerView insertSubview:maskView belowSubview:fromVC.view];
        [containerView insertSubview:shadowView belowSubview:fromVC.view];
    }
    
    if (shadowsDirection == PushPopAnimatedTypeLeft) {
        shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.f, 0.f, 2.f, CGRectGetHeight(shadowView.bounds))].CGPath;
        shadowView.layer.shadowOffset = CGSizeMake(-3.f, 0.f);
    }else{
        shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.f, CGRectGetWidth(shadowView.bounds) - 2.f, 2.f, CGRectGetHeight(shadowView.bounds))].CGPath;
        shadowView.layer.shadowOffset = CGSizeMake(3.f, 0.f);
    }
    
    //运动
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        toVC.view.frame = finalFrame;
        
        if (self.type & PushPopAnimatedTypePush) {
            
            fromVC.view.frame = CGRectOffset(initialFrame, ((self.type & PushPopAnimatedTypeRight) ? viewWidth : - viewWidth) * 0.5f, 0.f);
            
            maskView.alpha   = 1.f;
            shadowView.frame = toVC.view.frame;
            shadowView.alpha = 0.7f;
        }else{
            
            fromVC.view.frame = CGRectOffset(initialFrame, (self.type & PushPopAnimatedTypeRight) ? viewWidth : - viewWidth, 0.f);
            
            maskView.alpha   = 0.f;
            shadowView.frame = fromVC.view.frame;
            shadowView.alpha = 0.05f;
        }
        
        //自定义动作
        if (_animations) {
            _animations();
        }
        
    } completion:^(BOOL finished){
        
        [maskView removeFromSuperview];
        [shadowView removeFromSuperview];
        
        //通知完成
        [self didEndTransitioningAnimationWithContext:transitionContext finished:finished];
    }];
}

@end
