//
//  MyInfoCellEditP.h
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#ifndef MyInfoCellEditProtocol_h
#define MyInfoCellEditProtocol_h

#import <UIKit/UIKit.h>
#import "NSObject+ShowViewControllerDelegate.h"

//----------------------------------------------------------

@protocol MyInfoCellEditerEditerDelegate;
@protocol MyInfoCellEditerDelegate;

//----------------------------------------------------------

@protocol MyInfoCellEditerProtocol <NSObject>

@optional

- (void)updateWithInfo:(NSDictionary *)info value:(id)value;
- (void)updateWithInfo:(NSDictionary *)info value:(id)value context:(id)context;

@required

@property(nonatomic,strong,readonly) NSIndexPath * cellIndexPath;
@property(nonatomic,strong,readonly) NSDictionary * info;
@property(nonatomic,strong,readonly) id value;

- (void)startEditForInfoCellAtIndexPath:(NSIndexPath *)indexPath
                      baseTableViewView:(UITableView *)tableView
                       inViewController:(UIViewController *)viewController
                               animated:(BOOL)animated
                         completedBlock:(void(^)(void))completedBlock;


- (void)endEditWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

//是否正在编辑
@property(nonatomic,readonly) BOOL isEditting;

//代理
@property(nonatomic,weak) id<MyInfoCellEditerDelegate> delegate;
@property(nonatomic,weak) id<MyInfoCellEditerEditerDelegate> editerDelegate;


@end

//----------------------------------------------------------

@protocol MyInfoCellEditerDelegate <MyShowViewControllerDelegate>

@optional

@end

//----------------------------------------------------------

@protocol MyInfoCellEditerEditerDelegate <NSObject>

@optional

- (BOOL)infoCellEditer:(id<MyInfoCellEditerProtocol>)infoCellEditer willEditToValue:(id)value;
- (void)infoCellEditer:(id<MyInfoCellEditerProtocol>)infoCellEditer didEditToValue:(id)value;

//取消编辑
- (void)infoCellEditerDidEditByCancel:(id<MyInfoCellEditerProtocol>)infoCellEditer;

//结束编辑有时间添加

@end

#endif
