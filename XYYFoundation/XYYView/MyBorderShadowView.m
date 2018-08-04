//
//  MyBorderShadowView.m
//  leslie
//
//  Created by 陈荣航 on 2017/3/28.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "MyBorderShadowView.h"

@implementation MyBorderShadowView

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showShadow) {
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(UIEdgeInsetsInsetRect(self.bounds, self.shadowBorderInset), self.shadowBorderOffset.x,  self.shadowBorderOffset.y) cornerRadius: self.shadowBorderRadius].CGPath;
    }else {
        self.layer.shadowPath = nil;
    }
}


@end
