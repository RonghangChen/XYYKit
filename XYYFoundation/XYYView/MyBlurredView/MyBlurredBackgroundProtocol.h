//
//  MyBlurredBackgroundP.h
//  
//
//  Created by LeslieChen on 15/3/12.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#ifndef __MyBlurredBackgroundProtocol_h
#define __MyBlurredBackgroundProtocol_h

//----------------------------------------------------------

typedef NS_ENUM(NSInteger,MyBlurredBackgroundType) {
    MyBlurredBackgroundTypeNone,    //无
    MyBlurredBackgroundTypeStatic   //静态
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    ,MyBlurredBackgroundTypeDynamic  //动态
#endif
    
};

//----------------------------------------------------------

typedef UIImage *(^MyApplyBlurredEffectBlock)(UIImage *image);

//----------------------------------------------------------

@protocol MyBlurredBackgroundProtocol

//毛玻璃背景类型
@property(nonatomic) MyBlurredBackgroundType blurredBackgroundType;
//添加毛玻璃效果的block,对于静态毛玻璃效果有效
@property(nonatomic,copy) MyApplyBlurredEffectBlock applyBlurredEffectBlock;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

//对于动态毛玻璃有效
@property(nonatomic) UIBlurEffectStyle blurEffectStyle;
//毛玻璃透明度
@property(nonatomic) CGFloat blurEffectAlpha;

#endif


@end


#endif
