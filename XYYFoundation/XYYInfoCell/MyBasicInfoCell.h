//
//  MyBasciInfoCell.h
//  
//
//  Created by LeslieChen on 15/3/22.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyTableViewCell.h"
#import "MyContentViewTableViewCell.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "MyCellContext.h"

//----------------------------------------------------------

@class MyBasicInfoCell;
@class MyInfoCellController;

//----------------------------------------------------------

@protocol MyBasicInfoCellDelegate <MyContentViewCellDelegate>

@optional

@end

//----------------------------------------------------------

@protocol MyBasicInfoCellEditerDelegate <NSObject>

@optional

//将要开始编辑
- (BOOL)infoCellWillBeginEdit:(MyBasicInfoCell *)cell;
//开始编辑
- (void)infoCellDidBeginEdit:(MyBasicInfoCell *)cell;
//结束编辑
- (void)infoCellDidEndEdit:(MyBasicInfoCell *)cell;

//想要开始编辑
- (BOOL)infoCellWantToBeginEdit:(MyBasicInfoCell *)cell;


- (BOOL)infoCell:(MyBasicInfoCell *)cell willEditToValue:(id)value;
- (void)infoCell:(MyBasicInfoCell *)cell didEditToValue:(id)value;

@end

//----------------------------------------------------------

@interface MyBasicInfoCell : MyContentViewTableViewCell

+ (CGFloat)heightForCellWithInfo:(NSDictionary *)info
              infoCellController:(MyInfoCellController *)infoCellController
                           value:(id)value
                         context:(MyCellContext *)context;

- (void)updateWithInfoCellInfo:(NSDictionary *)infoCellInfo
                         value:(id)value
                      editable:(BOOL)editable
                       context:(MyCellContext *)context;
- (void)updateWithInfoCellInfo:(NSDictionary *)infoCellInfo
                         value:(id)value
                       context:(MyCellContext *)context;

@property(nonatomic,strong,readonly) NSDictionary * infoCellInfo;
@property(nonatomic,readonly) MyBasicInfoCellType  cellType;
@property(nonatomic,readonly) MyBasicInfoCellEditType editType;


@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) id value;
@property(nonatomic,strong,readonly) NSString * valueTitle;


@property(nonatomic,weak) id<MyBasicInfoCellEditerDelegate> editerDelegate;
@property(nonatomic,weak) id<MyBasicInfoCellDelegate> delegate;


//是否允许编辑
@property(nonatomic,readonly,getter=isEditabled) BOOL editable;

//是否可以开始编辑(自定义编辑,非编辑器)，默认为NO
- (BOOL)canBeginEdit;
//是否可以通过选中开始编辑，默认为YES
- (BOOL)canBeginEditForDidSelected;
//是否是文本编辑，默认为NO
- (BOOL)isTextEdit;
//开始编辑（没有编辑器会使用该方法开始进行编辑）
- (void)beginEdit:(BOOL)animated completedBlock:(void(^)(void))completedBlock;
//结束编辑
- (void)endEdit:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

//是否正在编辑
@property(nonatomic,readonly,getter=isInfoEditting) BOOL infoEditting;

//子类重载用于发送通知

//尝试开始编辑
- (BOOL)tryBeginEdit;
//将要开始编辑
- (BOOL)willBeginEdit;
//开始编辑
- (void)didBeginEdit;
//完成编辑
- (void)didEndEdit;

//想要开始编辑
- (BOOL)wantToBeginEdit;

//尝试改变值
- (BOOL)tryEditToNewValue:(id)newValue;
//将要改变值
- (BOOL)willEditToNewValue:(id)newValue;
//改变值
- (void)didEditToNewValue:(id)newValue;



@end


