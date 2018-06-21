//
//  XYYSizeUtil.h
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYYBaseDef.h"


//像素转换为点
#define PiexlToPoint(_p)   ((_p) / [UIScreen mainScreen].scale)


//矩形中心
#define __CenterForRect_IMP__(_rect,L)  \
({ \
CGRect __NSX_PASTE__(__rect,L) = _rect; \
CGPointMake(CGRectGetMidX(__NSX_PASTE__(__rect,L)), CGRectGetMidY(__NSX_PASTE__(__rect,L))); \
})
#define CenterForRect(_rect) __CenterForRect_IMP__(_rect,__COUNTER__)


//获取内容矩形，单位量，0~1
#define __ContentsRectForRect_IMP__(_contentRect,_rect,L) \
({ \
CGRect __NSX_PASTE__(__rect,L) = _rect; \
CGRect __NSX_PASTE__(__contentRect,L) = _contentRect; \
CGFloat __NSX_PASTE__(__width,L) = CGRectGetWidth(__NSX_PASTE__(__rect,L));  \
CGFloat __NSX_PASTE__(__height,L) = CGRectGetHeight(__NSX_PASTE__(__rect,L)); \
CGRectMake(__NSX_PASTE__(__width,L)  ? CGRectGetMinX(__NSX_PASTE__(__contentRect,L)) / __NSX_PASTE__(__width,L) : 0.f,    \
__NSX_PASTE__(__height,L) ? CGRectGetMinY(__NSX_PASTE__(__contentRect,L)) / __NSX_PASTE__(__height,L) : 0.f,   \
__NSX_PASTE__(__width,L)  ? CGRectGetWidth(__NSX_PASTE__(__contentRect,L)) / __NSX_PASTE__(__width,L) : 0.f,   \
__NSX_PASTE__(__height,L) ? CGRectGetHeight(__NSX_PASTE__(__contentRect,L)) / __NSX_PASTE__(__height,L) : 0.f);\
})
#define ContentsRectForRect(_contentRect,_rect) __ContentsRectForRect_IMP__(_contentRect,_rect,__COUNTER__)

//是否是长图
#define __IS_LONGIMAGE__IMP__(_imageSize, _basicSize, _factor,L) \
({  \
CGSize __NSX_PASTE__(__imageSize,L) = _imageSize;   \
CGSize __NSX_PASTE__(__basicSize,L) = _basicSize;   \
BOOL __NSX_PASTE__(__bRet,L) = NO;  \
if(__NSX_PASTE__(__imageSize,L).width && __NSX_PASTE__(__basicSize,L).width &&              \
(__NSX_PASTE__(__imageSize,L).width  >= __NSX_PASTE__(__basicSize,L).width * 0.5f ||      \
__NSX_PASTE__(__imageSize,L).height >= __NSX_PASTE__(__basicSize,L).height) * 0.5f  ) {  \
__NSX_PASTE__(__bRet,L) = (__NSX_PASTE__(__imageSize,L).height / __NSX_PASTE__(__imageSize,L).width) >= \
((_factor) * (__NSX_PASTE__(__basicSize,L).height / __NSX_PASTE__(__basicSize,L).width));  \
}   \
__NSX_PASTE__(__bRet,L);    \
})
#define IS_LONGIMAGE(_imageSize, _basicSize, _factor)   __IS_LONGIMAGE__IMP__(_imageSize, _basicSize, _factor,__COUNTER__)
#define IS_LONGIMAGE_BASIC_SCREEN(_imageSize, _factor)  IS_LONGIMAGE(_imageSize, screenSize(), _factor)


//文本尺寸
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0

//单行文本尺寸
#define TEXTSIZE(text, font)   \
([text length] > 0 ? [text sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero)

//多行文本尺寸
#define MULTILINE_TEXTSIZE(text, font, maxSize, mode)  \
([text length] > 0 ? [text boundingRectWithSize:maxSize  \
options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) \
attributes:@{NSFontAttributeName           : font, \
NSForegroundColorAttributeName: [UIColor blackColor]} \
context:nil].size : CGSizeZero)

#else

#define TEXTSIZE(text, font)   \
([text length] > 0 ? [text sizeWithFont:font] : CGSizeZero)

#define MULTILINE_TEXTSIZE(text, font, maxSize, mode) \
([text length] > 0 ? [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero)

#endif


//缩放模式
typedef NS_ENUM(NSInteger, MyZoomMode){
    /**  不改变长宽比，缩放至合适大小 */
    MyZoomModeAspectFit  = 0,
    /**  不改变长宽比，缩放至合适大小填充 */
    MyZoomModeAspectFill = 1,
    /**  可能改变长宽比，缩放至填充 */
    MyZoomModeFill       = 2
};

//缩放选项
typedef NS_ENUM(NSInteger, MyZoomOption){
    //无选项
    MyZoomOptionNone,
    //即原尺寸大于缩放后的目标尺寸才缩放
    MyZoomOptionZoomIn,
    //即原尺寸小于缩放后的目标尺寸才缩放
    MyZoomOptionZoomOut
};

//比例的模式
typedef NS_ENUM(NSInteger, MyScaleMode){
    /** 基于当前比例,和当前比例一致 */
    MyScaleModeCurrent,
    /** 基于屏幕,和屏幕缩放比例一致 */
    MyScaleModeScreen,
    /** 基于像素，即比例为1 */
    MyScaleModePixel
};

//内容布局
typedef NS_ENUM(NSInteger,MyContentLayout) {
    MyContentLayoutCenter = 0,       //布局在中心
    MyContentLayoutTop    = 1 << 0,  //布局在上端，水平居中
    MyContentLayoutBottom = 1 << 1,  //布局在下端，水平居中
    MyContentLayoutLeft   = 1 << 2,  //布局在左端，竖直居中
    MyContentLayoutRight  = 1 << 3,  //布局在右端，竖直居中
    
    //左上
    MyContentLayoutLeftTop     = (MyContentLayoutLeft  | MyContentLayoutTop),
    //右上
    MyContentLayoutRightTop    = (MyContentLayoutRight | MyContentLayoutTop),
    //左下
    MyContentLayoutLeftBottom  = (MyContentLayoutLeft  | MyContentLayoutBottom),
    //右下
    MyContentLayoutRightBottom = (MyContentLayoutRight | MyContentLayoutBottom)
};



/**
 * 将原大小按具体模式缩放至基于目标大小
 * @param sourceSize sourceSize为源大小
 * @param targetSize targetSize为目标大小
 * @param zoomMode  zoomMode为缩放模式
 * @param zoomOption zoomOption为缩放选项，默认为MyZoomOptionNone
 * @return 返回缩放后的大小
 */
CGSize sizeZoomToTagetSize(CGSize sourceSize, CGSize targetSize, MyZoomMode zoomMode);
CGSize sizeZoomToTagetSize_extend(CGSize sourceSize, CGSize targetSize, MyZoomMode zoomMode, MyZoomOption zoomOption);


/**
 * 转换size到当前缩放比例的大小
 * @param size  size为大小
 * @param sizeScaleMode sizeScaleMode为size的比例模式
 * @param currentScale currentScale为当前的缩放比例
 * @return 返回转换后的size
 */
CGSize convertSizeToCurrentScale(CGSize size, MyScaleMode sizeScaleMode, CGFloat currentScale);


/**
 * 转换size从formScale到toScale
 * @param size size为大小
 * @param fromScale fromScale为尺寸的缩放比例
 * @param toScale toScale为目标的缩放比例
 * @return 返回转换后的size
 */
CGSize convertSizeToScale(CGSize size, CGFloat fromScale, CGFloat toScale);


static inline CGFloat convertLenghtToScale(CGFloat lenght,CGFloat fromScale, CGFloat toScale) {
    return (toScale ? fromScale / toScale : 0.f) * lenght;
}
static inline CGFloat convertLenghtToCurrentScale(CGFloat lenght, MyScaleMode sizeScaleMode, CGFloat currentScale)
{
    if (sizeScaleMode == MyScaleModeCurrent) {
        return lenght;
    }else {
        return convertLenghtToScale(lenght, (sizeScaleMode == MyScaleModeScreen) ? [UIScreen mainScreen].scale : 1.f, currentScale);
    }
}

static inline float degreesToRadians (float degrees) { return degrees * M_PI / 180;}
static inline float radiansToDegrees (float radians) { return radians * M_1_PI * 180;}
static inline CGRect CGRectAppendSize (CGRect rect,CGSize size) {
    rect.size.width += size.width;
    rect.size.height += size.height;
    return rect;
}


/**
 * 获取特定布局的内容矩形大小
 * @param rect rect为目标矩形，即内容矩形布局基于的矩形
 * @param contentSize contentSize为内容大小
 * @param contentLayout contentLayout为内容的布局方式具体取值请见枚举类型MyContentLayout的定义
 * @return 返回内容矩形
 */
CGRect contentRectForLayout(CGRect rect, CGSize contentSize, MyContentLayout contentLayout);




