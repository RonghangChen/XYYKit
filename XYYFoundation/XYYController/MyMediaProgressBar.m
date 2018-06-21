//
//  MyMediaProgressBar.m
//
//
//  Created by LeslieChen on 14-2-26.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyMediaProgressBar.h"
#import "XYYConst.h"

//----------------------------------------------------------

#define TrackHeight       2.f
#define TouchPadding      10.f
#define DefaultThumbSize  CGSizeMake(14.f,14.f)
#define DefaultBarLenght  100.f

//----------------------------------------------------------

@interface MyMediaProgressBar()

@property(nonatomic,strong,readonly) UIImageView  * thumbImageView;

@property(nonatomic,strong,readonly) CAShapeLayer * trackBGShapeLayer;
@property(nonatomic,strong,readonly) CAShapeLayer * loadedTrackShapeLayer;
@property(nonatomic,strong,readonly) CAShapeLayer * glowTrackShapeLayer;


- (CGRect)_rectForThumbImageView;

//获取轨迹的path
- (CGPathRef)_pathForTrackShapeLayer;

//更新进度
- (void)_updateProgress;

//KV0
- (void)_registerKVO;
- (void)_unregisterKVO;
- (NSArray *)_observableKeypaths;
- (void)_updateUIForKeypath:(NSString *)keyPath;


@end

//----------------------------------------------------------

@implementation MyMediaProgressBar
{
    BOOL    _haveInitSubView;
    CGFloat _touchBeginPointX;
    CGFloat _thumbThouchOffsetX;
}

@synthesize thumbImageView = _thumbImageView;

@synthesize trackBGShapeLayer     = _trackBGShapeLayer;
@synthesize loadedTrackShapeLayer = _loadedTrackShapeLayer;
@synthesize glowTrackShapeLayer   = _glowTrackShapeLayer;

#pragma mark - life circle

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    if(self){
        [self sizeToFit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_MyMediaProgressBar];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyMediaProgressBar];
    }
    
    return self;
}

- (void)_setup_MyMediaProgressBar
{
    self.backgroundColor = [UIColor clearColor];
    
    _maxValue   = 1.f;
    _continuous = YES;
    
    _trackBGColor      = [UIColor darkGrayColor];
    _glowTrackColor    = [UIColor whiteColor];
    _loadedTrackColor  = [UIColor lightGrayColor];
    _thumbColor        = [UIColor whiteColor];
    _thumbShadowColor  = [UIColor whiteColor];
    
    //注册
    [self _registerKVO];
}

- (void)dealloc {
    [self _unregisterKVO];
}

#pragma mark - para lazy init

- (UIImageView *)thumbImageView
{
    if (!_thumbImageView) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _thumbImageView.backgroundColor = [UIColor redColor];
        
        [self _updateThumb];
    }
    
    return _thumbImageView;
}

- (void)_updateThumb
{
    if (_thumbImageView) {
        
        _thumbImageView.layer.sublayers = nil;
        _thumbImageView.layer.shadowOpacity = 0.f;
        _thumbImageView.image = nil;
        _thumbImageView.highlightedImage = nil;
        
        if (self.thumbImageNormal) {
            _thumbImageView.image = self.thumbImageNormal;
            _thumbImageView.highlightedImage = self.thumbImageHighlighted;
            
            CGRect bounds = CGRectZero;
            bounds.size = self.thumbImageNormal.size;
            _thumbImageView.bounds = bounds;
            
        }else{
            
            CGRect bounds = CGRectZero;
            bounds.size = DefaultThumbSize;
            _thumbImageView.bounds = bounds;
            
            //按钮形状
            CAShapeLayer * thumbLayer = [CAShapeLayer layer];
            thumbLayer.fillColor = self.thumbColor.CGColor;
            thumbLayer.strokeColor = thumbLayer.fillColor;
            
            //设置路径
            CGFloat radius = CGRectGetWidth(bounds) * 0.5f;
            thumbLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                             radius:radius
                                                         startAngle:0.f
                                                           endAngle:M_PI * 2
                                                          clockwise:NO].CGPath;
            
            [_thumbImageView.layer addSublayer:thumbLayer];
            
            //设置阴影
            _thumbImageView.layer.shadowPath = [UIBezierPath bezierPathWithArcCenter:
                                                                        CGPointMake(radius, radius)
                                                                                 radius:radius + 3.f
                                                                             startAngle:0.f
                                                                               endAngle:M_PI * 2
                                                                              clockwise:NO].CGPath;
            
            _thumbImageView.layer.shadowOffset  = CGSizeZero;
            _thumbImageView.layer.shadowColor = self.thumbShadowColor.CGColor;
            if (_thumbImageView.isHighlighted){
                _thumbImageView.layer.shadowOpacity = 1.f;
            }
        }
        
        //内建大小改变
        [self invalidateIntrinsicContentSize];
    }
}

- (CAShapeLayer *)_createShapeLayer
{
    CAShapeLayer * shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineWidth = TrackHeight;
    shapeLayer.lineCap   = kCALineCapRound;
    shapeLayer.actions = @{
                           @"path"       :[NSNull null],
                           @"strokeColor":[NSNull null],
                           @"strokeStart":[NSNull null],
                           @"strokeEnd"  :[NSNull null]
                          };
    shapeLayer.strokeStart = 0.f;
    shapeLayer.strokeEnd   = 0.f;
    
    return shapeLayer;
}

- (CAShapeLayer *)trackBGShapeLayer
{
    if (!_trackBGShapeLayer) {
        _trackBGShapeLayer = [self _createShapeLayer];
        _trackBGShapeLayer.strokeColor = self.trackBGColor.CGColor;
        _trackBGShapeLayer.strokeEnd = 1.f;
    }
    
    return _trackBGShapeLayer;
}

- (CAShapeLayer *)loadedTrackShapeLayer
{
    if (!_loadedTrackShapeLayer) {
        _loadedTrackShapeLayer = [self _createShapeLayer];
        _loadedTrackShapeLayer.strokeColor = self.loadedTrackColor.CGColor;
    }
    
    return _loadedTrackShapeLayer;
}

- (CAShapeLayer *)glowTrackShapeLayer
{
    if (!_glowTrackShapeLayer) {
        _glowTrackShapeLayer = [self _createShapeLayer];
        _glowTrackShapeLayer.strokeColor = self.glowTrackColor.CGColor;
    }
    
    return _glowTrackShapeLayer;
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[
              @"thumbImageNormal",
              @"thumbImageHighlighted",
              @"trackBGColor",
              @"glowTrackColor",
              @"loadedTrackColor",
              @"thumbColor",
              @"thumbShadowColor"
            ];
}

- (void)_registerKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)_unregisterKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self == object && ![change[@"old"] isEqual:change[@"new"]]) {
        
        //update UI
        if ([NSThread isMainThread]) {
            [self _updateUIForKeypath:keyPath];
        }else{
            [self performSelectorOnMainThread:@selector(_updateUIForKeypath:)
                                   withObject:keyPath
                                waitUntilDone:NO];
        }
    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"trackBGColor"]) {
        if (_trackBGShapeLayer) _trackBGShapeLayer.strokeColor = self.trackBGColor.CGColor;
    }else if ([keyPath isEqualToString:@"glowTrackColor"]){
        
        if (_glowTrackShapeLayer) {
            _glowTrackShapeLayer.strokeColor = self.glowTrackColor.CGColor;
        }
        
        if (_thumbImageView && !_thumbImageView.image) {
            _thumbImageView.layer.shadowColor = self.glowTrackColor.CGColor;
        }
        
    }else if ([keyPath isEqualToString:@"loadedTrackColor"]){
        if (_loadedTrackShapeLayer) _loadedTrackShapeLayer.strokeColor = self.loadedTrackColor.CGColor;
    }else{
        if (_thumbImageView) {
            //更新按钮
            [self _updateThumb];
            [self setNeedsLayout];
        }
    }
}

#pragma mark - Set Progress

//value
#define StandardValue(_value,_standardFunc)    \
    (_stepValueInternal ? _standardFunc((_value)/_stepValueInternal) * _stepValueInternal : _value)

#define StepValue(_value,_standardFunc)         \
    (_minValue + StandardValue((_value) - _minValue,_standardFunc))

#define ValueToProgress(_value)                 \
    ((_maxValue - _minValue) ? ((_value) - _minValue)/(_maxValue - _minValue) : 0)

- (void)_updateProgress
{
    if (_haveInitSubView) {
        self.loadedTrackShapeLayer.strokeEnd = ValueToProgress(_loadedValue);
        self.glowTrackShapeLayer.strokeEnd   = ValueToProgress(_value);
    }
}

- (void)setMinValue:(float)minValue
{
    if (_minValue != minValue) {
        
        //标准化值
        _minValue    = MIN(minValue, _maxValue - _stepValueInternal);
        _minValue    = _maxValue - StandardValue(_maxValue - _minValue,ceilf);
        _value       = MAX(_minValue, _value);
        _loadedValue = MAX(_minValue, _loadedValue);
        
        //更新进度
        [self _updateProgress];
    }
}

- (void)setMaxValue:(float)maxValue
{
    if (_maxValue != maxValue) {
        
        //标准化值
        _maxValue    = MAX(maxValue, _minValue + _stepValueInternal);
        _maxValue    = StepValue(_maxValue, floorf);
        _value       = MIN(maxValue, _value);
        _loadedValue = MIN(maxValue, _loadedValue);
        
        //更新进度
        [self _updateProgress];
    }
}

- (void)setStepValueInternal:(float)stepValueInternal
{
    stepValueInternal = MAX(0, stepValueInternal);
    
    if (_stepValueInternal != stepValueInternal) {
        
        //标准化值
        _stepValueInternal = stepValueInternal;
        _maxValue          = StepValue(_maxValue, floorf);
        _value             = StepValue(_value, roundf);
        _loadedValue       = StepValue(_loadedValue, roundf);
        
        //更新过程
        [self _updateProgress];
    }
}

- (CAAnimation *)_createAnimationForm:(CGFloat)from to:(CGFloat)to
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = 0.2f;
    animation.fromValue = @(from);
    animation.toValue   = @(to);
    
    return animation;
}

- (void)setValue:(float)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    //标准化值
    value = ChangeInMinToMax(value, _minValue, _maxValue);
    value = StepValue(value, roundf);
    
    if (_value != value) {
        [self _setValue:value animated:animated];
    }
}

//内部值改变调用的方法
- (void)_setValue:(float)value animated:(BOOL)animated
{
    _value = value;
    
    CGFloat to  = ValueToProgress(_value);
    
    if (animated) {
        
        CGFloat from = self.glowTrackShapeLayer.strokeEnd;
        [self.glowTrackShapeLayer addAnimation:[self _createAnimationForm:from to:to] forKey:@"animation"];
        
        [UIView beginAnimations:nil context:nil];
    }
    
    self.glowTrackShapeLayer.strokeEnd = to;
    self.thumbImageView.frame = [self _rectForThumbImageView];

    if (animated) {
        [UIView commitAnimations];
    }
    
}

- (void)setLoadedValue:(float)loadedValue {
    [self setLoadedValue:loadedValue animated:NO];
}

- (void)setLoadedValue:(float)loadedValue animated:(BOOL)animated
{
    //标准化值
    loadedValue = ChangeInMinToMax(loadedValue, _minValue, _maxValue);
    loadedValue = StepValue(loadedValue, roundf);
    
    if (_loadedValue != loadedValue) {
        
        _loadedValue = loadedValue;
    
        CGFloat to   = ValueToProgress(_loadedValue);
        
        if (_loadedValue > _value && animated) {
            
            CGFloat from = self.loadedTrackShapeLayer.strokeEnd;
            [self.loadedTrackShapeLayer addAnimation:[self _createAnimationForm:from to:to] forKey:@"animation"];
        }
        
        self.loadedTrackShapeLayer.strokeEnd = to;
    }
}

#pragma mark - Layout

#define TrackLength(_thumbWidth)    \
    (CGRectGetWidth(self.bounds) - _thumbWidth - 2 * TouchPadding)

#define TrackStartX(_thumbWidth)    \
    (_thumbWidth * 0.5f + TouchPadding + CGRectGetMinX(self.bounds))

#define TrackEndX(_thumbWidth)      \
    (CGRectGetMaxX(self.bounds) - _thumbWidth * 0.5f - TouchPadding)

#define ValueToLength(_value,_thumbWidth) \
    (ValueToProgress(_value) * TrackLength(_thumbWidth))

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_haveInitSubView) {
        
        _haveInitSubView = YES;
        
        [self.layer addSublayer:self.trackBGShapeLayer];
        [self.layer addSublayer:self.loadedTrackShapeLayer];
        [self.layer addSublayer:self.glowTrackShapeLayer];
        
        [self addSubview:self.thumbImageView];
    }
    
    //设置按钮位置
    self.thumbImageView.frame = [self _rectForThumbImageView];
    
    //设置路劲
    CGPathRef path = [self _pathForTrackShapeLayer];
    self.trackBGShapeLayer.path = path;
    self.loadedTrackShapeLayer.path = path;
    self.glowTrackShapeLayer.path = path;
    
    //更新进度
    [self _updateProgress];
}


- (CGPathRef)_pathForTrackShapeLayer
{
    CGFloat thumbWidth = CGRectGetWidth(self.thumbImageView.bounds);
    CGFloat midY       = CGRectGetMidY(self.bounds);
    
    UIBezierPath * bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(TrackStartX(thumbWidth), midY)];
    [bezierPath addLineToPoint:CGPointMake(TrackEndX(thumbWidth), midY)];
    
    return bezierPath.CGPath;
}

- (CGRect)_rectForThumbImageView
{
    CGRect thumbRect = CGRectZero;
    thumbRect.size = self.thumbImageNormal ? self.thumbImageNormal.size : DefaultThumbSize;
    
    CGFloat thumbWidth = CGRectGetWidth(thumbRect);
    CGFloat xValue = ValueToLength(_value,thumbWidth) + TrackStartX(thumbWidth) - thumbWidth * 0.5f;
    thumbRect.origin = CGPointMake(xValue, (CGRectGetHeight(self.bounds) - CGRectGetHeight(thumbRect)) * 0.5f);
    
    return thumbRect;
}

#pragma mark - Touch Handle

- (CGRect)_thumbTouchRect
{
    //扩大触摸响应范围
    CGRect touchRect = self.thumbImageView.frame;
    
    return CGRectInset(touchRect, -2 * TouchPadding, -2 * TouchPadding);
}

- (float)_valueForThumbCenterX:(CGFloat)thumbCenterX
{
   
    CGFloat thumbWidth = CGRectGetWidth(self.thumbImageView.bounds);
    
    float value = ((thumbCenterX - TrackStartX(thumbWidth)) / TrackLength(thumbWidth)) * (_maxValue - _minValue) + _minValue;
    
    //标准化
    value = ChangeInMinToMax(value, _minValue, _maxValue);
    value = StepValue(value, roundf);
    
    return value;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (!enabled && _dragging) {
        
        _dragging = NO;
        
        self.thumbImageView.highlighted = NO;
        self.thumbImageView.layer.shadowOpacity = 0.f;
        self.thumbImageView.transform = CGAffineTransformIdentity;
        
        [self setNeedsLayout];        
    }
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint touchPoint = [touch locationInView:self];
    
    //被获取
    if (CGRectContainsPoint([self _thumbTouchRect], touchPoint)) {
        
        _dragging = YES;
        
        _thumbThouchOffsetX = touchPoint.x - self.thumbImageView.center.x;

        //设置高亮
        self.thumbImageView.highlighted = YES;
        
        //无图片
        if (!self.thumbImageView.image) {
            self.thumbImageView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            self.thumbImageView.layer.shadowOpacity = 1.f;
        }
    }
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_dragging) {
        
        CGFloat newThumbCenterX = [touch locationInView:self].x - _thumbThouchOffsetX;
        
        //限制在一定范围
        CGFloat thumbWidth = CGRectGetWidth(self.thumbImageView.bounds);
        CGFloat minX = TrackStartX(thumbWidth);
        CGFloat maxX = TrackEndX(thumbWidth);
        newThumbCenterX = ChangeInMinToMax(newThumbCenterX, minX , maxX);
        
        //更新位置
        self.thumbImageView.center = CGPointMake(newThumbCenterX, self.thumbImageView.center.y);
        self.glowTrackShapeLayer.strokeEnd = (newThumbCenterX - TrackStartX(thumbWidth)) / TrackLength(thumbWidth);
    
        //发送事件
        if(_continuous){
            
            //计算对应的新值
            float newValue = [self _valueForThumbCenterX:newThumbCenterX];

            if (newValue != _value) {
                _value = newValue;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
        
        return YES;
    }else{
        return NO;
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{

    CGFloat newThumbCenterX;
    
    if (_dragging) {
        
        self.thumbImageView.highlighted = NO;
        self.thumbImageView.transform = CGAffineTransformIdentity;
        self.thumbImageView.layer.shadowOpacity = 0.f;
        
        newThumbCenterX = [touch locationInView:self].x - _thumbThouchOffsetX;
        
    }else{
        newThumbCenterX = [touch locationInView:self].x;
    }
    
    //限制在一定范围
    CGFloat thumbWidth = CGRectGetWidth(self.thumbImageView.bounds);
    CGFloat minX = TrackStartX(thumbWidth);
    CGFloat maxX = TrackEndX(thumbWidth);
    newThumbCenterX = ChangeInMinToMax(newThumbCenterX, minX , maxX);
    
    //计算对应的新值
    float newValue = [self _valueForThumbCenterX:newThumbCenterX];
    
    //更新位置
    [self _setValue:newValue animated:YES];
    
    _dragging = NO;
    
    //发送事件
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (_dragging) {
     
        _dragging = NO;
        
        self.thumbImageView.highlighted = NO;
        self.thumbImageView.layer.shadowOpacity = 0.f;
        self.thumbImageView.transform = CGAffineTransformIdentity;
        
        [self setNeedsLayout];
    }
}


- (CGPoint)pointInBarForValue:(CGFloat)value
{
    value = ChangeInMinToMax(value, _minValue, _maxValue);
    CGFloat thumbWidth = CGRectGetWidth(self.thumbImageView.bounds);
    
    return CGPointMake(TrackStartX(thumbWidth) + ValueToLength(value, thumbWidth) ,CGRectGetMidY(self.bounds));
}

- (CGPoint)centerPointForThumb
{
    return self.thumbImageView.center;
}

#pragma mark - other

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ||
        [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ||
             [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
        return !CGRectContainsPoint([self _thumbTouchRect], [gestureRecognizer locationInView:self]);
    }
    
    return YES;
}

- (CGSize)intrinsicContentSize
{
    CGSize thumbSize = self.thumbImageView.bounds.size;
    return CGSizeMake(DefaultBarLenght + thumbSize.width, thumbSize.height + 2 * TouchPadding);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize intrinsicContentSize = [self intrinsicContentSize];
    return CGSizeMake(MAX(intrinsicContentSize.width, size.width), intrinsicContentSize.height);
}

@end
