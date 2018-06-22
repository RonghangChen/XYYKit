//
//  XYYSizeUtil.m
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "XYYSizeUtil.h"


CGSize sizeZoomToTagetSize(CGSize sourceSize, CGSize targetSize, MyZoomMode zoomMode)
{
    CGSize resultSize = targetSize;
    
    if (zoomMode != MyZoomModeFill) {
        
        //计算长宽压缩比例
        CGFloat widthFactor  = sourceSize.width  ? fabs(targetSize.width  / sourceSize.width)  : 0.f;
        CGFloat heightFactor = sourceSize.height ? fabs(targetSize.height / sourceSize.height) : 0.f;
        
        //当长宽压缩比例很接近可认为等比例压缩，绘制大小直接等于目标大小
        if (fabs(widthFactor - heightFactor) > 0.000001) {
            
            //计算绘制的尺寸（不使用缩放比例相乘是为了避免不必要的背景色）
            if (zoomMode == MyZoomModeAspectFit) {
                if (widthFactor < heightFactor) {
                    resultSize.height = sourceSize.height * widthFactor;
                }else {
                    resultSize.width  = sourceSize.width * heightFactor;
                }
            }else {
                if (widthFactor > heightFactor) {
                    resultSize.height = sourceSize.height * widthFactor;
                }else {
                    resultSize.width  = sourceSize.width * heightFactor;
                }
            }
        }
    }
    
    return resultSize;
}

CGSize sizeZoomToTagetSize_extend(CGSize sourceSize, CGSize targetSize, MyZoomMode zoomMode, MyZoomOption zoomOption)
{
    CGSize size = sizeZoomToTagetSize(sourceSize, targetSize, zoomMode);
    
    switch (zoomOption) {
        case MyZoomOptionZoomIn:
            
            //缩放后的尺寸小于原尺寸，才有效
            if (size.width > sourceSize.width &&
                size.height > sourceSize.height) {
                size = sourceSize;
            }
            
            break;
            
        case MyZoomOptionZoomOut:
            
            //缩放后的尺寸大于原尺寸，才有效
            if (size.width < sourceSize.width &&
                size.height < sourceSize.height) {
                size = sourceSize;
            }
            
            break;
            
        default:
            break;
    }
    
    return size;
}

CGSize convertSizeToCurrentScale(CGSize size, MyScaleMode sizeScaleMode, CGFloat currentScale)
{
    if (sizeScaleMode == MyScaleModeCurrent) {
        return size;
    }else {
        return convertSizeToScale(size, (sizeScaleMode == MyScaleModeScreen) ? [UIScreen mainScreen].scale : 1.f, currentScale);
    }
}

CGSize convertSizeToScale(CGSize size, CGFloat fromScale, CGFloat toScale)
{
    if (fromScale == toScale) {
        return size;
    }else {
        CGFloat scaleFator = toScale ?  fromScale / toScale : 0.f;
        return CGSizeMake(size.width * scaleFator, size.height * scaleFator);
    }
}

#pragma mark -

CGRect contentRectForLayout(CGRect rect, CGSize contentSize, MyContentLayout contentLayout)
{
    //原点
    CGPoint origin = CGPointZero;
    
    //水平
    if (contentLayout & MyContentLayoutLeft) {
        origin.x = CGRectGetMinX(rect);
    }else if(contentLayout & MyContentLayoutRight){
        origin.x = CGRectGetMaxX(rect) - contentSize.width;
    }else{
        origin.x = CGRectGetMinX(rect) + (CGRectGetWidth(rect) - contentSize.width) * 0.5f;
    }
    
    //竖直
    if (contentLayout & MyContentLayoutTop) {
        origin.y = CGRectGetMinY(rect);
    }else if(contentLayout & MyContentLayoutBottom){
        origin.y = CGRectGetMaxY(rect) - contentSize.height;
    }else{
        origin.y = CGRectGetMinY(rect) + (CGRectGetHeight(rect) - contentSize.height) * 0.5f;
    }
    
    return CGRectMake(origin.x, origin.y, contentSize.width, contentSize.height);
}


