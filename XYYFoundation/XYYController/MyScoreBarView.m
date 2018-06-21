//
//  MyScoreBarView.m
//
//
//  Created by LeslieChen on 14/12/10.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import "MyScoreBarView.h"
#import "XYYConst.h"
#import "UIImage+Tint.h"
#import "XYYSizeUtil.h"

//----------------------------------------------------------

#define MinTouchPadding  15
#define defaultScoreSize CGSizeMake(30.f,30.f)

//----------------------------------------------------------

@interface MyScoreBarView ()

//绘制用的值
@property(nonatomic) CGFloat drawValue;

//用于绘制的分数图片
@property(nonatomic,strong,readonly) UIImage * drawScoreImage;

@end

//----------------------------------------------------------

@implementation MyScoreBarView
{
    CGFloat _touchPanOffsetX;
    BOOL    _didCatchTouchForDragging;
}

@synthesize drawScoreImage = _drawScoreImage;

#pragma mark - life circle

- (id)init {
    return [self initWithMaxValue:5.f scoreTrackImage:nil scoreImage:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithMaxValue:5.f scoreTrackImage:nil scoreImage:nil];
    
    if (self) {
        self.frame = frame;
    }
    
    return self;
}

- (id)initWithMaxValue:(NSUInteger)maxValue {
    return [self initWithMaxValue:maxValue scoreTrackImage:nil scoreImage:nil];
}

- (id)initWithMaxValue:(NSUInteger)maxValue
       scoreTrackImage:(UIImage *)scoreTrackImage
            scoreImage:(UIImage *)scoreImage
{
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        [self _setup_MyScoreBarView];
        
        self.maxValue = maxValue;
        self.scoreTrackImage = scoreTrackImage;
        self.scoreImage = scoreImage;
        
        [self sizeToFit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyScoreBarView];
    }
    
    return self;
}

- (void)_setup_MyScoreBarView
{
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    self.maxValue = 5.f;
    self.stepValueInternal = 1.f;
    self.minMargin = 5.f;
    
    [self _registerKVO];
}

- (void)dealloc {
    [self _unregisterKVO];
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[@"scoreImage",
             @"scoreTrackImage",
             @"scoreTrackColor",
             @"scoreColor",
             @"minMargin",
             @"drawValue",
             @"drawScorePathBlock"];
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
    if ([keyPath isEqualToString:@"drawValue"]) {
        // do nothing
    }else if ([keyPath isEqualToString:@"scoreImage"]) {
        
        _drawScoreImage = nil;
        if (!self.scoreTrackImage || self.drawValue == 0) {
            return;
        }
        
    }else if ([keyPath isEqualToString:@"scoreTrackColor"]) {
        
        if (self.scoreTrackImage) {
            return;
        }
        
    }else if ([keyPath isEqualToString:@"scoreColor"]) {
        
        if (self.scoreTrackImage && !self.scoreImage) {
            _drawScoreImage = nil;
        }
        if (self.drawValue == 0 || (self.scoreTrackImage && self.scoreImage)) {
            return;
        }
        
    }else if ([keyPath isEqualToString:@"drawScorePathBlock"]){
        
        if (self.scoreTrackImage) {
            return;
        }
        
    }else if ([keyPath isEqualToString:@"minMargin"]) {
        
        [self invalidateIntrinsicContentSize];
        
    }else if ([keyPath isEqualToString:@"scoreTrackImage"]) {
        
        [self invalidateIntrinsicContentSize];
        if (!self.scoreImage) {
            _drawScoreImage = nil;
        }
    }
    
    [self setNeedsDisplay];
}

#pragma mark - value


#define StandardValue(_value,_standardFunc)     \
    (_stepValueInternal ? _standardFunc((_value) / _stepValueInternal) * _stepValueInternal : (_value))
#define StandardStepValue(_standardFunc)        \
    (_stepValueInternal && _maxValue ? _maxValue / _standardFunc(_maxValue / _stepValueInternal) : 0.f)


- (void)setMaxValue:(NSUInteger)maxValue
{
    if(_maxValue != maxValue){
        _maxValue = maxValue;
        
        _stepValueInternal = MIN(_stepValueInternal, _maxValue);
        _stepValueInternal = StandardStepValue(roundf);
        
        _value = MIN(_value, _maxValue);
        _value = StandardValue(_value,roundf);
        
        self.drawValue = _value;
    }
}

- (void)setStepValueInternal:(CGFloat)stepValueInternal
{
    stepValueInternal = MAX(0.f, stepValueInternal);
    
    if (_stepValueInternal != stepValueInternal) {
        _stepValueInternal = stepValueInternal;
        
        _stepValueInternal = MIN(_stepValueInternal, _maxValue);
        _stepValueInternal = StandardStepValue(roundf);
        
        _value = MIN(_value, _maxValue);
        _value = StandardValue(_value,roundf);
        
        self.drawValue = _value;
    }
}

- (void)setValue:(CGFloat)value
{
    value = MAX(0.f, value);
    
    if (_value != value) {
        _value = value;
        
        _value = MIN(_value, _maxValue);
        _value = StandardValue(_value,roundf);
        
        self.drawValue = _value;
    }
}


#pragma mark - UI

- (UIColor *)scoreColor
{
    if (!_scoreColor) {
        _scoreColor = ColorWithNumberRGB(0xF4821B);
    }
    
    return _scoreColor;
}

- (UIColor *)scoreTrackColor
{
    if (!_scoreTrackColor) {
        _scoreTrackColor = [UIColor lightGrayColor];
    }
    
    return _scoreTrackColor;
}

- (UIImage *)drawScoreImage
{
    if (!_drawScoreImage) {
        if (self.scoreImage) {
            _drawScoreImage = self.scoreImage;
        }else if (self.scoreTrackImage) {
            _drawScoreImage = [self.scoreTrackImage imageWithTintColor:self.scoreColor];
        }
    }
    
    return _drawScoreImage;
}


- (void)drawRect:(CGRect)rect
{
    NSUInteger scoreCount = self.maxValue;
    
    //无内容直接返回
    if (scoreCount == 0) {
        return;
    }
    
    //分数单元的大小
    CGSize scoreSectionSize = CGSizeMake(CGRectGetWidth(rect) / scoreCount - self.minMargin, CGRectGetHeight(rect));
    
    //小于0则忽略不进行绘制
    if (scoreSectionSize.width <= 0 || scoreSectionSize.height <= 0) {
        return;
    }
    
    //获取当前绘制上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //转换到原点（不是必需，因为rect的orgin应该为CGSizeZero）
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));

    //计算绘制大小
    CGSize scoreDrawSize;
    if (self.scoreTrackImage) { //绘制的是图片则通过图片大小进行重新计算绘制大小
        scoreDrawSize = sizeZoomToTagetSize_extend(self.scoreTrackImage.size, scoreSectionSize, MyZoomModeAspectFit,MyZoomOptionZoomIn);
    }else {
        scoreDrawSize = scoreSectionSize ;
    }
    
    //计算绘制的矩形
    CGRect drawRect = contentRectForLayout(CGRectMake(self.minMargin * 0.5f, 0.f, scoreSectionSize.width, scoreSectionSize.height), scoreDrawSize, MyContentLayoutCenter);
    
    CGFloat clipScoreValue = self.drawValue - 1;
    
    //开始绘制
    for (NSInteger i = 0; i < scoreCount; ++ i) {

        //保存上下文
        CGContextSaveGState(context);
        
        if (self.scoreTrackImage) { //绘制图片
            
            if (i  <= clipScoreValue) { //绘制分数
               [self.drawScoreImage drawInRect:drawRect];
            }else if(i > clipScoreValue) { //绘制轨迹
                [self.scoreTrackImage drawInRect:drawRect];
                
                //设置裁减并绘制分数
                if (i - 1 < clipScoreValue) {
                    
                    //设置裁减
                    CGRect clipRect = drawRect;
                    clipRect.size.width *= (clipScoreValue - i + 1);
                    CGContextClipToRect(context,clipRect);
                    
                    //绘制分数
                    [self.drawScoreImage drawInRect:drawRect];
                }
            }
            
        }else { //绘制路径
            
            //生成路径
            CGMutablePathRef scorePath = CGPathCreateMutable();
            [self _drawScorePath:scorePath rect:drawRect];
            
            if (i <= clipScoreValue) { //绘制分数
                
                //填充分数路径
                CGContextAddPath(context, scorePath);
                [self.scoreColor setFill];
                CGContextFillPath(context);
                
            }else if(i > clipScoreValue) { //绘制轨迹
                
                //填充轨迹路径
                CGContextAddPath(context, scorePath);
                [self.scoreTrackColor setFill];
                CGContextFillPath(context);
                
                //设置裁减并绘制分数
                if (i - 1 < clipScoreValue) {
                    
                    //设置裁减
                    CGRect clipRect = drawRect;
                    clipRect.size.width *= (clipScoreValue - i + 1);
                    CGContextClipToRect(context,clipRect);
                    
                    //填充分数路径
                    CGContextAddPath(context, scorePath);
                    [self.scoreColor setFill];
                    CGContextFillPath(context);
                }
            }
            
            //释放路径
            CGPathRelease(scorePath);
        }
        
        //恢复上下文状态
        CGContextRestoreGState(context);
        
        //偏移绘制矩形
        drawRect = CGRectOffset(drawRect, scoreSectionSize.width + self.minMargin, 0.f);
    }
}


- (void)_drawScorePath:(CGMutablePathRef)path rect:(CGRect)rect
{
    if (self.drawScorePathBlock) {
        self.drawScorePathBlock(path,rect);
    }else{
        
        //半径
        CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) * 0.5f;
        //中心
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        
        CGPathMoveToPoint(path, NULL, center.x, center.y - radius);
        
        for (NSInteger i = 1; i <= 4; ++ i) {
            CGFloat x = radius * sinf(i * 4.0 * M_PI / 5.0);
            CGFloat y = radius * cosf(i * 4.0 * M_PI / 5.0);
            CGPathAddLineToPoint(path, NULL, center.x - x, center.y - y);
        }
        
        //关闭路径
        CGPathCloseSubpath(path);
    }
}

#pragma mark - touch

#define LenghtForValue(_value) (CGRectGetWidth(self.bounds) / self.maxValue * (_value))
#define ValueForLenght(_lenght) (self.maxValue / CGRectGetWidth(self.bounds) * (_lenght))

//触摸响应的矩形
- (CGRect)_touchPanRespondRect
{
    //触摸偏移
    CGFloat touchPadding = LenghtForValue(self.stepValueInternal);
    touchPadding = MAX(MinTouchPadding, touchPadding);
    
    //获得当前值所在的位置
    CGFloat valueX = LenghtForValue(self.value);
    
    //返回触摸响应范围
    return CGRectMake(valueX - touchPadding, 0.f, touchPadding * 1.5f, CGRectGetHeight(self.bounds));
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //触摸点
    CGPoint touchPoint = [touch locationInView:self];
    //触摸响应矩形范围
    CGRect  touchPanRespondRect = [self _touchPanRespondRect];
    
    //触摸点在滑动响应区域则捕获触摸
    _didCatchTouchForDragging = CGRectContainsPoint(touchPanRespondRect, touchPoint);
    if (_didCatchTouchForDragging) { //记录触摸点和当前value的偏移
        _touchPanOffsetX = touchPoint.x - LenghtForValue(self.value);
    }
    
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_didCatchTouchForDragging) {
        _dragging = YES;
        
        //移动的新值的长度
        CGFloat newValueLenght = [touch locationInView:self].x - _touchPanOffsetX;
        CGFloat maxLenght = CGRectGetWidth(self.bounds);
        newValueLenght = ChangeInMinToMax(newValueLenght, 0.f, maxLenght);
        
        //计算绘制值
        self.drawValue = ValueForLenght(newValueLenght);
        
        if (self.continuous) {
        
            CGFloat newValue = StandardValue(self.drawValue, ceilf);
            
            if (self.value != newValue) {
                _value = newValue;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
                
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //计算新值的长度
    CGFloat newValueLenght;
    if (self.isDragging) {
        newValueLenght = [touch locationInView:self].x - _touchPanOffsetX;
    }else {
        newValueLenght = [touch locationInView:self].x;
    }
    newValueLenght = ChangeInMinToMax(newValueLenght, 0.f, CGRectGetWidth(self.bounds));
    
    //计算新值
    CGFloat newValue = ValueForLenght(newValueLenght);
    newValue = StandardValue(newValue, ceilf);
    
    //决定是否发送通知
    BOOL notifer = NO;
    if (!self.isDragging) {
        notifer = (newValue != self.value);
    }else {
        notifer = self.continuous || (self.value != newValue);
    }
    
    //更改值
    self.drawValue = _value = newValue;
    
    _dragging = NO;
    
    if (notifer) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (self.isDragging) {
        _dragging = NO;
        self.drawValue = self.value;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (!enabled && self.isDragging) {
        _dragging = NO;
        self.drawValue = self.value;
    }
}

#pragma mark - other

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ||
        [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ||
             [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
        return !CGRectContainsPoint([self _touchPanRespondRect], [gestureRecognizer locationInView:self]);
    }
    
    return YES;
}

- (CGSize)intrinsicContentSize
{
    CGSize scoreSize = defaultScoreSize;
    if (self.scoreTrackImage) {
        scoreSize = self.scoreTrackImage.size;
    }
    
    if (self.maxValue == 0) {
        return CGSizeZero;
    }else {
        return CGSizeMake((scoreSize.width + self.minMargin) * self.maxValue, scoreSize.height);
    }
}

- (CGSize)sizeThatFits:(CGSize)size{
    return [self intrinsicContentSize];
}

@end
