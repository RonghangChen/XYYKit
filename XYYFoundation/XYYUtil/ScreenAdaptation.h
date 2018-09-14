//
//  testtt.h

//
//  Created by LeslieChen on 15/2/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

//系统版本
#define SystemVersion systemVersion()

#define GreaterThanSystem(_version) (systemVersion() >= (_version))
//#define GreaterThanIOS6System       GreaterThanSystem(6.f)
//#define GreaterThanIOS7System       GreaterThanSystem(7.f)
#define GreaterThanIOS8System       GreaterThanSystem(8.f)
#define GreaterThanIOS9System       GreaterThanSystem(9.f)
#define GreaterThanIOS10System      GreaterThanSystem(10.f)

//---------------------------------------------

//状态栏高度（正常）
#define StatusBarHeight         20.f
//导航栏高度（正常）
#define NavigationBarHeight     44.f
//tab栏高度（正常）
#define TabBarHeight            49.f

//----------屏幕尺寸及适配相关--------------
//----------------------------------------------------------

/*
 *获取系统版本
 */
float systemVersion(void);

/*
 *获取屏幕尺寸
 */
CGSize screenSize(void);

//配置内容滑动视图(用于适配)
void configurationContentScrollViewForAdaptation(UIScrollView * scrollView);

//---------------------------------------------

//屏幕尺寸类型
typedef NS_ENUM(int,MyScreenSizeType) {
    //iPhone4屏幕尺寸（资源后缀包括@iPhone4,@smallsmall,@small_small,优先级依次降低）
    MyScreenSizeTypeiPhone4 = 0,
    //iPhone5/5s屏幕尺寸（资源后缀包括@small）
    MyScreenSizeTypeSmall,
    //iPhone6-8屏幕尺寸（资源后缀包括@middle）
    MyScreenSizeTypeMiddle,
    //iPhoneX屏幕尺寸（资源后缀包括@iPhoneX,@middle,优先级依次降低）
    MyScreenSizeTypeiPhoneX,
    //iPhone6-8Plus屏幕尺寸（资源后缀包括@big）
    MyScreenSizeTypeBig,
    //iPhoneXS MAX屏幕尺寸（资源后缀包括@iPhoneXMax,@big,优先级依次降低）
    MyScreenSizeTypeiPhoneXMax
};

//屏幕类型
MyScreenSizeType mainScreenType(void);

//适配后可以使用的资源名称数组
NSArray * adaptationResourceNames(NSString * resourceName);
//适配后存在的nib文件名称
NSString * validAdaptationNibName(NSString * nibName,NSBundle * bundleOrNil);

/*
 *适配后的值
 */
@interface NSDictionary (ScreenAdaptation)

- (id)adaptationValueForKey:(NSString *)key;
- (id)adaptationValueForKey:(NSString *)key withClass:(Class)valueClass;
- (id)adaptationValueForKey:(NSString *)key canRespondsToSelector:(SEL)selector;

- (NSInteger)adaptationIntegerValueForKey:(NSString *)key;
- (NSInteger)adaptationIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
- (CGFloat)adaptationFloatValueForKey:(NSString *)key;
- (CGFloat)adaptationFloatValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue;

@end

/*
 *适配后的图片
 */
@interface UIImage (ScreenAdaptation)

+ (UIImage *)adaptationImageWithName:(NSString *)name;

@end



