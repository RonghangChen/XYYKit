//
//  MyContentView.m
//  
//
//  Created by LeslieChen on 15/12/16.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "MyContentView.h"

@implementation MyContentView
{
    BOOL _needUpdateViewWhenMovetToWindow;
}

- (void)setNeedUpdateView
{
    if (self.window) {
        [self updateView];
    }else {
        _needUpdateViewWhenMovetToWindow = YES;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self updateViewIfNeeded];
    }
}

- (BOOL)updateViewIfNeeded
{
    if (_needUpdateViewWhenMovetToWindow) {
        _needUpdateViewWhenMovetToWindow = NO;
        [self updateView];
        return YES;
    }
    
    return NO;
}

- (void)updateView {
    //do nothing
}


@end
