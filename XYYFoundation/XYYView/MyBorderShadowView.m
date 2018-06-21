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

- (CGFloat)shadowOpacity {
    return self.layer.shadowOpacity;
}
- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    self.layer.shadowOpacity = shadowOpacity;
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
