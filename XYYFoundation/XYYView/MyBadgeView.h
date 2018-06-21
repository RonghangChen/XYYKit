//
//  MyBadgeView.h
//
//
//  Created by LeslieChen on 14/11/10.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class MyBadgeView;

//----------------------------------------------------------

@protocol MyBadgeViewDelegate <NSObject>

@optional

//是否需要点击消失，默认为YES
- (BOOL)badgeViewShouldTapDisappear:(MyBadgeView *)badgeView;

//已经点击消失
- (void)badgeViewDidTapDisappear:(MyBadgeView *)badgeView;

@end

//----------------------------------------------------------

@interface MyBadgeView : UIView

//是否显示标签,默认为NO
@property(nonatomic) BOOL showBadge;
//是否显示badge
- (void)setShowBadge:(BOOL)showBadge
            animated:(BOOL)animated
      completedBlock:(void(^)(void))completedBlock;

//标签的值
@property(nonatomic,strong) NSString * badgeValue;

//标记背景颜色，默认为红色
@property(nonatomic,strong) UIColor * badgeBGColor;

//标记值的颜色，默认白色
@property(nonatomic,strong) UIColor * badgeColor;

//字体，默认为10号系统字体
@property(nonatomic,strong) UIFont * badgeFont;

//最小的标记半径，默认为5.f
@property(nonatomic) CGFloat minBadgeRadius;

//最大显示的标签字符长度，默认为NSUIntegerMax
@property(nonatomic) NSUInteger maxBadgeCharLength;

//标记的锚点，默认是（0.5，0.5）右上角
@property(nonatomic) CGPoint badgeAnchorPoint;
//定位的锚点，默认是（1.f，0）右上角
@property(nonatomic) CGPoint locationAnchorPoint;
//定位的偏移，默认是（0，0）
@property(nonatomic) CGPoint locationOffset;


//振动
- (void)vibrate;
- (void)vibrateWithDuration:(NSTimeInterval)duration;

//是否可以点击消失,默认为NO
@property(nonatomic) BOOL canTapDisappear;

//点击消失区域的扩大的inset
@property(nonatomic) UIEdgeInsets tapDisappearInsets;


@property(nonatomic,weak) id<MyBadgeViewDelegate> delegate;


@end

//----------------------------------------------------------

@interface UIView (MyBadgeView)

//返回自身或第一个子视图
@property(nonatomic,strong,readonly) MyBadgeView * badgeView;

- (void)vibrateBadgeView;
- (void)vibrateBadgeViewWithDuration:(NSTimeInterval)duration;

@end
