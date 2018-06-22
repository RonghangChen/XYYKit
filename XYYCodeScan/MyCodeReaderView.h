//
//  MyCodeReaderView.h
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyCodeTypeDef.h"
#import <AVFoundation/AVFoundation.h>

//----------------------------------------------------------

@protocol MyCodeScanActivityViewProtocol;

//----------------------------------------------------------

@class MyCodeReaderView;

@protocol MyCodeReaderViewDelegate <NSObject>

@optional

//----------------------------------------------------------


//开始运行
- (void)codeReaderViewDidStartRuning:(MyCodeReaderView *)codeReaderView;
//开始运行失败
- (void)codeReaderView:(MyCodeReaderView *)codeReaderView didFailureStartRuningWithError:(NSError *)error;

//扫描成功
- (void)codeReaderView:(MyCodeReaderView *)codeReaderView didReadCodeDatas:(NSArray<NSString *> *)codeDatas;

//被打断
- (void)codeReaderViewWasInterrupted:(MyCodeReaderView *)codeReaderView;
//打断结束
- (void)codeReaderViewInterruptionEnded:(MyCodeReaderView *)codeReaderView;

//停止运行
- (void)codeReaderViewDidStopRunning:(MyCodeReaderView *)codeReaderView;


@end

//----------------------------------------------------------


@interface MyCodeReaderView : UIView

//摄像头是否可获取
+ (BOOL)isCameraCaptureSourceAvailable;
//是否有闪光灯
+ (BOOL)isTorchAvailable;
//获取授权状态
+ (AVAuthorizationStatus)authorizationStatusForCameraCaptureSource;
//请求授权
+ (void)requestAccessForCameraCaptureSourceWithcompletionHandler:(void (^)(BOOL granted))handler;

//
- (id)initWithCodeType:(MyCodeType)codeType;
//
- (id)initWithCodeType:(MyCodeType)codeType scanActivityViewClass:(Class)scanActivityViewClass;

//类型
@property(nonatomic,readonly) MyCodeType codeType;

//准备开始
- (BOOL)prepareStart;
//开始
- (BOOL)start;
//停止
- (void)stop;

//是否在运行
@property(nonatomic, readonly, getter=isRunning) BOOL running;
//是否被打断
@property(nonatomic, readonly, getter=isInterrupted) BOOL interrupted;


//是否可以手势缩放,默认为yes
@property (nonatomic) BOOL allowsPinchZoom;
//缩放比例，最小为1.f,默认为1.f
@property(nonatomic) CGFloat zoomScale;
- (void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated;

//是否基于扫码图片自动缩放,默认为YES
@property (nonatomic) BOOL autoZoomScale;

//闪光灯类型，默认为AVCaptureTorchModeOff,KVO观察
@property (nonatomic) AVCaptureTorchMode torchMode;


//代理
@property(nonatomic,weak) id<MyCodeReaderViewDelegate> delegate;

//显示扫描活动视图，默认为NO
@property(nonatomic) BOOL showScanActivityView;
//当showScanActivityView为YES时显示
@property(nonatomic,strong,readonly) UIView<MyCodeScanActivityViewProtocol> * scanActivityView;

//扫码区域，基于比例值
@property (nonatomic) CGRect scanCrop;
//自动调整扫描框，默认为YES
@property(nonatomic) BOOL autoAdjustScanCrop;
//扫描内容的缩进量，默认为
@property(nonatomic) UIEdgeInsets scanContentInsets;

@end
