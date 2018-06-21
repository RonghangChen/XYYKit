//
//  MyScoreBarView.h
//
//
//  Created by LeslieChen on 14/12/10.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

//绘制分数的路径block
typedef void (^MyDrawScorePathBlock)(CGMutablePathRef path,CGRect rect);

//----------------------------------------------------------

@interface MyScoreBarView : UIControl

- (id)initWithMaxValue:(NSUInteger)maxValue;
- (id)initWithMaxValue:(NSUInteger)maxValue
       scoreTrackImage:(UIImage *)scoreTrackImage
            scoreImage:(UIImage *)scoreImage;

//分数图片，默认为nil，即使用drawScorePathBlock绘制或改变scoreTrackImage图片颜色，这取决于scoreTrackImage是否为nil
@property(nonatomic,strong) UIImage * scoreImage;
//分数轨迹图片,默认为nil,即使用drawScorePathBlock绘制
@property(nonatomic,strong) UIImage * scoreTrackImage;

//分数轨迹的颜色，默认为灰色 lightGrayColor
@property(nonatomic,strong) UIColor * scoreTrackColor;
//分数颜色，默认为黄色 #F4821B
@property(nonatomic,strong) UIColor * scoreColor;

//分数绘制快，默认未nil，使用默认的五角星
@property(nonatomic,copy) MyDrawScorePathBlock drawScorePathBlock;

//分数之间的最小间隔，默认为5.f
@property(nonatomic) CGFloat minMargin;

//当前分数值
@property(nonatomic) CGFloat value;
//最大分数 default 5.0
@property(nonatomic) NSUInteger maxValue;

//分数的最小改变值，默认为1.f
@property(nonatomic) CGFloat stepValueInternal;
//当该值为YES时，分数发生改变即发送事件，否则需等到用户交互结束后才发送最后结果，默认为No
@property(nonatomic) BOOL continuous;

//是否还在拖拽
@property(nonatomic,readonly,getter = isDragging) BOOL dragging;

@end
