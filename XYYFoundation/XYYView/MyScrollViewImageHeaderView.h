//
//  MyTableviewImageHeaderView.h
//  
//
//  Created by LeslieChen on 15/11/25.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyContentView.h"

@interface MyScrollViewImageHeaderView : MyContentView

- (id)initWithFrame:(CGRect)frame completedShowHeight:(CGFloat)completedShowHeight;

//初始显示的高度
@property(nonatomic) CGFloat originShowHeight;
//完成显示订单高度
@property(nonatomic) CGFloat completedShowHeight;


//偏移因子，滑动时用于构建视差效果的偏移因子,大小在0-1之间，默认为0.5f
@property(nonatomic,readonly) CGFloat offsetFactor;
//隐藏时用于构建视差效果的偏移因子,大小在0-1之间，默认为0.3f
@property(nonatomic,readonly) CGFloat hideOffsetFactor;

//滑动视图滑动
- (void)scrollViewDidScroll:(CGPoint)contentOffset;

//背景图像视图相关
@property(nonatomic,strong,readonly) UIImageView * imageView;
@property(nonatomic,strong) UIImage * image;
- (void)setImage:(UIImage *)image animated:(BOOL)animated;


@end
