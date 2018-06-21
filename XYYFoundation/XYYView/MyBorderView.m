//
//  MyBorderView.m

//
//  Created by LeslieChen on 15/2/28.
//  Copyright (c) 2015年 ED. All rights reserved.
//


//----------------------------------------------------------

#import "MyBorderView.h"
#import "ScreenAdaptation.h"
#import "XYYSizeUtil.h"

//----------------------------------------------------------

@implementation MyBorderView
{
    CALayer * _borderLayer;
}

@synthesize borderStyle = _borderStyle;
@synthesize borderMask = _borderMask;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize borderInset = _borderInset;
@synthesize borderLineInset = _borderLineInset;
@synthesize borderLineScaleInset = _borderLineScaleInset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initBorderView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initBorderView];
    }
    
    return self;
}

- (void)_initBorderView {
    self.borderWidth = PiexlToPoint(1.f);
}

#pragma mark -

#define IMP_MUTATOR(mutator, ctype, member, selector) \
- (void)mutator (ctype)value \
{ \
    if(member != value){ \
        member = value; \
        if(selector){ \
            [self performSelector:selector withObject:nil];\
        }\
    }\
}

IMP_MUTATOR(setBorderMask:, MyBorderMask, _borderMask, @selector(setNeedsLayout))
IMP_MUTATOR(setBorderColor:, UIColor *, _borderColor, @selector(setNeedsLayout))
IMP_MUTATOR(setBorderStyle:, MyLineStyle, _borderStyle, @selector(setNeedsLayout))
IMP_MUTATOR(setBorderWidth:, CGFloat, _borderWidth, @selector(setNeedsLayout))

- (void)setBoderInset:(UIEdgeInsets)borderInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderInset,borderInset)) {
        _borderInset = borderInset;
        [self setNeedsLayout];
    }
}

- (void)setBoderLineInset:(UIEdgeInsets)borderLineInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderLineInset,borderLineInset)) {
        _borderLineInset = borderLineInset;
        [self setNeedsLayout];
    }
}

- (void)setBorderLineScaleInset:(UIEdgeInsets)borderLineScaleInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderLineScaleInset,borderLineScaleInset)) {
        _borderLineScaleInset = borderLineScaleInset;
        [self setNeedsLayout];
    }
}

- (UIColor *)borderColor {
    return _borderColor ?: [UIColor blackColor];
}

#pragma mark -

- (BOOL)showTopBorder {
    return _borderMask & MyBorderTop;
}

- (void)setShowTopBorder:(BOOL)showTopBorder
{
    if (showTopBorder) {
        self.borderMask |= MyBorderTop;
    }else {
        self.borderMask = _borderMask & (~MyBorderTop);
    }
}

- (BOOL)showLeftBorder {
    return _borderMask & MyBorderLeft;
}

- (void)setShowLeftBorder:(BOOL)showLeftBorder
{
    if (showLeftBorder) {
        self.borderMask |= MyBorderLeft;
    }else {
        self.borderMask = _borderMask & (~MyBorderLeft);
    }
}

- (BOOL)showBottomBorder {
    return _borderMask & MyBorderBottom;
}

- (void)setShowBottomBorder:(BOOL)showBottomBorder
{
    if (showBottomBorder) {
        self.borderMask |= MyBorderBottom;
    }else {
        self.borderMask = _borderMask & (~MyBorderBottom);
    }
}

- (BOOL)showRightBorder {
    return _borderMask & MyBorderRight;
}

- (void)setShowRightBorder:(BOOL)showRightBorder
{
    if (showRightBorder) {
        self.borderMask |= MyBorderRight;
    }else {
        self.borderMask = _borderMask & (~MyBorderRight);
    }
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _updateBorder_MyBorderView];
}

- (void)_updateBorder_MyBorderView
{
    _borderLayer.sublayers = nil;
    [_borderLayer removeFromSuperlayer];

    if (self.borderMask == MyBorderNone || self.borderWidth <= 0.f) {
        return;
    }
    
    if (!_borderLayer) {
        _borderLayer = [CALayer layer];
    }
    
    [self.layer addSublayer:_borderLayer];

    CGRect borderContainerRect = UIEdgeInsetsInsetRect(self.bounds, self.borderInset);
    borderContainerRect.size.width = MAX(0.f, borderContainerRect.size.width);
    borderContainerRect.size.height = MAX(0.f, borderContainerRect.size.height);
    
    MyBorderMask mask[4] = {
                    MyBorderTop,
                    MyBorderBottom,
                    MyBorderLeft,
                    MyBorderRight};
    
    for (int i = 0; i < 4; ++ i) {
        
        if (self.borderMask & mask[i]) {
            
            CGPoint startPoint = CGPointZero;
            CGPoint endPoint = CGPointZero;
            
            if (mask[i] == MyBorderTop || mask[i] == MyBorderBottom) {
                
                CGFloat width = CGRectGetWidth(borderContainerRect);
                startPoint.x = CGRectGetMinX(borderContainerRect) + self.borderLineInset.left + self.borderLineScaleInset.left * width;
                endPoint.x = CGRectGetMaxX(borderContainerRect) - self.borderLineInset.right - self.borderLineScaleInset.right * width;
                
                if (startPoint.x >= endPoint.x) {
                    continue;
                }
                
                if (mask[i] == MyBorderTop) {
                    startPoint.y = CGRectGetMinY(borderContainerRect) + self.borderWidth * 0.5f;
                }else{
                    startPoint.y  = CGRectGetMaxY(borderContainerRect) - self.borderWidth * 0.5f;
                }
                
                endPoint.y = startPoint.y;
                
            }else{
                
                CGFloat height = CGRectGetHeight(borderContainerRect);
                startPoint.y = CGRectGetMinY(borderContainerRect) + self.borderLineInset.top + self.borderLineScaleInset.top * height;
                endPoint.y = CGRectGetMaxY(borderContainerRect) - self.borderLineInset.bottom - self.borderLineScaleInset.bottom * height;
                
                if (startPoint.y >= endPoint.y) {
                    continue;
                }
                
                if (mask[i] == MyBorderLeft) {
                    startPoint.x = CGRectGetMinX(borderContainerRect) + self.borderWidth * 0.5f;
                }else{
                    startPoint.x  = CGRectGetMaxX(borderContainerRect) - self.borderWidth * 0.5f;
                }
                
                endPoint.x = startPoint.x;
            }
            
            MyLineLayer * borderLineLayer = [MyLineLayer layer];
            borderLineLayer.lineStyle = self.borderStyle;
            borderLineLayer.lineWidth = self.borderWidth;
            borderLineLayer.lineColor = self.borderColor;
            borderLineLayer.startPoint = startPoint;
            borderLineLayer.endPoint = endPoint;
            
            [_borderLayer addSublayer:borderLineLayer];
            
        }
    }
}

@end
