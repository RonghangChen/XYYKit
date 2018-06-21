//
//  MyBoderProtocol.h

//
//  Created by LeslieChen on 15/2/28.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyLineLayer.h"

//----------------------------------------------------------

//边界掩码
typedef NS_OPTIONS(NSUInteger,MyBorderMask) {
    MyBorderNone   = 0,
    MyBorderTop    = 1,
    MyBorderBottom = 1 << 1,
    MyBorderLeft   = 1 << 2,
    MyBorderRight  = 1 << 3,
    MyBorderAll    = ~0UL
};

//----------------------------------------------------------

@protocol MyBorderProtocol

//边界风格
@property(nonatomic) MyLineStyle borderStyle;
//边界掩码
@property(nonatomic) MyBorderMask borderMask;

//边界宽度
@property(nonatomic) CGFloat  borderWidth;
//边界颜色
@property(nonatomic,strong) UIColor * borderColor;

//边界缩进
@property(nonatomic) UIEdgeInsets borderInset;
@property(nonatomic) UIEdgeInsets borderLineInset;
@property(nonatomic) UIEdgeInsets borderLineScaleInset;

@end
