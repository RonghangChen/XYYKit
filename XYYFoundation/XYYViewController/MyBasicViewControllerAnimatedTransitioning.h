//
//  MyViewControllerAnimatedTransitioning.h
//  
//
//  Created by LeslieChne on 15/8/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class MyBasicViewControllerAnimatedTransitioning;

//----------------------------------------------------------

@protocol MyBasicViewControllerAnimatedTransitioningDelegate <NSObject>

@optional

- (void)viewControllerAnimatedTransitioning:(MyBasicViewControllerAnimatedTransitioning *)viewControllerAnimatedTransitioning didEndTransitioning:(BOOL)completed;

@end

//----------------------------------------------------------

//该类为视图控制器过渡动画基类
NS_CLASS_AVAILABLE_IOS(7_0)@interface MyBasicViewControllerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

- (void)didEndTransitioningAnimationWithContext:(id<UIViewControllerContextTransitioning>)transitionContext
                                       finished:(BOOL)isfinished;

@property(nonatomic,weak) id<MyBasicViewControllerAnimatedTransitioningDelegate> delegate;


//动画时长，默认为0.4f;
@property(nonatomic) NSTimeInterval transitionDuration;


@end
