//
//  UIView+IBDesignable.m
//  
//
//  Created by 陈荣航 on 16/5/17.
//  Copyright © 2016年 ED. All rights reserved.
//

#import "UIView+IBDesignable.h"

@implementation UIView (IBDesignable)

- (void)setIbBorderColor:(UIColor *)ibBorderColor {
    self.layer.borderColor = [ibBorderColor CGColor];
}
- (UIColor *)ibBorderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setIbBorderWidth:(CGFloat)ibBorderWidth {
    self.layer.borderWidth = ibBorderWidth;
}
- (CGFloat)ibBorderWidth {
    return self.layer.borderWidth;
}

- (void)setIbCornerRadius:(CGFloat)ibCornerRadius {
    self.layer.cornerRadius = ibCornerRadius;
}
- (CGFloat)ibCornerRadius {
    return self.layer.cornerRadius;
}

- (void)setIbCenterPoint:(CGPoint)ibCenterPoint {
    self.center = ibCenterPoint;
}

- (CGPoint)ibCenterPoint {
    return self.center;
}


@end
