//
//  MyBlurredView.h
//  
//
//  Created by LeslieChen on 15/3/12.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyBlurredBackgroundProtocol.h"

@interface MyBlurredView : UIView <MyBlurredBackgroundProtocol>

//动态毛玻璃时有效
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@property(nonatomic,strong,readonly) UIView * blurredContentView;
#endif

//更新，当改变变量和状态后需要调用此函数更新
- (void)updateBlurred;
//更新，当改变变量和状态后需要调用此函数更新,window为静态毛玻璃的参照window，传入nil则使用self.window获取
- (void)updateBlurredWithWindow:(UIWindow *)window;
//清除毛玻璃效果
- (void)clearBlurred;

@end
