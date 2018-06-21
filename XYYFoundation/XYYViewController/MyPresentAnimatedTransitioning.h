//
//  MyDimissAnimatedTransitioning.h
//  5idj
//
//  Created by LeslieChen on 14/10/23.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicViewControllerAnimatedTransitioning.h"

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyPresentAnimatedTransitioningType) {
    MyPresentAnimatedTransitioningTypePresent,
    MyPresentAnimatedTransitioningTypeDismiss
};

//----------------------------------------------------------

@interface MyPresentAnimatedTransitioning : MyBasicViewControllerAnimatedTransitioning

- (id)initWithType:(MyPresentAnimatedTransitioningType)type;
- (id)initWithType:(MyPresentAnimatedTransitioningType)type animations:(void(^)(void))animations;

//类型
@property(nonatomic,readonly) MyPresentAnimatedTransitioningType type;

@end
