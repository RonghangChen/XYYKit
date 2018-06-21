//
//  MyBadgeView.m
//
//
//  Created by LeslieChen on 14/11/10.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import "MyBadgeView.h"
#import "XYYConst.h"
#import "NSString+Extend.h"

//----------------------------------------------------------

@interface MyBadgeView ()

@property(nonatomic,strong,readonly) UILabel * bageLabel;

//点击手势
@property(nonatomic,strong,readonly) UITapGestureRecognizer * tapGestureRecognizer;
////忽视布局
//@property(nonatomic) BOOL ignoreLayout;

@end

//----------------------------------------------------------

@implementation MyBadgeView
{
    //显示动画的掩码，用来标识当前动画，判断是否中途结束
    NSString * _show_animation_mask;
}

@synthesize bageLabel = _bageLabel;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

#pragma mark - life circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_MyBadgeView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyBadgeView];
    }
    
    return self;
}

- (void)_setup_MyBadgeView
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    self.clipsToBounds = NO;
    
    _minBadgeRadius      = 5.f;
    _maxBadgeCharLength  = NSUIntegerMax;
    _badgeAnchorPoint    = CGPointMake(0.5f, 0.5f);
    _locationAnchorPoint = CGPointMake(1.f, 0.f);
    
    [self _registerKVO];
}


- (void)dealloc {
    [self _unregisterKVO];
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[@"showBadge",
             @"badgeValue",
             @"badgeColor",
             @"badgeBGColor",
             @"badgeFont",
             @"minBadgeRadius",
             @"maxBadgeCharLength",
             @"badgeAnchorPoint",
             @"locationAnchorPoint",
             @"locationOffset"];
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
    if (object == self && ![change[@"old"] isEqual:change[@"new"]]) {
        
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
    if ([keyPath isEqualToString:@"badgeValue"]){
        _bageLabel.text = self.badgeValue;
    }else if ([keyPath isEqualToString:@"badgeFont"]){
        _bageLabel.font = self.badgeFont;
    }else if ([keyPath isEqualToString:@"badgeColor"]){
        _bageLabel.textColor = self.badgeColor;
        return;
    }else if ([keyPath isEqualToString:@"badgeBGColor"]) {
        _bageLabel.backgroundColor = self.badgeBGColor;
        return;
    }
    
    [self setNeedsLayout];
}

#pragma mark - draw UI

- (UIColor *)badgeColor{
    return _badgeColor ?: [UIColor whiteColor];
}

- (UIColor *)badgeBGColor{
    return _badgeBGColor ?: ColorWithNumberRGB(0xf33630);
}

- (UIFont *)badgeFont{
    return _badgeFont ?: [UIFont systemFontOfSize:10.f];
}

#pragma mark - layout

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];

    if (self.superview) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        super.frame = self.superview.bounds;
    }
}

- (UILabel *)bageLabel
{
    if (!_bageLabel) {
        _bageLabel = [[UILabel alloc] init];
        _bageLabel.hidden = !self.showBadge;
        _bageLabel.textAlignment = NSTextAlignmentCenter;
        _bageLabel.clipsToBounds = YES;
        _bageLabel.text = self.badgeValue;
        _bageLabel.font = self.badgeFont;
        _bageLabel.textColor = self.badgeColor;
        _bageLabel.backgroundColor = self.badgeBGColor;
        
        [self addSubview:_bageLabel];
    }
    
    return _bageLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showBadge) {
        
        self.bageLabel.frame = [self _badgeRectForRect:self.bounds textRect:NULL];
        self.bageLabel.layer.cornerRadius = CGRectGetHeight(self.bageLabel.bounds) * 0.5f;
    }
}

- (CGRect)_badgeRectForRect:(CGRect)rect textRect:(CGRect *)pTextRect
{
    CGRect badgeRect = CGRectZero, textRect = CGRectZero;
    
    if (self.badgeValue.length) {
        
        NSString * badgeValue = self.badgeValue;
        if (self.badgeValue.length > self.maxBadgeCharLength) {
            badgeValue = [badgeValue substringToIndex:self.maxBadgeCharLength];
        }
        
        CGSize badgeValueSize =  [self.bageLabel intrinsicContentSize];
        textRect.size = badgeValueSize;
        
        if (badgeValue.length == 1) {
            CGFloat max = MAX(badgeValueSize.width, badgeValueSize.height) * M_SQRT2;
            badgeValueSize.height = max;
            badgeValueSize.width  = max;
        }else{
            CGFloat addLength = badgeValueSize.height * (M_SQRT2 - 1);
            badgeValueSize.width  += 2 * addLength;
            badgeValueSize.height += addLength;
            badgeValueSize.width = MAX(badgeValueSize.width, badgeValueSize.height);
        }
        
        badgeValueSize.height = ceilf(MAX(2 * self.minBadgeRadius, badgeValueSize.height));
        badgeValueSize.width  = ceilf(MAX(2 * self.minBadgeRadius, badgeValueSize.width));
        
        badgeRect.size = badgeValueSize;
    }else{
        badgeRect.size = CGSizeMake(2 * self.minBadgeRadius, 2 * self.minBadgeRadius);
    }
    
    badgeRect.origin.x = CGRectGetMinX(rect) + self.locationOffset.x + self.locationAnchorPoint.x * CGRectGetWidth(rect) - self.badgeAnchorPoint.x * CGRectGetWidth(badgeRect);
    badgeRect.origin.y = CGRectGetMinY(rect) + self.locationOffset.y + self.locationAnchorPoint.y * CGRectGetHeight(rect) - self.badgeAnchorPoint.y * CGRectGetHeight(badgeRect);
    
    if (pTextRect != NULL) {
        textRect.origin.x = (CGRectGetWidth(badgeRect)  - CGRectGetWidth(textRect)) * 0.5f;
        textRect.origin.y = (CGRectGetHeight(badgeRect) - CGRectGetHeight(textRect)) * 0.5f;
        *pTextRect = textRect;
    }
    
    return badgeRect;
}

#pragma mark -

- (void)vibrate {
    [self vibrateWithDuration:0.4f];
}

- (void)vibrateWithDuration:(NSTimeInterval)duration
{
    if(self.showBadge && !self.isHidden && self.alpha > 0.01f){
        
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"transform.scale";
        animation.duration = duration;
        animation.values = @[@(1.f),@(0.3f),@(1.2f),@(1.f)];
        animation.keyTimes = @[@(0.f),@(0.0f),@(0.5f),@(0.5f)];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.bageLabel.layer addAnimation:animation forKey:nil];
    }
}

#pragma mark -

- (void)setShowBadge:(BOOL)showBadge {
    [self setShowBadge:showBadge animated:NO completedBlock:nil];
}

- (void)setShowBadge:(BOOL)showBadge animated:(BOOL)animated completedBlock:(void(^)(void))completedBlock
{
    if (_showBadge != showBadge) {
        _showBadge = showBadge;
        
        //还原
//        self.ignoreLayout = NO;
        self.bageLabel.transform = CGAffineTransformIdentity;
        
        if (!animated) {
            _show_animation_mask = nil;
            _bageLabel.hidden = !showBadge;
            
            if (completedBlock) {
                completedBlock();
            }
            
        }else {
            
            //更新布局
            [self layoutIfNeeded];
            
//            self.ignoreLayout = YES;
            
            //初始化scale
            if (showBadge) {
                _bageLabel.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                _bageLabel.hidden = NO;
            }
            
            //记录动画标识
            NSString * mask = [NSString uniqueIDString];
            _show_animation_mask = mask;
            
            [UIView animateWithDuration:0.2f
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 
                                 _bageLabel.transform = _showBadge ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.01f, 0.01f);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 if (![_show_animation_mask isEqualToString:mask]) { //当前动画被中途终止，直接返回
                                     return;
                                 }
                                 
//                                 self.ignoreLayout = NO;
                                 _bageLabel.transform = CGAffineTransformIdentity;
                                 _bageLabel.hidden = !_showBadge;
                                 
                                 if (completedBlock) {
                                     completedBlock();
                                 }
                                 
                             }];
        }
    }
}

- (void)setCanTapDisappear:(BOOL)canTapDisappear
{
    self.userInteractionEnabled = canTapDisappear;
    
    if (canTapDisappear) {
        self.tapGestureRecognizer.enabled = YES;
    }else {
        _tapGestureRecognizer.enabled = NO;
    }
}

- (BOOL)canTapDisappear {
    return self.userInteractionEnabled;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return _bageLabel && !_bageLabel.isHidden &&
           CGRectContainsPoint(UIEdgeInsetsInsetRect(_bageLabel.frame, self.tapDisappearInsets), point);
}


- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHandle)];
        _tapGestureRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    
    return _tapGestureRecognizer;
}


- (void)_tapGestureHandle
{
    //判断是否响应点击
    BOOL bRet = YES;
    id<MyBadgeViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(badgeViewShouldTapDisappear:)) {
        bRet = [delegate badgeViewShouldTapDisappear:self];
    }
    
    if (bRet) {
        
        typeof(self) __weak weak_self = self;
        [self setShowBadge:NO animated:YES completedBlock:^{
            ifRespondsSelector(delegate, @selector(badgeViewDidTapDisappear:)) {
                [delegate badgeViewDidTapDisappear:weak_self];
            }
        }];
    }
}

@end

//----------------------------------------------------------

@implementation UIView (MyBadgeView)

- (MyBadgeView *)badgeView
{
    if ([self isKindOfClass:[MyBadgeView class]]) {
        return (MyBadgeView *)self;
    }
    
    for (UIView * view in self.subviews.reverseObjectEnumerator) {
        MyBadgeView * badgeView = [view badgeView];
        if (badgeView != nil) {
            return badgeView;
        }
    }
    
    return nil;
}

- (void)vibrateBadgeView {
    [self vibrateBadgeViewWithDuration:0.4f];
}

- (void)vibrateBadgeViewWithDuration:(NSTimeInterval)duration
{
    if ([self isKindOfClass:[MyBadgeView class]]) {
        [(MyBadgeView *)self vibrateWithDuration:duration];
    }
    
    for (UIView * view in self.subviews) {
        if (!view.isHidden && view.alpha > 0.01f) {
            [view vibrateBadgeViewWithDuration:duration];
        }
    }
}

@end

