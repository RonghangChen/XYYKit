//
//  NSObject+IntervalAnimation.m
//  
//
//  Created by LeslieChen on 15/3/30.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "NSObject+IntervalAnimation.h"
#import "UIView+IntervalAnimation.h"
#import "ScreenAdaptation.h"

@implementation NSObject (IntervalAnimation)

- (void)startCommitIntervalAnimatedWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                                        duration:(NSTimeInterval)duration
                                           delay:(NSTimeInterval)delay
                                         forShow:(BOOL)show
                                         context:(id)context
                                  completedBlock:(void(^)(BOOL finished))completedBlock
{
    
    CGSize containerSize = CGSizeZero;
    
    if ([self isKindOfClass:[UIView class]]){
        containerSize = [(UIView *)self bounds].size;
    }else if ([self isKindOfClass:[UIViewController class]]) {
        containerSize = [(UIViewController *)self view].bounds.size;
    }else{
        containerSize = screenSize();
    }
    
    [self commitIntervalAnimatedWithDirection:moveAnimtedDirection
                                containerSize:containerSize
                                     duration:duration
                                        delay:delay
                                      forShow:show
                                      context:context
                               completedBlock:completedBlock];
    
}

- (void)commitIntervalAnimatedWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                              containerSize:(CGSize)containerSize
                                   duration:(NSTimeInterval)duration
                                      delay:(NSTimeInterval)delay
                                    forShow:(BOOL)show
                                    context:(id)context
                             completedBlock:(void (^)(BOOL))completedBlock
{
    
    NSArray * needAnimatedObjects = [self needAnimatedObjectsWithDirection:moveAnimtedDirection
                                                                   forShow:show
                                                                   context:context];
    if (needAnimatedObjects.count == 0) {
        if (completedBlock) {
            completedBlock(YES);
        }
        
        return;
    }
    
    NSUInteger i = 0;
    NSTimeInterval animationInterval = [self animationIntervalForDuration:duration forShow:show];
    NSTimeInterval animationIntervalForGroup = [self animationIntervalForGroupWithDuration:duration forShow:show];
    for (id objectData in needAnimatedObjects) {
        
        NSArray * objects = nil;
        if ([objectData isKindOfClass:[NSArray class]]){
            objects = objectData;
        }else{
            objects = @[objectData];
        }
        
        NSUInteger j = 0;
        for (id object in objects) {
            
#define ISEND ((i == needAnimatedObjects.count - 1) && (j == objects.count - 1))
            
            if (object == self) {
                [self animationWithDirection:moveAnimtedDirection
                               containerSize:containerSize
                                    duration:duration
                                       delay:delay
                                     forShow:show
                                     context:context
                              completedBlock:ISEND ? completedBlock : nil];
            }else{
                [object commitIntervalAnimatedWithDirection:moveAnimtedDirection
                                              containerSize:containerSize
                                                   duration:duration
                                                      delay:delay + animationInterval * i + animationIntervalForGroup * j
                                                    forShow:show
                                                    context:context
                                             completedBlock:ISEND ? completedBlock : nil];
            }
            
            ++ j;
        }
        
        ++ i;
    }
}

- (void)animationWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                 containerSize:(CGSize)containerSize
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                       forShow:(BOOL)show
                       context:(id)context
                completedBlock:(void (^)(BOOL))completedBlock
{
    UIView * animatedView = nil;
    if ([self isKindOfClass:[UIView class]]) {
        animatedView = (UIView *)self;
    }else if ([self isKindOfClass:[UIViewController class]]){
        animatedView = [(UIViewController *)self view];
    }
    
    
    if (animatedView == nil) {
        if (completedBlock) {
            completedBlock(YES);
        }
        return;
    }
    
    CGRect tmpFrame = animatedView.frame;
    switch (moveAnimtedDirection) {
        case MyMoveAnimatedDirectionLeft:
        tmpFrame = CGRectOffset(tmpFrame, (show ? 1.f : -1.f ) * containerSize.width, 0.f);
        break;
        
        case MyMoveAnimatedDirectionRight:
        tmpFrame = CGRectOffset(tmpFrame, (show ? 1.f : -1.f ) * -containerSize.width, 0.f);
        break;
        
        case MyMoveAnimatedDirectionUp:
        tmpFrame = CGRectOffset(tmpFrame, 0.f, (show ? 1.f : -1.f ) * containerSize.height);
        break;
        
        case MyMoveAnimatedDirectionDown:
        tmpFrame = CGRectOffset(tmpFrame, 0.f, (show ? 1.f : -1.f ) * -containerSize.height);
        break;
    }
    
    CGRect fromFrame,toFrame;
    
    if (show) {
        fromFrame = tmpFrame;
        toFrame = animatedView.frame;
    }else{
        fromFrame = animatedView.frame;
        toFrame = tmpFrame;
    }
    
    animatedView.frame = fromFrame;
    
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:[self animationDampingRatioForDuration:duration]
          initialSpringVelocity:[self initialSpringVelocityForDuration:duration]
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         animatedView.frame = toFrame;
                     } completion:completedBlock];
    
}

- (NSTimeInterval)animationIntervalForDuration:(NSTimeInterval)duration forShow:(BOOL)show {
    return 0.2f;
}

- (NSTimeInterval)animationIntervalForGroupWithDuration:(NSTimeInterval)duration forShow:(BOOL)show {
    return 0.f;
}

- (CGFloat)animationDampingRatioForDuration:(NSTimeInterval)duration {
    return 0.8f;
}

- (CGFloat)initialSpringVelocityForDuration:(NSTimeInterval)duration {
    return 0.f;
}

- (NSArray *)needAnimatedObjectsWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                                      forShow:(BOOL)show
                                      context:(id)context
{
    if ([self isKindOfClass:[UIView class]]){
        return [(UIView *)self needAnimatedViewsWithDirection:moveAnimtedDirection
                                                      forShow:show
                                                      context:context];
    }else {
        return @[self];
    }
}


@end
