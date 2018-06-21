//
//  NSObject+IntervalAnimation.h
//  
//
//  Created by LeslieChen on 15/3/30.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int,MyMoveAnimatedDirection) {
    MyMoveAnimatedDirectionUp,
    MyMoveAnimatedDirectionDown,
    MyMoveAnimatedDirectionLeft,
    MyMoveAnimatedDirectionRight
};

@interface NSObject (IntervalAnimation)

//开始动作
- (void)startCommitIntervalAnimatedWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                                        duration:(NSTimeInterval)duration
                                           delay:(NSTimeInterval)delay
                                         forShow:(BOOL)show
                                         context:(id)context
                                  completedBlock:(void(^)(BOOL finished))completedBlock;

//动作循环
- (void)commitIntervalAnimatedWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                              containerSize:(CGSize)containerSize
                                   duration:(NSTimeInterval)duration
                                      delay:(NSTimeInterval)delay
                                    forShow:(BOOL)show
                                    context:(id)context
                             completedBlock:(void(^)(BOOL finished))completedBlock;
//动画
- (void)animationWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                 containerSize:(CGSize)containerSize
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                       forShow:(BOOL)show
                       context:(id)context
                completedBlock:(void(^)(BOOL finished))completedBlock;

- (NSArray *)needAnimatedObjectsWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                                      forShow:(BOOL)show
                                      context:(id)context;

//组之间的间隔,默认返回0.2f
- (NSTimeInterval)animationIntervalForDuration:(NSTimeInterval)duration forShow:(BOOL)show;
//组内的间隔
- (NSTimeInterval)animationIntervalForGroupWithDuration:(NSTimeInterval)duration  forShow:(BOOL)show;

- (CGFloat)animationDampingRatioForDuration:(NSTimeInterval)duration;
- (CGFloat)initialSpringVelocityForDuration:(NSTimeInterval)duration;


@end
