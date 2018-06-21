//
//  MyViewControllerAnimatedTransitioning.m
//  
//
//  Created by LeslieChen on 15/8/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyBasicViewControllerAnimatedTransitioning.h"
#import "XYYBaseDef.h"

@implementation MyBasicViewControllerAnimatedTransitioning

- (id)init
{
    self = [super init];
    
    if (self) {
        _transitionDuration = 0.4;
    }
    
    return self;
}

- (void)didEndTransitioningAnimationWithContext:(id<UIViewControllerContextTransitioning>)transitionContext
                                       finished:(BOOL)isfinished
{
    BOOL isCompleted =  isfinished && ![transitionContext transitionWasCancelled];
    [transitionContext completeTransition:isCompleted];

    id<MyBasicViewControllerAnimatedTransitioningDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(viewControllerAnimatedTransitioning:didEndTransitioning:)) {
        [delegate viewControllerAnimatedTransitioning:self didEndTransitioning:isCompleted];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self didEndTransitioningAnimationWithContext:transitionContext finished:YES];
}

@end
