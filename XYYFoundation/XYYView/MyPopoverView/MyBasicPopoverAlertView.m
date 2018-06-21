//
//  MyBasicPopoverAlertView.m
//  leslie
//
//  Created by 陈荣航 on 2017/11/10.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "MyBasicPopoverAlertView.h"
#import "XYYConst.h"

@implementation MyBasicPopoverAlertView

- (MyPopoverView *)showWithConfigBlock:(void(^)(MyPopoverView * popoverView))configBlock
                               animated:(BOOL)animated
                        completedBlock:(void(^)(void))completedBlock
{
    return [self showInView:nil
            withConfigBlock:configBlock
                   animated:animated
             completedBlock:completedBlock];
}

- (MyPopoverView *)showInView:(UIView *)view
              withConfigBlock:(void(^)(MyPopoverView * popoverView))configBlock
                     animated:(BOOL)animated
               completedBlock:(void(^)(void))completedBlock
{
    if (self.popoverView) {
        return nil;
    }
    
    MyPopoverView * popoverView = [[MyPopoverView alloc] initWithContentView:self];
    popoverView.backgroundColor = BlackColorWithAlpha(0.5f);
    popoverView.locationAnchorPoint = CGPointMake(0.5f, 0.5f);
    
    //自定义配置
    if (configBlock) {
        configBlock(popoverView);
    }
    
    [popoverView showInView:view animated:animated completedBlock:completedBlock];
    
    return popoverView;
}

- (void)hideWithAnimted:(BOOL)animated completedBlock:(void(^)(void))completedBlock {
    [self.popoverView hide:animated completedBlock:completedBlock];
}

#pragma mark -

- (UIWindowLevel)showPopoverWindowLevel {
    return MAX(UIWindowLevelAlert, [super showPopoverWindowLevel]);
}

- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point {
    return NO;
}

- (void)startPopoverViewShow:(BOOL)show animated:(BOOL)animated
{
    if (animated) {
        
        if (show) {
            self.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
        }
        
        [UIView animateWithDuration:show ? 0.6 : 0.5
                              delay:0.0
             usingSpringWithDamping:show ? 0.5f : 1.1f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.transform = show ? CGAffineTransformIdentity :  CGAffineTransformMakeScale(0.01f, 0.01f);
                         } completion:nil];
    }
}

@end
