//
//  UIView+IBDesignable.h
//  
//
//  Created by 陈荣航 on 16/5/17.
//  Copyright © 2016年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface UIView (IBDesignable)

@property(nonatomic,assign) IBInspectable CGFloat   ibCornerRadius;
@property(nonatomic,assign) IBInspectable CGFloat   ibBorderWidth;
@property(nonatomic,assign) IBInspectable UIColor * ibBorderColor;
@property(nonatomic,assign) IBInspectable CGPoint ibCenterPoint;

@end
