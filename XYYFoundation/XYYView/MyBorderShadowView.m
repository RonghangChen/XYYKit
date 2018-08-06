//
//  MyBorderShadowView.m
//  leslie
//
//  Created by 陈荣航 on 2017/3/28.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "MyBorderShadowView.h"

@implementation MyBorderShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shadowCorner = UIRectCornerAllCorners;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _shadowCorner = UIRectCornerAllCorners;
    }
    
    return self;
}


- (UIColor *)shadowColor {
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}
- (void)setShadowColor:(UIColor *)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
}

- (CGSize)shadowOffset {
    return self.layer.shadowOffset;
}
- (void)setShadowOffset:(CGSize)shadowOffset {
    self.layer.shadowOffset = shadowOffset;
}

- (CGFloat)shadowRadius {
    return self.layer.shadowRadius;
}
- (void)setShadowRadius:(CGFloat)shadowRadius {
    self.layer.shadowRadius = shadowRadius;
}


- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    if (_shadowOpacity != shadowOpacity) {
        _shadowOpacity = shadowOpacity;
        self.layer.shadowOpacity = self.showShadow ? shadowOpacity : 0.f;
    }
}

- (void)setShowShadow:(BOOL)showShadow
{
    if (_showShadow != showShadow) {
        _showShadow = showShadow;
        [self setNeedsLayout];
        self.layer.shadowOpacity = showShadow ? self.shadowOpacity : 0.f;
    }
}

- (void)setShadowBorderInset:(UIEdgeInsets)shadowBorderInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_shadowBorderInset, shadowBorderInset)) {
        _shadowBorderInset = shadowBorderInset;
        [self setNeedsLayout];
    }
}

- (void)setShadowBorderOffset:(CGPoint)shadowBorderOffset
{
    if (CGPointEqualToPoint(_shadowBorderOffset, shadowBorderOffset)) {
        _shadowBorderOffset = shadowBorderOffset;
        [self setNeedsLayout];
    }
}

- (void)setShadowBorderRadius:(CGFloat)shadowBorderRadius
{
    if (_shadowBorderRadius != shadowBorderRadius) {
        _shadowBorderRadius = shadowBorderRadius;
        [self setNeedsLayout];
    }
}

#pragma mark -

- (void)setShadowCorner:(UIRectCorner)shadowCorner
{
    if (_shadowCorner != shadowCorner) {
        _shadowCorner = shadowCorner;
        [self setNeedsLayout];
    }
}

#define IMP_CORNER_PROPERTY(name) \
- (void)setShow##name##ShadowCorner:(BOOL)show\
{\
    if (show) {\
        self.shadowCorner |= UIRectCorner##name;\
    }else {\
        self.shadowCorner &= (~UIRectCorner##name);\
    }\
}\
- (BOOL)show##name##ShadowCorner {\
    return _shadowCorner & UIRectCorner##name;\
}

IMP_CORNER_PROPERTY(TopLeft)
IMP_CORNER_PROPERTY(TopRight)
IMP_CORNER_PROPERTY(BottomLeft)
IMP_CORNER_PROPERTY(BottomRight)

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showShadow) {
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(UIEdgeInsetsInsetRect(self.bounds, self.shadowBorderInset), self.shadowBorderOffset.x,  self.shadowBorderOffset.y) byRoundingCorners:self.shadowCorner cornerRadii:CGSizeMake(self.shadowBorderRadius, self.shadowBorderRadius)].CGPath;
    }else {
        self.layer.shadowPath = nil;
    }
}


@end
