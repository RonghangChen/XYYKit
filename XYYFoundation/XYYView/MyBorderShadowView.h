//
//  MyBorderShadowView.h
//  leslie
//
//  Created by 陈荣航 on 2017/3/28.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "MyBorderView.h"

@interface MyBorderShadowView : MyBorderView

//阴影颜色
@property(nonatomic,strong) IBInspectable UIColor * shadowColor;
//阴影透明度
@property(nonatomic) IBInspectable CGFloat shadowOpacity;
//阴影偏移
@property(nonatomic) IBInspectable CGSize shadowOffset;
//阴影半径
@property(nonatomic) IBInspectable CGFloat shadowRadius;

//是否显示阴影，默认为NO
@property(nonatomic) IBInspectable BOOL showShadow;
//阴影边角半径
@property(nonatomic) IBInspectable CGFloat shadowBorderRadius;
//阴影缩进
@property(nonatomic) UIEdgeInsets shadowBorderInset;
//阴影偏移
@property(nonatomic) IBInspectable CGPoint shadowBorderOffset;


@end
