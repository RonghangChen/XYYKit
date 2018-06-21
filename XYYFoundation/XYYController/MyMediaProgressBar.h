//
//  MyMediaProgressBar.h
//
//
//  Created by LeslieChen on 14-2-26.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@interface MyMediaProgressBar : UIControl

//当前进度值，默认为0
@property(nonatomic) float value;

//加载进度的值，默认为0
@property(nonatomic) float loadedValue;

//最小取值，默认为0
@property(nonatomic) float minValue;

//最大取值，默认为0
@property(nonatomic) float maxValue;

//移动的最小改变量，默认为0，即任意小
@property(nonatomic) float stepValueInternal;

//当该值为YES，则进度发生改变即发送事件，否则需等到用户结束互动才发送最后结果，默认为YES
@property(nonatomic) BOOL continuous;

//是否还在拖拽
@property(nonatomic,readonly,getter = isDragging) BOOL dragging;

//轨迹背景颜色，默认为黑灰色
@property(nonatomic,strong) UIColor * trackBGColor;

//播放进度轨迹颜色，默认为白色
@property(nonatomic,strong) UIColor * glowTrackColor;

//加载进度的轨迹，默认为浅灰色
@property(nonatomic,strong) UIColor * loadedTrackColor;

//进度拖动按钮的图片,正常状态下，默认为nil
@property(nonatomic,strong) UIImage * thumbImageNormal;

//进度拖动按钮的图片,被选择状态下，默认为nil
@property(nonatomic,strong) UIImage * thumbImageHighlighted;

//按钮颜色,默认为白色
@property(nonatomic,strong) UIColor * thumbColor;
//按钮点击后阴影颜色，默认为白色
@property(nonatomic,strong) UIColor * thumbShadowColor;

//设置相关值
- (void)setValue:(float)value animated:(BOOL)animated;
- (void)setLoadedValue:(float)loadedValue animated:(BOOL)animated;

//获取值所对应点在Bar中的坐标
- (CGPoint)pointInBarForValue:(CGFloat)value;

//按钮的中心点
- (CGPoint)centerPointForThumb;

@end
