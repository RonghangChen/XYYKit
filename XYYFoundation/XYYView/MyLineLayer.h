//
//  MyLineLayer.h

//
//  Created by LeslieChen on 15/2/28.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

//线的风格
typedef NS_ENUM(NSInteger, MyLineStyle) {
    MyLineStyleNormal,
    MyLineStyleGradient
};


@interface MyLineLayer : CALayer

@property(nonatomic) MyLineStyle lineStyle;

@property(nonatomic) CGFloat lineWidth;
@property(nonatomic,strong) UIColor * lineColor;

@property(nonatomic) CGPoint startPoint,endPoint;

//默认都为0.5f
@property(nonatomic) CGFloat gradientStartLocation,gradientEndLocation;

@end
