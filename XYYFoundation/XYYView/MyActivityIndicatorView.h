//
//  MyActivityIndicatorView.h
//
//
//  Created by LeslieChen on 14-7-25.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//#warning 有时间修改为基于定时器的动画

//----------------------------------------------------------

@protocol  MyActivityIndicatorViewProtocol

/**
 * 是否在停止动作时隐藏，默认为YES
 */
@property(nonatomic) BOOL hidesWhenStopped;

- (void)startAnimating;
- (void)stopAnimating;

- (BOOL)isAnimating;

@end

//----------------------------------------------------------


typedef NS_ENUM(int, MyActivityIndicatorViewStyle) {
    MyActivityIndicatorViewStyleIndeterminate,
    MyActivityIndicatorViewStyleDeterminate
};

//----------------------------------------------------------

@interface MyActivityIndicatorView : UIView <MyActivityIndicatorViewProtocol>

- (id)initWithStyle:(MyActivityIndicatorViewStyle)style;

/**
 * 风格，默认为MyActivityIndicatorViewStyleIndeterminate
 */
@property(nonatomic) MyActivityIndicatorViewStyle style;


/**
 * 线的宽度，默认为1
 */
@property(nonatomic) CGFloat     lineWidth;

/**
 * 内容的缩进，默认为UIEdgeInsetsZero
 */
@property(nonatomic) UIEdgeInsets contentInset;


/**
 * 是否是顺时针方向旋转，默认为YES
 */
@property(nonatomic) BOOL       clockwise;

/**
 * 开始动画时是否分为两步，默认为NO
 */
@property(nonatomic) BOOL       twoStepAnimation;

/**
 * 开始的角度，默认为0
 */
@property(nonatomic) CGFloat   startAngle;


/**
 * MyActivityIndicatorViewStyleIndeterminate风格时的进度默认为0.9f
 */
@property(nonatomic) float      indeterminateProgress;

/**
 * 进度，取值在0.f - 1.f
 * 对于MyActivityIndicatorViewStyleIndeterminate风格进度恒为indeterminateProgress，且更改此值会被忽略
 */
@property(nonatomic) float  progress;

@end
