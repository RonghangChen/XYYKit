//
//  MyCodeScanActivityView.m
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyCodeScanActivityView.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface MyCodeScanActivityView ()

//是否在运行
@property(nonatomic,getter=isRunning) BOOL running;

//计时器
@property(nonatomic,strong) CADisplayLink * displayLink;

@property(nonatomic,strong,readonly) UIView * maskLayerView;
@property(nonatomic,strong,readonly) CALayer * scanCropBoundsLayer;
@property(nonatomic,strong,readonly) UIImageView * scanActivityImageView;

//运行了的时间
@property(nonatomic) NSTimeInterval runningTime;

//
@property(nonatomic,readonly) CGRect scanCropRect;
//无效需要从新计算
@property(nonatomic) BOOL scanCropRectInvidate;

@end

//----------------------------------------------------------

@implementation MyCodeScanActivityView

@synthesize codeType = _codeType;
@synthesize scanCrop = _scanCrop;
@synthesize scanCropBoundsTintColor = _scanCropBoundsTintColor;

@synthesize maskLayerView = _maskLayerView;
@synthesize scanCropBoundsLayer = _scanCropBoundsLayer;
@synthesize scanActivityImageView = _scanActivityImageView;
@synthesize scanCropRect = _scanCropRect;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        [self _setup_MyCodeScanActivityView];
    }
    
    return self;
}

- (id)initWithCodeType:(MyCodeType)codeType
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _codeType = codeType;
        [self _setup_MyCodeScanActivityView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyCodeScanActivityView];
    }
    
    return self;
}


- (void)_setup_MyCodeScanActivityView
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    _scanCrop = CGRectMake(0.f, 0.f, 1.f, 1.f);
    _animationDuration = 2.f;
    self.scanCropRectInvidate = YES;
}

#pragma mark - 

- (CGRect)scanCropRect
{
    if (self.scanCropRectInvidate) {
        self.scanCropRectInvidate = NO;
        
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds);
        
        CGRect scanCropRect = CGRectMake(CGRectGetMinX(self.scanCrop) * width,
                                         CGRectGetMinY(self.scanCrop) * height,
                                         CGRectGetWidth(self.scanCrop) * width,
                                         CGRectGetHeight(self.scanCrop) * height);
        
        scanCropRect.origin.x = MAX(0, scanCropRect.origin.x);
        scanCropRect.origin.y = MAX(0, scanCropRect.origin.y);
        scanCropRect.size.width = MIN(scanCropRect.size.width, width);
        scanCropRect.size.height = MIN(scanCropRect.size.height, height);
        
        _scanCropRect = scanCropRect;
    }
    
    return _scanCropRect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scanCropRectInvidate = YES;
    
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, NULL, self.bounds);
    CGPathAddRect(maskPath, NULL, self.scanCropRect);
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = maskPath;
    CGPathRelease(maskPath);
    
    //设置mask
    self.maskLayerView.layer.mask = maskLayer;
    
    //更新扫描框
    [self _updateScanCropBounds];
}


- (void)setScanCrop:(CGRect)scanCrop
{
    if (!CGRectEqualToRect(self.scanCrop, scanCrop)) {
        _scanCrop = scanCrop;
        [self setNeedsLayout];
    }
}

#pragma mark -

- (UIView *)maskLayerView
{
    if(!_maskLayerView){
        
        _maskLayerView = [[UIView alloc] initWithFrame:self.bounds];
        _maskLayerView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                          UIViewAutoresizingFlexibleWidth;
        _maskLayerView.backgroundColor = BlackColorWithAlpha(0.6f);
        [self insertSubview:_maskLayerView atIndex:0];
    }
    
    return _maskLayerView;
}

- (UIColor *)maskColor {
    return self.maskLayerView.backgroundColor;
}

- (void)setMaskColor:(UIColor *)maskColor {
    self.maskLayerView.backgroundColor = maskColor;
}


#pragma mark -

- (CALayer *)scanCropBoundsLayer
{
    if (!_scanCropBoundsLayer) {
        _scanCropBoundsLayer = [[CALayer alloc] init];
        _scanCropBoundsLayer.actions = @{@"bounds" : [NSNull null] , @"position" : [NSNull null]};
        
        if (_scanActivityImageView) {
            [self.layer insertSublayer:_scanCropBoundsLayer below:_scanActivityImageView.layer];
        }else{
            [self.layer addSublayer:_scanCropBoundsLayer];
        }
    }
    
    return _scanCropBoundsLayer;
}

- (void)setScanCropBoundsTintColor:(UIColor *)scanCropBoundsTintColor
{
    if(_scanCropBoundsTintColor != scanCropBoundsTintColor){
        _scanCropBoundsTintColor = scanCropBoundsTintColor;
        [self _scanCropBoundsTintColorDidChange];
    }
}

- (UIColor *)scanCropBoundsTintColor {
    return _scanCropBoundsTintColor ?: [self tintColor];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (!_scanCropBoundsTintColor) {
        [self _scanCropBoundsTintColorDidChange];
    }
}

- (void)_scanCropBoundsTintColorDidChange
{
    [self _updateScanCropBounds];
    
    if (_scanActivityImageView) {
        _scanActivityImageView.image = [self _scanActivityIndicarterImage];
    }
}

- (void)_updateScanCropBounds
{
    self.scanCropBoundsLayer.sublayers = nil;
 
    CGRect scanCropRect = self.scanCropRect;
    self.scanCropBoundsLayer.frame = scanCropRect;
    
    //白色边界
    CAShapeLayer * boundsShapeLayer = [CAShapeLayer layer];
    boundsShapeLayer.fillColor = [UIColor clearColor].CGColor;
    boundsShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    boundsShapeLayer.path = [UIBezierPath bezierPathWithRect:self.scanCropBoundsLayer.bounds].CGPath;
    [self.scanCropBoundsLayer addSublayer:boundsShapeLayer];
    
    //其余颜色的标记
    CAShapeLayer * indicaterShapeLayer = [CAShapeLayer layer];
    indicaterShapeLayer.fillColor = [UIColor clearColor].CGColor;
    indicaterShapeLayer.strokeColor = self.scanCropBoundsTintColor.CGColor;
    indicaterShapeLayer.lineWidth = 4.f;
    
    CGFloat scanCropRectWidth = CGRectGetWidth(scanCropRect);
    CGFloat scanCropRectHeight = CGRectGetHeight(scanCropRect);
    CGFloat indicaterLenght = MIN(scanCropRectWidth, scanCropRectHeight);
    indicaterLenght *= 0.5f;
    indicaterLenght = MIN(indicaterLenght, 15.f);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.F, indicaterLenght);
    CGPathAddLineToPoint(path, NULL, 0.F, 0.F);
    CGPathAddLineToPoint(path, NULL, indicaterLenght, 0.F);
    
    CGPathMoveToPoint(path, NULL, scanCropRectWidth - indicaterLenght, 0.f);
    CGPathAddLineToPoint(path, NULL, scanCropRectWidth, 0.F);
    CGPathAddLineToPoint(path, NULL, scanCropRectWidth, indicaterLenght);
    
    CGPathMoveToPoint(path, NULL, scanCropRectWidth, scanCropRectHeight - indicaterLenght);
    CGPathAddLineToPoint(path, NULL, scanCropRectWidth, scanCropRectHeight);
    CGPathAddLineToPoint(path, NULL, scanCropRectWidth - indicaterLenght, scanCropRectHeight);
    
    CGPathMoveToPoint(path, NULL, indicaterLenght, scanCropRectHeight);
    CGPathAddLineToPoint(path, NULL, 0.F, scanCropRectHeight);
    CGPathAddLineToPoint(path, NULL, 0.F, scanCropRectHeight - indicaterLenght);
    
    indicaterShapeLayer.path = path;
    CGPathRelease(path);
    
    [self.scanCropBoundsLayer addSublayer:indicaterShapeLayer];
}

#pragma mark -

- (void)start
{
    if (!self.isRunning) {
        self.running = YES;
        
        self.scanActivityImageView.hidden = NO;
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_timeToUpdatescanActivity)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
        
        self.runningTime = 0.f;
        
        //更新一次
        [self _timeToUpdatescanActivity];
    }
}

- (void)stop
{
    if (self.isRunning) {
        self.running = NO;
    
        self.scanActivityImageView.hidden = YES;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    if (animationDuration != _animationDuration) {
        if (self.isRunning) {
            self.runningTime *= (animationDuration / _animationDuration);
        }
        _animationDuration = animationDuration;
    }
}

- (UIImage *)_scanActivityIndicarterImage
{
//    return [[ImageWithName(@"scan_line.png") imageWithTintColor:self.scanCropBoundsTintColor] resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 85.f, 0.f, 85.f) resizingMode:UIImageResizingModeStretch];
    
    return [ImageWithName(@"scan_line.png") resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 90.f, 0.f, 90.f) resizingMode:UIImageResizingModeStretch];
}

- (UIImageView *)scanActivityImageView
{
    if(!_scanActivityImageView){
        _scanActivityImageView = [[UIImageView alloc] init];
        _scanActivityImageView.contentMode = UIViewContentModeScaleToFill;
        _scanActivityImageView.image = [self _scanActivityIndicarterImage];
        _scanActivityImageView.hidden = YES;
        [self addSubview:_scanActivityImageView];
    }
    
    return _scanActivityImageView;
}

- (void)_timeToUpdatescanActivity
{
    //计算时间
    NSTimeInterval duration = self.displayLink.duration;
    if (self.runningTime + duration > self.animationDuration &&
        self.runningTime < self.animationDuration) {
        self.runningTime = self.animationDuration;
    }else if (self.runningTime + duration > 2 * self.animationDuration &&
              self.runningTime < 2 *self.animationDuration){
        self.runningTime = 0.f;
    }else{
        self.runningTime += duration;
    }
    
    //计算位置
    CGRect scanCropRect = self.scanCropRect;
    CGFloat imageViewHeight = self.scanActivityImageView.image.size.height;
    
    CGRect scanActivityImageViewFrame = scanCropRect;
    scanActivityImageViewFrame.size.height = imageViewHeight;
    
    if (imageViewHeight < CGRectGetHeight(scanCropRect)) {
        
        CGFloat progress = 0.f;
        if (self.runningTime <= self.animationDuration) {
            progress = self.runningTime / self.animationDuration;
        }else{
            progress = (2 * self.animationDuration - self.runningTime) / self.animationDuration;
        }
        
        if (progress < 0.2f) {
            self.scanActivityImageView.alpha = 5 * progress;
        }else if (progress > 0.8f){
            self.scanActivityImageView.alpha = 5 * (1.0f - progress);
        }else{
            self.scanActivityImageView.alpha = 1.f;
        }
    
        scanActivityImageViewFrame.origin.y += ((CGRectGetHeight(scanCropRect) - imageViewHeight) * progress);
    }
    
    self.scanActivityImageView.frame = scanActivityImageViewFrame;
}



@end
