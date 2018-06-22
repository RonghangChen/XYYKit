//
//  MyCodeScanActivityView.h
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyCodeTypeDef.h"

//----------------------------------------------------------

@protocol MyCodeScanActivityViewProtocol <NSObject>

- (id)initWithCodeType:(MyCodeType)codeType;

//类型
@property(nonatomic,readonly) MyCodeType codeType;

// start the video stream and barcode reader.
- (void) start;

// stop the video stream and barcode reader.
- (void) stop;

//扫描范围
@property (nonatomic) CGRect scanCrop;

@end

//----------------------------------------------------------

@interface MyCodeScanActivityView : UIView <MyCodeScanActivityViewProtocol>

//一次动画时长，默认为2.f
@property(nonatomic) NSTimeInterval animationDuration;

//色调，默认为tintcolor
@property(nonatomic,strong) UIColor * scanCropBoundsTintColor;

//非扫描区遮罩颜色，默认为60%透明度的黑色
@property(nonatomic,strong) UIColor * maskColor;

@end
