//
//  MyBasicInfoCellEditView.h
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyInfoCellEditerProtocol.h"

//----------------------------------------------------------

@interface MyBasicInfoCellEditerView : UIView <MyInfoCellEditerProtocol>


@property(nonatomic,strong) NSString * title;
//编辑的值相关
@property(nonatomic,strong,readonly) id newValue;


- (BOOL)tryEditToNewValue;

//是否改变了值
- (BOOL)didChangeValue:(id)newValue;
- (void)didEditToNewValue:(id)newValue;

//结束编辑
- (void)didEndEditByCancle;

//value预期的类型，默认返回nil，不做任何过滤
- (Class)valueExpectedClass;

@end
