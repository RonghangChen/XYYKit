//
//  help.h
//
//
//  Created by LeslieChen on 13-12-11.
//  Copyright (c) 2013年 LeslieChen. All rights reserved.
//

/*
 *
 *常用帮助函数定义
 *
 */

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

#ifndef Help_h
#define Help_h


#pragma mark -


#pragma mark -
//----------索引相关--------------
//----------------------------------------------------------

//获取指定section上的连续的在range范围的indexPath
NSArray * indexPathsFromRange(NSInteger section, NSRange range);
NSArray * indexPathsFromIndexSet(NSInteger section, NSIndexSet * indexSet);


//核对index在range范围内，不在则抛出异常
void checkIndexAtRange(NSUInteger index,NSRange range);

//将数据进行本地化排序，返回数据中第一个元素为索引数组，第二元素为数据数组的数组，和索引相对应
NSArray * makeDatasToLocalizedIndexed(NSArray * datas, SEL collationStringSelector);


#pragma mark -
//----------内存相关--------------
//----------------------------------------------------------

// 输出自动释放池信息
extern void _objc_autoreleasePoolPrint(void);

//位置内存大小
#define MyMemorySizeUnknown -1.0

//返回物理内存大小，单位是MB
double physicalMemorySize(void);

//当前任务占用的内存数，单位是MB
double usedMemorySize(void);

//内存类型
typedef NS_OPTIONS(NSUInteger, MyMemoryType) {
    MyMemoryTypeNone      = 0,
    MyMemoryTypeFree      = 1 << 0,  //空闲
    MyMemoryTypeUsed      = 1 << 1,  //已使用
    MyMemoryTypeInactive  = 1 << 2,  //未激活
    MyMemoryTypeAvailable = MyMemoryTypeFree | //可获取的内存包括空闲及未激活的内存
                            MyMemoryTypeInactive
};

//获取特定类型的内存大小
double memorySizeForType(MyMemoryType type);


#pragma mark -

//----------其它--------------
//----------------------------------------------------------

//app store 的URL
NSString * appStoreURL(NSString * appID);
NSString * appStoreHTTPURL(NSString * appID);
NSString * appStoreReviewURL(NSString * appID);

//打开appstroe
void gotoAppStore(NSString * appID);
//打开appstroe评价
void gotoAppStoreReview(NSString * appID);
//打开URL
BOOL openURL(NSURL * url);
//调用系统打电话功能
void callPhoneNumber(NSString * phoneNumber);

/*
 *获取指定方向上的旋转仿射变换矩阵
 */
CGAffineTransform rotationAffineTransformForOrientation(UIInterfaceOrientation orientation);


//设置网络活动指示器的显示情况
void showNetworkActivityIndicator(BOOL bShow);

//返回直线layer
CAShapeLayer * createLineLayer(CGPoint startPoint,CGPoint endPoint,CGFloat lineWidth,UIColor * lineColor);

//----------------------------------------------------------

//默认重用定义
extern  NSString * const defaultReuseDef;


#pragma mark -
//----------运行时--------------
//----------------------------------------------------------

/**
 * 协议是否包含某一个方法
 */
BOOL NSProtocolContainSelector(Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod);

#endif
