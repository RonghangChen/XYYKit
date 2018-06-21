//
//  MyMaskView.h

//
//  Created by LeslieChen on 15/1/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class MyMaskView;

//----------------------------------------------------------

@protocol MyMaskViewDataSource

@optional

//返回用于蒙版的layer，优先级高于下面的路径
- (CALayer *)maskLayerForMaskView:(MyMaskView *)maskView;
//返回用于蒙版的路径
- (UIBezierPath *)maskPathForMaskView:(MyMaskView *)maskView;

@end

//----------------------------------------------------------

typedef CALayer * (^GetMaskLayerBlock)(MyMaskView * maskView);
typedef UIBezierPath * (^GetMaskPathBlock)(MyMaskView * maskView);

//----------------------------------------------------------

@interface MyMaskView : UIView

//是否重新加载蒙版当视图大小改变时，默认为YES
@property(nonatomic) BOOL reloadMaskWhenSizeChange;

@property(nonatomic,weak) id<MyMaskViewDataSource> dataSource;

//获取的block，如果无数据源或者数据源没实现则调用下面两个block获取
@property(nonatomic,copy) GetMaskLayerBlock maskLayerBlock;
@property(nonatomic,copy) GetMaskPathBlock  maskPathBlock;

//重新加载
- (void)reloadMask;

@end

//----------------------------------------------------------

@interface UIView (MyMaskView)

@property(nonatomic,strong,readonly) MyMaskView * myMaskView;

@end

