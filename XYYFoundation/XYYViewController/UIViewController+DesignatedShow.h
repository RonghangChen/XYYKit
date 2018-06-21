//
//  UIViewController+DesignatedShow.h
//  
//
//  Created by LeslieChen on 15/3/18.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "NSObject+ShowViewControllerDelegate.h"

//----------------------------------------------------------

typedef NS_ENUM(NSInteger,MyViewControllerDesignatedShowWay){
    MyViewControllerDesignatedShowWayPush,       //push显示
    MyViewControllerDesignatedShowWayPresent,    //prsent显示
    MyViewControllerDesignatedShowWayUserDefine  //用户定义的方式
};

//----------------------------------------------------------

@protocol MyDesignatedShowProtocol <NSObject>

@required
//设计的方式显示
- (MyViewControllerDesignatedShowWay)viewControllerDesignatedShowWay;

//通过设计的显示方法显示
- (BOOL)showViewControllerWithDesignatedWay:(UIViewController *)viewController
                                   animated:(BOOL)animated
                             completedBlock:(void(^)(void))completedBlock;


@optional

//将要显示
- (BOOL)willShowBaseViewController:(UIViewController *)baseViewController
                          animated:(BOOL)animated
                    completedBlock:(void(^)(void))completedBlock;

@required

//重定向的用于显示的视图控制器，当要以某一种方法显示视图时，可能需要将该视图加入某一容器视图后再显示，或者重定向到另一个视图显示，默认返回视图控制器自己
- (UIViewController *)relocationViewControllerForShowBaseViewController:(UIViewController *)baseViewController;

//隐藏
- (BOOL)hideWithDesignatedWay:(BOOL)animated completedBlock:(void(^)(void))completedBlock;


//用户定义的方式显示
- (BOOL)showWithUserDefineWayBasicViewController:(UIViewController *)basicViewController
                                        animated:(BOOL)animated
                                  completedBlock:(void(^)(void))completedBlock;
- (BOOL)hideWithUserDefineWay:(BOOL)animated completedBlock:(void(^)(void))completedBlock;


//默认的初始化并显示方法
+ (instancetype)showViewControllerWithContext:(id)context
                           baseViewController:(UIViewController *)baseViewController
                                     animated:(BOOL)animated
                               completedBlock:(void(^)(void))completedBlock;

//默认的显示时候基于的视图控制器，当showViewControllerWithContext:baseViewController:animated:completedBlock:传入的baseViewController为nil时会使用该方法获取默认基于的视图控制器，默认返回nil
+ (UIViewController *)defaultShowBaseViewController;

//将要创建实例并基于baseViewController显示
+ (BOOL)willCreateInstaceWithContext:(id)context
           forShowBaseViewController:(UIViewController *)baseViewController
                            animated:(BOOL)animated
                      completedBlock:(void(^)(void))completedBlock;


@end

//----------------------------------------------------------

@interface UIViewController (DesignatedShow) <MyDesignatedShowProtocol>

//显示视图的转发代理（如果设置了代理且实现了方法，任何显示隐藏视图相关方法都会被转发）
@property(nonatomic,weak) id<MyShowViewControllerDelegate> showViewControllerDelegate;

//替换显示
- (BOOL)replaceShowViewController:(UIViewController *)viewController
                         animated:(BOOL)animated
                   completedBlock:(void(^)(void))completedBlock;

@end

