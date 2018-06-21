//
//  MyActivityIndicatorView.m
//
//
//  Created by LeslieChen on 14-7-25.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

#import "MyActivityIndicatorView.h"
#import "XYYSizeUtil.h"
#import "XYYConst.h"

@interface MyActivityIndicatorView () <CAAnimationDelegate>

@end

@implementation MyActivityIndicatorView
{
    CAShapeLayer    *_shapeLayer;
    BOOL             _isAnimating;
}

@synthesize hidesWhenStopped = _hidesWhenStopped;

#pragma mark - life circle

- (id)init {
    return [self initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
    if (self) {
        self.frame = frame;
    }
    
    return self;
}

- (id)initWithStyle:(MyActivityIndicatorViewStyle)style
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
    if (self) {
        _style = style;
        [self _init_MyActivityIndicatorView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init_MyActivityIndicatorView];
    }
    
    return self;
}

- (void)_init_MyActivityIndicatorView
{
    self.userInteractionEnabled = NO;
    self.hidden = _style == MyActivityIndicatorViewStyleIndeterminate;
    self.backgroundColor = [UIColor clearColor];
//    self.tintColor = ColorWithNumberRGB(0x447BED);
    
    _hidesWhenStopped = YES;
    _clockwise        = YES;
    _lineWidth        = 1.f;
    _indeterminateProgress = 0.9f;
    
    _shapeLayer             = [[CAShapeLayer alloc] init];
    _shapeLayer.frame       = self.bounds;
    _shapeLayer.lineWidth   = 1.f;
    _shapeLayer.lineCap     = kCALineCapRound;
    _shapeLayer.strokeColor = self.tintColor.CGColor;
    _shapeLayer.fillColor   = [UIColor clearColor].CGColor;
    _shapeLayer.actions     = @{@"strokeEnd":[NSNull null],
                                @"bounds"   :[NSNull null],
                                @"position" :[NSNull null]};
    [self.layer addSublayer:_shapeLayer];
}

- (void)dealloc {
    [self stopAnimating];
}


#pragma mark - layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(37.f, 37.f);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize intrinsicContentSize = [self intrinsicContentSize];
    return CGSizeMake(MAX(size.width, intrinsicContentSize.width),
                      MAX(size.height, intrinsicContentSize.height));
}

- (void)setStartAngle:(CGFloat)startAngle
{
    if (_startAngle != startAngle) {
        _startAngle = startAngle;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _updateView];
}

- (void)_updateView
{
    //设置路径
    float startAngle  = degreesToRadians(self.startAngle);
    float endAngle    = startAngle + 2 * M_PI;
    
    CGRect  bounds = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    _shapeLayer.frame = bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, CGRectGetWidth(bounds) * 0.5f, CGRectGetHeight(bounds) * 0.5f,  (MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) - _lineWidth) * 0.5f, startAngle, endAngle, !_clockwise);
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.lineWidth = _lineWidth;
    _shapeLayer.strokeEnd = _progress;
}

- (void)setStyle:(MyActivityIndicatorViewStyle)style
{
    if (_style != style) {
        _style = style;
        [self _reset];
    }
}

- (void)_reset
{
    //动画停止
    [self stopAnimating];
    
    //设置隐藏与否
    self.hidden = _style == MyActivityIndicatorViewStyleIndeterminate && _hidesWhenStopped;
    
    //设置进度
    _progress = (_style == MyActivityIndicatorViewStyleIndeterminate && !_twoStepAnimation) ? _indeterminateProgress : 0.f;
    _shapeLayer.strokeEnd = _progress;
}


- (void)setIndeterminateProgress:(float)indeterminateProgress
{
    indeterminateProgress = ChangeInMinToMax(indeterminateProgress, 0.f, 1.f);
    
    if (_indeterminateProgress != indeterminateProgress) {
        _indeterminateProgress = indeterminateProgress;
        
        if (_style == MyActivityIndicatorViewStyleIndeterminate && (!_twoStepAnimation || _isAnimating)) {
            _progress =  _indeterminateProgress;
            _shapeLayer.strokeEnd = _progress;
        }
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        [self setNeedsLayout];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        [self setNeedsLayout];
    }
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    _shapeLayer.strokeColor = self.tintColor.CGColor;
}

- (void)setProgress:(float)progress
{
    if (_style == MyActivityIndicatorViewStyleDeterminate) {
        
        progress = ChangeInMinToMax(progress, 0.f, 1.f);
        
        if (_progress != progress) {
            _progress = progress;
            _shapeLayer.strokeEnd = _progress;
        }
    }
}

- (void)setClockwise:(BOOL)clockwise
{
    if (_clockwise != clockwise) {
        _clockwise = clockwise;
        
        [self _updateView];
        
        //更新动画
        if (_isAnimating) {
            [self startAnimating];
        }
    }
}


- (void)startAnimating
{
    if (_style == MyActivityIndicatorViewStyleIndeterminate) {
        [self stopAnimating];
        
        _isAnimating = YES;
        
        if (self.window) {
            [self _startAnimating];
        }
        
        if (_hidesWhenStopped) {
            self.hidden = NO;
        }
    }
}


- (void)stopAnimating
{
    if (_isAnimating) {
        
        _isAnimating = NO;
        
        [self _stopAnimating];
        
        if (_hidesWhenStopped) {
            self.hidden = YES;
        }
    }
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

- (void)didMoveToWindow
{
    if (self.window && _isAnimating) {
        [self _startAnimating];
    }else if(_isAnimating){
        [self _stopAnimating];
    }
}

#pragma mark - animating


- (void)_startAnimating
{
    _progress  = _indeterminateProgress;
    _shapeLayer.strokeEnd = _progress;
    
    if (_twoStepAnimation) {
        
        CABasicAnimation * loadAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        loadAnimation.fromValue = @(0.f);
        loadAnimation.toValue   = @(_indeterminateProgress);
        loadAnimation.duration  = 0.4f;
        loadAnimation.delegate  = self;
        [_shapeLayer addAnimation:loadAnimation forKey:@"loadAnimation"];
    }else{
        [self _startRotationAnimation];
    }
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isMemberOfClass:[CABasicAnimation class]]) {
        
        if ([[(CABasicAnimation *)anim keyPath] isEqualToString:@"strokeEnd"] && flag) {
            [self _startRotationAnimation];
        }
    }
}

- (void)_startRotationAnimation
{
    CABasicAnimation * rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue   = @(0.f);
    rotationAnimation.toValue     = @(_clockwise ? 2 * M_PI : -2 * M_PI);
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.duration    = 0.8f;
    [_shapeLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)_stopAnimating
{
    _progress = _twoStepAnimation ? 0.f : _indeterminateProgress;
    _shapeLayer.strokeEnd = _progress;
    
    //移除所有动画
    [_shapeLayer removeAllAnimations];
    
    //移除
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}


- (void)_appWillEnterForegroundNotification:(NSNotification *)notification
{
    if (_isAnimating) {
        [self startAnimating];
    }
}


@end
