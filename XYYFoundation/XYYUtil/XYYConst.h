//
//  XYYConst.h
//  XYYKit
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "XYYBaseDef.h"

#ifndef XYYConst_h
#define XYYConst_h

//常量
//----------------------------------------------------------

#define SecPerDay                               86400.0
#define SecPerHour                              3600.0
#define MinPerHour                              60.0
#define SecPerMin                               MinPerHour
#define DayForTimeInterval(_time)               floor((_time) / SecPerDay)
#define HourForTimeInterval(_time)              floor((_time) / SecPerHour)
#define MinForTimeInterval(_time)               floor((_time) / SecPerMin)


//数字相关
//----------------------------------------------------------

//_num2除以_num1是否整除
#define __IsIntrgerDivision_IMP__(_num1, _num2, L) \
({ \
typeof(_num1) __NSX_PASTE__(__num1,L) = _num1; \
typeof(_num2) __NSX_PASTE__(__num2,L) = _num2; \
floorf(__NSX_PASTE__(__num1,L) / __NSX_PASTE__(__num2,L)) == \
(((double)__NSX_PASTE__(__num1,L)) / __NSX_PASTE__(__num2,L)); \
})
#define IsIntrgerDivision(_num1,_num2) __IsIntrgerDivision_IMP__(_num1, _num2, __COUNTER__)


//改变到范围内
#define ChangeInMinToMax(_value,_min,_max)  MAX(MIN(_value,_max),_min)


//随机数
//----------------------------------------------------------

#define RANDOM_INT(_MIN, _MAX)   ((_MIN) + arc4random() % ((_MAX) - (_MIN) + 1))
#define RANDOM_FLOAT(_MIN, _MAX) ((_MIN) + RANDOM_0_1() * ((_MAX) - (_MIN)))
#define RANDOM_0_1()             ((double)arc4random() / UINT32_MAX)


//颜色相关
//----------------------------------------------------------


//颜色创建
#define ColorWithRGBA(int_r,int_g,int_b,_alpha)  \
[UIColor colorWithRed:(int_r)/255.0 green:(int_g)/255.0 blue:(int_b)/255.0 alpha:_alpha]

//通过数字初始化颜色
#define ColorWithNumberRGBA(_hex,_alpha) ColorWithRGBA(((_hex)>>16)&0xFF,((_hex)>>8)&0xFF,(_hex)&0xFF,_alpha)
#define ColorWithNumberRGB(_hex) ColorWithNumberRGBA(_hex,1.f)

#define ColorWithWhite(int_w,_alpha) [UIColor colorWithWhite:(int_w)/255.0 alpha:_alpha]
#define BlackColorWithAlpha(_alpha) ColorWithWhite(0,_alpha)

//生成随机颜色
#define RANDOM_COLOR(_alpha) [UIColor colorWithRed:RANDOM_0_1() \
green:RANDOM_0_1() \
blue:RANDOM_0_1() \
alpha:_alpha]


#endif /* XYYConst_h */
