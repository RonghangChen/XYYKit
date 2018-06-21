//
//  UIImage+XYYExtend.m
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "UIImage+XYYExtend.h"
#import "ScreenAdaptation.h"

@implementation UIImage (XYYExtend)

//截取视图
+ (UIImage *)snapshotImageWithView:(UIView *)view
{
    if (view) {
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
        
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return nil;
}


//返回大小可变的某颜色的图片
+ (UIImage *)resizableImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.f, 1.f), NO, 0);
    
    [color setFill];
    UIRectFill(CGRectMake(0.f, 0.f, 1.f, 1.f));
    
    UIImage * image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    UIGraphicsEndImageContext();
    
    return image;
}

//获取闪屏图片
+ (UIImage *)getLaunchImage {
    return [self getLaunchImageWithSize:screenSize() orientation:UIInterfaceOrientationPortrait];
}

+ (UIImage *)getLaunchImageWithSize:(CGSize)size orientation:(UIInterfaceOrientation)orientation
{
    NSString * orientationStr = nil;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        orientationStr = @"Portrait";
    }else if (UIInterfaceOrientationIsLandscape(orientation)) {
        orientationStr = @"Landscape";
    }
    
    if (orientationStr) {
        NSArray* launchImagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
        for (NSDictionary * dict in launchImagesDict)  {
            if (CGSizeEqualToSize(CGSizeFromString(dict[@"UILaunchImageSize"]), size) &&
                [orientationStr isEqualToString:dict[@"UILaunchImageOrientation"]]) {
                return [UIImage imageNamed:dict[@"UILaunchImageName"]];
            }
        }
    }
    
    return nil;
}


@end
