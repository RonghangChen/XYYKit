//
//  UIView+IntervalAnimation.h
//  
//
//  Created by LeslieChen on 15/3/10.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+IntervalAnimation.h"

@interface UIView (IntervalAnimation)

@property(nonatomic) BOOL onlyAnimatedSelf;

- (NSArray *)needAnimatedViewsForShow:(BOOL)show context:(id)context;
- (NSArray *)needAnimatedViewsWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                                    forShow:(BOOL)show
                                    context:(id)context;

@end
