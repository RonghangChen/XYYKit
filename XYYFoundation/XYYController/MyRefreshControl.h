//
//  MyRefreshControl.h
//
//
//  Created by LeslieChen on 13-12-16.
//  Copyright (c) 2013年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyScrollTriggerView.h"

//----------------------------------------------------------

#define MyRefreshControlTriggerDistance 50.f

//----------------------------------------------------------

/**
 * 刷新控件的类型，上刷新控件和下刷新控件
 */
typedef NS_ENUM(int, MyRefreshControlType){
    /* 上刷新控件 */
    MyRefreshControlTypeTop,
    /* 下刷新控件 */
    MyRefreshControlTypeBottom
};


/**
 * 刷新控件的风格
 */
typedef NS_ENUM(int, MyRefreshControlStyle){
    /* 箭头风格 */
    MyRefreshControlStyleArrow,
    /* 进度风格 */
    MyRefreshControlStyleProgress
};

//----------------------------------------------------------

@protocol MyRefreshControlProtocol <NSObject>

- (id)initWithType:(MyRefreshControlType)type;

/**
 * 刷新控件的类型
 */
@property(nonatomic,readonly) MyRefreshControlType type;

/**
 *  刷新状态，为YES则在刷新
 */
@property(nonatomic,readonly,getter = isRefreshing) BOOL refreshing;


/**
 * 手动开始刷新
 */
- (void)beginRefreshing;
- (void)beginRefreshing_e:(BOOL)scrollToShow;

/**
 * 手动结束刷新
 */
- (void)endRefreshing;

@end

//----------------------------------------------------------

@interface MyRefreshControlManager : NSObject

+ (Class)defaultRefreshControlClass;
+ (void)setDefaultRefreshControlClass:(Class)refreshControlClass;

//创建刷新视图实例
+ (UIControl<MyRefreshControlProtocol> *)createDefaultRefreshControlWithType:(MyRefreshControlType)type;

@end

//----------------------------------------------------------

/**
 *  刷新控件，必需作为UIScrollView的子视图，刷新激活时发送UIControlEventValueChanged事件
 */
@interface MyRefreshControl : MyScrollTriggerView <MyRefreshControlProtocol>

/**
 * 默认风格为MyRefreshControlStyleArrow
 */
- (id)initWithType:(MyRefreshControlType)type style:(MyRefreshControlStyle)style;

/**
 * 刷新控件的风格
 */
@property(nonatomic,readonly) MyRefreshControlStyle style;

/**
 * 标签的文本的颜色，默认为黑色
 */
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIFont  *textFont;

/**
 * 文字
 */
- (void)setText:(NSString *)text forStatus:(MyScrollTriggerViewStatus)status;
- (NSString *)textForStatus:(MyScrollTriggerViewStatus)status;

@end
