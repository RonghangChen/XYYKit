//
//  MyUserGuideCell.m
//  
//
//  Created by LeslieChen on 15/5/21.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyUserGuideView.h"

//----------------------------------------------------------

@interface MyUserGuideView ()

@property(nonatomic,readonly) MyUserGuideViewShowDirection showDirection;
@property(nonatomic,readonly) BOOL bounces;

//暂停的时间
@property(nonatomic) NSTimeInterval pausedTimeInterval;

@end

//----------------------------------------------------------

@implementation MyUserGuideView

#pragma mark -

- (void)startShow:(BOOL)show bounces:(BOOL)bounces direction:(MyUserGuideViewShowDirection)direction
{
    BOOL bRet = (self.status == MyUserGuideViewStatusNone) ||
                (show && self.status == MyUserGuideViewStatusHidden) ||
                (!show && self.status == MyUserGuideViewStatusShowed);
    
    if (bRet) {
        
        _status = show ? MyUserGuideViewStatusShowing : MyUserGuideViewStatusHiding;
        _bounces = bounces;
        _showDirection = direction;
        
        [self animationForShow:show
                       bounces:bounces
                      duration:[self _animationDurationForShow:show]
                     direction:direction];
        
        //速度为0，定位到当前时间
        self.pausedTimeInterval = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.layer.speed = 0.f;
        self.layer.timeOffset = self.pausedTimeInterval;
        
        //
        [self didStartShow:show withBounces:bounces andDirection:direction];
    }
    
#if DEBUG
    else {
        NSLog(@"内部不一致，没有完成显示就开始隐藏或者没有完成隐藏就开始显示");
    }
#endif
}

- (BOOL)_checkShowStatusForShowHandle:(BOOL)show
{
    BOOL bRet = (show && self.status == MyUserGuideViewStatusShowing) ||
                (!show && self.status == MyUserGuideViewStatusHiding);
    
#if DEBUG
    if (!bRet) {
        NSLog(@"内部不一致，没有开始显示或者隐藏就开始相应操作");
    }
#endif

    return bRet;
    
}

- (NSTimeInterval)_animationDurationForShow:(BOOL)show {
    return [self animationDurationForShow:show bounces:self.bounces direction:self.showDirection];
}

- (void)updateShow:(BOOL)show withProgress:(CGFloat)progress
{
    if ([self _checkShowStatusForShowHandle:show]) {
        self.layer.timeOffset = self.pausedTimeInterval + progress * [self _animationDurationForShow:show];
    }
}

- (void)completedShow:(BOOL)show;
{
    if ([self _checkShowStatusForShowHandle:show]) {
        _status = show ? MyUserGuideViewStatusShowed : MyUserGuideViewStatusHidden;
        
        [self _resumeAnimationWithAnimationDuration:[self _animationDurationForShow:show]];
        [self didCompletedShow:show withDirection:self.showDirection];
    }
}

- (void)cancledShow:(BOOL)show
{
    if ([self _checkShowStatusForShowHandle:show]) {
        _status = show ? MyUserGuideViewStatusHidden : MyUserGuideViewStatusShowed;
        
        [self _resumeAnimationWithAnimationDuration:[self _animationDurationForShow:show]];
        [self didCancledShow:show withBounces:self.bounces andDirection:self.showDirection];
    }
}

- (void)_resumeAnimationWithAnimationDuration:(NSTimeInterval)duration
{
    self.layer.speed = 1.f;
    self.layer.timeOffset = 0.f;
    self.layer.beginTime = 0.f;
    
    //定位到动画结束时
    NSTimeInterval timeSincePaused = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - self.pausedTimeInterval;
    
    //动画结束的时间
    self.layer.beginTime = timeSincePaused - duration;
}

#pragma mark -

- (NSTimeInterval)animationDurationForShow:(BOOL)show
                                   bounces:(BOOL)bounces
                                 direction:(MyUserGuideViewShowDirection)direction
{
    return 0.f;
}

- (void)animationForShow:(BOOL)show
                 bounces:(BOOL)bounces
                duration:(NSTimeInterval)duration
               direction:(MyUserGuideViewShowDirection)direction
{
    //do nothing
}

- (void)didStartShow:(BOOL)show
         withBounces:(BOOL)bounces
        andDirection:(MyUserGuideViewShowDirection)direction
{
    //do nothing
}

- (void)didCompletedShow:(BOOL)show withDirection:(MyUserGuideViewShowDirection)direction {
    //do nothing
}

- (void)didCancledShow:(BOOL)show
           withBounces:(BOOL)bounces
          andDirection:(MyUserGuideViewShowDirection)direction
{
    //do nothing
}

#pragma mark - 

- (void)updateViewWithPageInfo:(NSDictionary *)pageInfo context:(MyCellContext *)context; {
    
}

- (void)tryCompletedGuide
{
    id<MyUserGuideViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(userGuideViewWantToCompletedGuide:)) {
        [delegate userGuideViewWantToCompletedGuide:self];
    }
}

@end
