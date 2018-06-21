//
//  MyPushPopAnimatedTransitioning.h
//
//
//  Created by LeslieChen on 14-4-1.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicViewControllerAnimatedTransitioning.h"

//----------------------------------------------------------

#define PushPopAnimatedTypeLeft     0x0001
#define PushPopAnimatedTypeRight    0x0010
#define PushPopAnimatedTypePush     0x0100
#define PushPopAnimatedTypePop      0x1000

typedef NS_ENUM(NSUInteger, PushPopAnimatedType) {
    PushPopAnimatedTypeLeftPush  = PushPopAnimatedTypeLeft  | PushPopAnimatedTypePush,
    PushPopAnimatedTypeLeftPop   = PushPopAnimatedTypeLeft  | PushPopAnimatedTypePop,
    PushPopAnimatedTypeRightPush = PushPopAnimatedTypeRight | PushPopAnimatedTypePush,
    PushPopAnimatedTypeRightPop  = PushPopAnimatedTypeRight | PushPopAnimatedTypePop,
    
    PushPopAnimatedTypeNavigationPop  = PushPopAnimatedTypeRightPop,
    PushPopAnimatedTypeNavigationPush = PushPopAnimatedTypeLeftPush
};

//----------------------------------------------------------

@interface MyPushPopAnimatedTransitioning : MyBasicViewControllerAnimatedTransitioning

- (id)initWithType:(PushPopAnimatedType)type;
- (id)initWithType:(PushPopAnimatedType)type animations:(void(^)(void))animations;

//类型
@property(nonatomic,readonly) PushPopAnimatedType type;


@end
