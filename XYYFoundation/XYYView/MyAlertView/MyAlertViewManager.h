//
//  MyAlertViewManager.h
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/10/13.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyAlertViewProtocol <NSObject>

- (void)hideAlertViewWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

@end


@interface MyAlertViewManager : NSObject

+ (instancetype)sharedManager;

//显示alert视图
- (void)showAlertView:(id<MyAlertViewProtocol>)alertView withBlock:(void(^)(void))showBlock;

//隐藏alert视图
- (void)hideAlertView:(id<MyAlertViewProtocol>)alertView withAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;
//隐藏所有的alert视图
- (void)hideAllAlertViews;

//是否正在显示
- (BOOL)isShowAlertView:(id<MyAlertViewProtocol>)alertView;

//正在显示的alert视图
@property(nonatomic,weak,readonly) id<MyAlertViewProtocol> showingAlertView;

//暂停显示的alert视图
@property(nonatomic) BOOL pauseShowAlertView;

@end
