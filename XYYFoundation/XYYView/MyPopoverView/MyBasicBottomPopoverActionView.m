//
//  MyBasicBottomPopoverActionView.m
//  leslie
//
//  Created by 陈荣航 on 2017/11/10.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "MyBasicBottomPopoverActionView.h"
#import "XYYConst.h"

@implementation MyBasicBottomPopoverActionView

- (MyPopoverView *)showWithConfigBlock:(void(^)(MyPopoverView * popoverView))configBlock
                               animated:(BOOL)animated
                        completedBlock:(void(^)(void))completedBlock
{
    if (self.popoverView) {
        return nil;
    }
    
    MyPopoverView * popoverView = [[MyPopoverView alloc] initWithContentView:self];
    popoverView.backgroundColor = BlackColorWithAlpha(0.5f);
    popoverView.contentViewAnchorPoint = CGPointMake(0.5f, 1.f);
    popoverView.locationAnchorPoint = CGPointMake(0.5f, 1.f);
    
    //自定义配置
    if (configBlock) {
        configBlock(popoverView);
    }
    
    [[MyAlertViewManager sharedManager] showAlertView:self withBlock:^{
        [popoverView showInView:nil animated:animated completedBlock:completedBlock];
    }];
    
    return popoverView;
}

- (void)hideWithAnimted:(BOOL)animated completedBlock:(void(^)(void))completedBlock
{
    if ([[MyAlertViewManager sharedManager] isShowAlertView:self]) {
        [[MyAlertViewManager sharedManager] hideAlertView:self withAnimated:animated completedBlock:completedBlock];
    }else {
        [self hideAlertViewWithAnimated:animated completedBlock:completedBlock];
    }
}

- (void)hideAlertViewWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock {
    [self.popoverView hide:animated completedBlock:completedBlock];
}

#pragma mark -

- (CGFloat)heightForContainerSize:(CGSize)size {
    return 0.f;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = [self heightForContainerSize:size];
    
    if (@available(iOS 11.0, *)) {
        return CGSizeMake(size.width, height + self.popoverView.safeAreaInsets.bottom);
    } else {
        return CGSizeMake(size.width, height);
    }
}

#pragma mark -

- (UIWindowLevel)showPopoverWindowLevel {
    return MAX(UIWindowLevelStatusBar, [super showPopoverWindowLevel]);
}

- (BOOL)customAnimationForPopoverView:(MyPopoverView *)popoverView
                                 show:(BOOL)show
                       animationBlock:(void (^)(void))animationBlock
                       completedBlock:(void (^)(void))completedBlock
{
    
    [self defaultPushCustomAnimationForPopoverView:popoverView
                                         direction:MyMoveAnimatedDirectionDown
                                              show:show
                                    animationBlock:animationBlock
                                    completedBlock:completedBlock];
    return YES;
}


@end
