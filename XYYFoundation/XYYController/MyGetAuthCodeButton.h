//
//  MyGetAuthCodeButton.h
//  
//
//  Created by LeslieChen on 15/3/13.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyButton.h"

//----------------------------------------------------------

@class MyGetAuthCodeButton;

//----------------------------------------------------------

@protocol MyGetAuthCodeButtonDelegate <NSObject>

@optional

//点击了获取
- (void)getAuthCodeButtonDidTapGet:(MyGetAuthCodeButton *)getAuthCodeButton;
//开始等待
- (void)getAuthCodeButtonStartWait:(MyGetAuthCodeButton *)getAuthCodeButton;
//更新等待时间
- (void)getAuthCodeButton:(MyGetAuthCodeButton *)getAuthCodeButton
         needWaittingTime:(NSUInteger)needWaittingTime;
//完成等待
- (void)getAuthCodeButtonEndWait:(MyGetAuthCodeButton *)getAuthCodeButton;

@end

//----------------------------------------------------------

//获取验证码的按钮
@interface MyGetAuthCodeButton : MyButton

//获取成功，正在等待下一次获取
@property(nonatomic,readonly,getter=isWattingNextGetAuthCode) BOOL wattingNextGetAuthCode;

//需要等待的时间，默认为60秒
@property(nonatomic) NSUInteger totalNeedWattingTime;
//需要等待的时间
@property(nonatomic,readonly) NSUInteger needWattingTime;

//等待时长的文本属性，默认为nil
@property(nonatomic,strong) NSDictionary * wattingTimeTextAttributed;

//获取验证码成功，调用此函数后将开始等待时间
- (void)getAuthCodeSucceed;
//停止等待
- (void)stopWatting;


//代理
@property(nonatomic,weak) id<MyGetAuthCodeButtonDelegate> delegate;

@end
