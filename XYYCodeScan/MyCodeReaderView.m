
//
//  MyCodeReaderView.m
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyCodeReaderView.h"
#import "MyCodeScanController.h"
#import "MyCodeScanActivityView.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

static inline CGRect _appendCenterRect(CGRect rect, CGPoint center)
{
    CGFloat halfWidth = MAX(ABS(CGRectGetMinX(rect) - center.x),ABS(CGRectGetMaxX(rect) - center.x));
    CGFloat halfHeight = MAX(ABS(CGRectGetMinY(rect) - center.y),ABS(CGRectGetMaxY(rect) - center.y));
    
    return CGRectMake(center.x - halfWidth, center.y - halfHeight, 2 * halfWidth, 2 * halfHeight);
}

//----------------------------------------------------------

@interface MyCodeReaderView() <AVCaptureMetadataOutputObjectsDelegate,
                               UIGestureRecognizerDelegate>

//设备和任务
@property(nonatomic,strong) AVCaptureDevice * device;
@property(nonatomic,strong) AVCaptureMetadataOutput * output;
@property(nonatomic,strong) AVCaptureSession * session;

//预览layer
@property(nonatomic,strong) AVCaptureVideoPreviewLayer * previewLayer;

//缩放手势
@property(nonatomic,strong) UIPinchGestureRecognizer * pinchGestureRecognizer;

//扫描活动视图类，默认为nil
@property(nonatomic,strong) Class scanActivityViewClass;

@end

//----------------------------------------------------------

@implementation MyCodeReaderView

@synthesize scanActivityView = _scanActivityView;

#pragma mark -

+ (BOOL)isCameraCaptureSourceAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL)isTorchAvailable {
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
}

+ (AVAuthorizationStatus)authorizationStatusForCameraCaptureSource {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (void)requestAccessForCameraCaptureSourceWithcompletionHandler:(void (^)(BOOL granted))handler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:handler];
}

#pragma mark -

- (id)initWithCodeType:(MyCodeType)codeType {
    return [self initWithCodeType:codeType scanActivityViewClass:nil];
}

- (id)initWithCodeType:(MyCodeType)codeType scanActivityViewClass:(Class)scanActivityViewClass
{
    if (scanActivityViewClass && (![scanActivityViewClass isSubclassOfClass:[UIView class]] || ![scanActivityViewClass conformsToProtocol:@protocol(MyCodeScanActivityViewProtocol)])) {
        
        @throw  [NSException exceptionWithName:NSInvalidArgumentException
                                        reason:@"scanActivityViewClass必须为UIView子类且遵循MyCodeScanActivityViewProtocol协议"
                                      userInfo:nil];
    }
    
    
    self = [super init];
    
    if (self) {
        _codeType = codeType;
        _scanActivityViewClass = scanActivityViewClass;
        [self _setup_MyCodeReaderView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _setup_MyCodeReaderView];
}

- (void)_setup_MyCodeReaderView
{
    _zoomScale = 1.f;
    _autoAdjustScanCrop = YES;
    _autoZoomScale = YES;
    self.allowsPinchZoom = YES;
}

- (void)dealloc
{
    //移除通知
    if (self.device) {
        [self.device removeObserver:self forKeyPath:@"torchMode"];
        [self.device removeObserver:self forKeyPath:@"videoZoomFactor"];
    }
    
    if (self.session) {
        [self.session stopRunning];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark -

- (void)setShowScanActivityView:(BOOL)showScanActivityView
{
    if (_showScanActivityView != showScanActivityView) {
        
        if (_showScanActivityView) {
            self.scanActivityView.hidden = YES;
            [self.scanActivityView stop];
        }
        
        _showScanActivityView = showScanActivityView;
        
        if (_showScanActivityView) {
            self.scanActivityView.hidden = NO;
            if (self.isRunning) {
                [self.scanActivityView start];
            }
        }
    }
}

- (UIView<MyCodeScanActivityViewProtocol> *)scanActivityView
{
    if (!_scanActivityView) {
        _scanActivityView = [[self.scanActivityViewClass ?: [MyCodeScanActivityView class] alloc] initWithCodeType:self.codeType];
        _scanActivityView.scanCrop = self.scanCrop;
        _scanActivityView.frame = self.bounds;
        _scanActivityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scanActivityView.userInteractionEnabled = NO;
        [self addSubview:_scanActivityView];
    }
    
    return _scanActivityView;
}

#pragma mark -

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    if (self.device) {
        
        if(![self.device isTorchModeSupported:torchMode]) {
            torchMode = AVCaptureTorchModeOff;
        }else {
            torchMode = torchMode;
        }
        
        if (self.device.torchMode != torchMode &&
            [self.device lockForConfiguration:NULL]) {
            
            //设置设备手电筒状态
            self.device.torchMode = torchMode;
            [self.device unlockForConfiguration];
            
        }else {
            [self _setTorchMode:self.device.torchMode];
        }
        
    }else {
        [self _setTorchMode:torchMode];
    }
}

- (void)_setTorchMode:(AVCaptureTorchMode)torchMode
{
    if (_torchMode == torchMode) {
        return;
    }
    
    [self willChangeValueForKey:@"torchMode"];
    _torchMode = torchMode;
    [self didChangeValueForKey:@"torchMode"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.device) {
        
        //回调到主线程
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            });
            return;
        }
        
        if([keyPath isEqualToString:@"torchMode"]) {
            [self _setTorchMode:self.device.torchMode];
        }else if([keyPath isEqualToString:@"videoZoomFactor"]) {
            [self _setZoomScale:self.device.videoZoomFactor];
        }
    }
}

#pragma mark -

- (void)setAllowsPinchZoom:(BOOL)allowsPinchZoom
{
    if (_allowsPinchZoom != allowsPinchZoom) {
        _allowsPinchZoom = allowsPinchZoom;
        
        if (allowsPinchZoom) {
            
            if (self.pinchGestureRecognizer == nil) {
                self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_pinchGestureRecognizerHandle:)];
                self.pinchGestureRecognizer.delegate = self;
            }
            [self addGestureRecognizer:self.pinchGestureRecognizer];
            
        }else if(self.pinchGestureRecognizer) {
            [self removeGestureRecognizer:self.pinchGestureRecognizer];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.pinchGestureRecognizer) {
        return self.isRunning;
    }
    
    return YES;
}

- (void)_pinchGestureRecognizerHandle:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.zoomScale *= gestureRecognizer.scale;
    }
    gestureRecognizer.scale = 1.f;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    [self setZoomScale:zoomScale animated:NO];
}

- (void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated
{
    zoomScale = MAX(1.f, zoomScale);
    if (self.device) {
        
        zoomScale = MIN(zoomScale, [self.device.activeFormat videoMaxZoomFactor]);
        
        if (self.device.videoZoomFactor != zoomScale &&
            [self.device lockForConfiguration:NULL]) {
            
            if (animated) {
                [self.device rampToVideoZoomFactor:zoomScale withRate:5.f];
            }else {
                
                //取消动画
                if (self.device.rampingVideoZoom) {
                    [self.device cancelVideoZoomRamp];
                }
                
                //直接设置
                self.device.videoZoomFactor = zoomScale;
            }
            
            [self.device unlockForConfiguration];
        }else {
            [self _setZoomScale:self.device.videoZoomFactor];
        }
        
    }else {
        [self _setZoomScale:zoomScale];
    }
}

- (void)_setZoomScale:(CGFloat)zoomScale
{
    if (_zoomScale == zoomScale) {
        return;
    }
    
    [self willChangeValueForKey:@"zoomScale"];
    _zoomScale = zoomScale;
    [self didChangeValueForKey:@"zoomScale"];
}

#pragma mark -

- (void)setAutoAdjustScanCrop:(BOOL)autoAdjustScanCrop
{
    if(_autoAdjustScanCrop != autoAdjustScanCrop){
        _autoAdjustScanCrop = autoAdjustScanCrop;
        if (_autoAdjustScanCrop) {
            [self setNeedsLayout];
        }
    }
}

- (void)setScanContentInsets:(UIEdgeInsets)scanContentInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(scanContentInsets, _scanContentInsets)) {
        _scanContentInsets = scanContentInsets;
        if (self.autoAdjustScanCrop) {
            [self setNeedsLayout];
        }
    }
}

- (void)setScanCrop:(CGRect)scanCrop
{
    if (!self.autoAdjustScanCrop) {
        [self _updateScanCrop:scanCrop];
    }
}

- (void)_updateScanCrop:(CGRect)scanCrop
{
    if (CGRectEqualToRect(_scanCrop,scanCrop)) {
        return;
    }
    
    _scanCrop = scanCrop;
    _scanActivityView.scanCrop = self.scanCrop;
    
    //更新扫描区域
    [self _updateRectOfInterest];
}

- (void)_updateRectOfInterest
{
    if (!self.session.isRunning) {
        return;
    }
    
    //计算实际大小
    CGRect scanCroprect = CGRectMake(self.scanCrop.origin.x * self.width,
                                     self.scanCrop.origin.y * self.height,
                                     self.scanCrop.size.width * self.width,
                                     self.scanCrop.size.height * self.height);
    
//    //转换到预览视图
//    scanCroprect = [self.layer convertRect:scanCroprect toLayer:self.previewLayer];
//
    //转换到输出端
    self.output.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:scanCroprect];
    
    //更新焦点
    [self _updateFocusPosition:CenterForRect(self.output.rectOfInterest)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //更新预览视图大小
    self.previewLayer.frame = self.bounds;
    
    //调整扫码区域
    if (self.autoAdjustScanCrop) {
        
        CGRect scanContentRect = UIEdgeInsetsInsetRect(self.bounds,self.scanContentInsets);
        
        CGFloat scanContentWidth = CGRectGetWidth(scanContentRect);
        CGFloat scanContentHeight = CGRectGetHeight(scanContentRect);
        CGFloat scanCropSize = MIN(scanContentHeight, scanContentWidth) * 0.75f;
        
        CGRect scanCropBounds = CGRectMake(CGRectGetMinX(scanContentRect) + (scanContentWidth - scanCropSize) * 0.5f, CGRectGetMinY(scanContentRect) + (CGRectGetHeight(scanContentRect) - scanCropSize) * 0.5f, scanCropSize, scanCropSize);
        
        [self _updateScanCrop:ContentsRectForRect(scanCropBounds, self.bounds)];
    }

}

#pragma mark -

- (void)_updateFocusPosition:(CGPoint)point
{
    if (!self.device.focusPointOfInterestSupported) {
        return;
    }
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeLocked;
    if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }else if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        focusMode = AVCaptureFocusModeAutoFocus;
    }
    
    if ([self.device lockForConfiguration:NULL]) {
        self.device.focusPointOfInterest = point;
        if ([self.device isFocusModeSupported:focusMode]) {
            self.device.focusMode = focusMode;
        }
        [self.device unlockForConfiguration];
    }
}


#pragma mark -

- (BOOL)prepareStart
{
    if (self.session == nil) {
        
        //初始化设备
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (self.device == nil) {
            goto fail;
        }

        //输入
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:NULL];
        if (input == nil) {
            goto fail;
        }
        
        //输出
        self.output = [[AVCaptureMetadataOutput alloc] init];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //创建任务
        self.session = [[AVCaptureSession alloc] init];
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        //添加输入
        if ([self.session canAddInput:input]) {
            [self.session addInput:input];
        }else {
            goto fail;
        }
        
        //添加输出
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
            //输出的元数据类型
            self.output.metadataObjectTypes = @[metadataObjectTypeForCodeType(self.codeType)];
        }else {
            goto fail;
        }
        
        //生成预览视图
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.bounds;
        [self.layer insertSublayer:self.previewLayer atIndex:0];
        
        //观察key
        [self.device addObserver:self forKeyPath:@"torchMode" options:NSKeyValueObservingOptionNew context:nil];
        [self.device addObserver:self forKeyPath:@"videoZoomFactor" options:NSKeyValueObservingOptionNew context:nil];
        
        //更新闪光灯状态
        self.torchMode = self.torchMode;
        //更新缩放比例
        self.zoomScale = self.zoomScale;
        
        //添加通知
        [self _addNotification];
    }
    
    return self.session != nil;
    
    
fail:
    self.session = nil;
    self.device = nil;
    self.output = nil;
    return NO;
}

- (BOOL)start
{
    if ([self prepareStart]) {
        [self.session startRunning];
        return YES;
    }
    return NO;
}

- (void)stop {
    [self.session stopRunning];
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataMachineReadableCodeObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //不存在数据或者正在缩放则忽略
    if (self.output != output ||
        metadataObjects.count == 0 ||
        self.device.rampingVideoZoom ||
        self.pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        self.pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        return;
    }
    
    //取消回调
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //读取数据
    AVMetadataObject * firstMetadataObject = nil;
    NSMutableArray * codeDatas = [NSMutableArray arrayWithCapacity:metadataObjects.count];
    for (AVMetadataMachineReadableCodeObject * metadataObject in metadataObjects) {
        NSString * stringValue = metadataObject.stringValue;
        if (stringValue.length) {
            if (firstMetadataObject == nil &&
                !CGRectIsEmpty(metadataObject.bounds)) {
                firstMetadataObject = metadataObject;
            }
            [codeDatas addObject:stringValue];
        }
    }
    
    if (codeDatas.count == 0) {
        return;
    }
    
    //允许自动缩放
    if (firstMetadataObject && self.autoZoomScale) {
        
        //获取扫描区和码区
        CGRect bounds = [self.previewLayer transformedMetadataObjectForMetadataObject:firstMetadataObject].bounds;
        CGRect rectOfInterest = [self.previewLayer rectForMetadataOutputRectOfInterest:self.output.rectOfInterest];
        
        if (bounds.size.width < rectOfInterest.size.width * 0.3f ||
            bounds.size.height < rectOfInterest.size.height * 0.3f) { //识别的码位置过小
            
            //扩展成中心的矩形
            CGPoint center = CenterForRect(self.previewLayer.bounds);
            bounds = _appendCenterRect(bounds, center);
            rectOfInterest = _appendCenterRect(rectOfInterest, center);
            
            //计算边距
            CGFloat xScaleLenght = bounds.origin.x - rectOfInterest.origin.x;
            CGFloat yScaleLenght = bounds.origin.y - rectOfInterest.origin.y;
            
            //距离边缘有一定距离
            if (xScaleLenght > 10.f && yScaleLenght > 10.f) {
                
                //计算缩放比例
                CGFloat scaleAppendX = 2 * xScaleLenght / bounds.size.width;
                CGFloat scaleAppendY = 2 * yScaleLenght / bounds.size.height;
                CGFloat scaleAppend = MIN(scaleAppendX, scaleAppendY);
                
                //缩放
                if (scaleAppend > 0.1f) {
                    [self setZoomScale:self.zoomScale * (1.f + scaleAppend) animated:YES];
                    
                    //1.s后发送延迟通知
                    [self performSelector:@selector(_sendDidReadCodeDatasMsgWithDatas:) withObject:codeDatas afterDelay:1.0];
                    
                    return;
                }
            }
        }
    }
    
    //通知代理
    [self _sendDidReadCodeDatasMsgWithDatas:codeDatas];
}

- (void)_sendDidReadCodeDatasMsgWithDatas:(NSMutableArray *)codeDatas
{
    if (!self.isRunning) {
        return;
    }
    
    id<MyCodeReaderViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(codeReaderView:didReadCodeDatas:)){
        [delegate codeReaderView:self didReadCodeDatas:codeDatas];
    }
}

#pragma mark - notication

- (void)_addNotification
{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(_captureSessionDidStartRunningNotification:)
                   name:AVCaptureSessionDidStartRunningNotification
                 object:self.session];
    [center addObserver:self
               selector:@selector(_captureSessionDidFailureStartRunningNotification:)
                   name:AVCaptureSessionRuntimeErrorNotification
                 object:self.session];
    [center addObserver:self
               selector:@selector(_captureSessionDidStopRunningNotification:)
                   name:AVCaptureSessionDidStopRunningNotification
                 object:self.session];
    [center addObserver:self
               selector:@selector(_captureSessionWasInterruptedNotification:)
                   name:AVCaptureSessionWasInterruptedNotification
                 object:self.session];
    [center addObserver:self
               selector:@selector(_captureSessionInterruptionEndedNotification:)
                   name:AVCaptureSessionInterruptionEndedNotification
                 object:self.session];
    
}

- (BOOL)isRunning {
    return self.session.isRunning;
}

- (BOOL)isInterrupted {
     return self.session.isInterrupted;
}

- (void)_captureSessionDidStartRunningNotification:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [self _didStartRunning];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _didStartRunning];
        });
    }
}

- (void)_didStartRunning
{
    id<MyCodeReaderViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(codeReaderViewDidStartRuning:)){
        [delegate codeReaderViewDidStartRuning:self];
    }
    
    if (self.showScanActivityView) {
        [self.scanActivityView start];
    }
    
    //更新扫码区域
    [self _updateRectOfInterest];
}

- (void)_captureSessionDidFailureStartRunningNotification:(NSNotification *)notification
{
    id<MyCodeReaderViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(codeReaderView:didFailureStartRuningWithError:)){
        [delegate codeReaderView:self didFailureStartRuningWithError:notification.userInfo[AVCaptureSessionErrorKey]];
    }
}

- (void)_captureSessionDidStopRunningNotification:(NSNotification *)notification
{
    id<MyCodeReaderViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(codeReaderViewDidStopRunning:)){
        [delegate codeReaderViewDidStopRunning:self];
    }
    
    if (self.showScanActivityView) {
        [self.scanActivityView stop];
    }
}

- (void)_captureSessionWasInterruptedNotification:(NSNotification *)notification
{
    id<MyCodeReaderViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(codeReaderViewWasInterrupted:)){
        [delegate codeReaderViewWasInterrupted:self];
    }
}

- (void)_captureSessionInterruptionEndedNotification:(NSNotification *)notification
{
    id<MyCodeReaderViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(codeReaderViewInterruptionEnded:)){
        [delegate codeReaderViewInterruptionEnded:self];
    }
}

@end
