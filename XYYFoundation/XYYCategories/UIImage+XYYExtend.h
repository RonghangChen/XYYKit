//
//  UIImage+XYYExtend.h
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XYYExtend)

//截取视图
+ (UIImage *)snapshotImageWithView:(UIView *)view;
//返回大小可变的某颜色的图片
+ (UIImage *)resizableImageWithColor:(UIColor *)color;

//获取闪屏图片
+ (UIImage *)getLaunchImage;
+ (UIImage *)getLaunchImageWithSize:(CGSize)size orientation:(UIInterfaceOrientation)orientation;

@end
