//
//  NSDictionary+MyBasicInfoCell.h
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyInfoCellEditerProtocol;

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyBasicInfoCellType) {
    MyBasicInfoCellTypeShow = 0,      //展示
    MyBasicInfoCellTypeEdit = 1,      //编辑（点击开始编辑）
    MyBasicInfoCellTypeNext = 2,      //下一步跳转
    MyBasicInfoCellTypeCustomEdit = 3 //自定义编辑
};

typedef NS_ENUM(NSInteger, MyBasicInfoCellEditType) {
    MyBasicInfoCellEditTypeCustom     = 0,     //自定义
    MyBasicInfoCellEditTypeText       = 1,     //文本编辑
    MyBasicInfoCellEditTypeSwitch     = 2,     //是否编辑
    MyBasicInfoCellEditTypePicker     = 3,     //选择器
    MyBasicInfoCellEditTypePickerDate = 4,     //选择时间
    MyBasicInfoCellEditTypeDetailText = 5      //详细文本编辑
};

//文本的类型
typedef NS_ENUM(NSInteger, MyInfoCellValueTextType) {
    MyInfoCellValueTextTypeNone            = 0,     //无类型
    MyInfoCellValueTextTypeEmail           = 1,     //邮箱
    MyInfoCellValueTextTypePhoneNumber     = 2,     //电话
    MyInfoCellValueTextTypeQQ              = 3,     //qq号
    MyInfoCellValueTextTypeNumber          = 4,     //数字
    MyInfoCellValueTextTypeInteger         = 5,     //整数
    MyInfoCellValueTextTypeDouble          = 6,     //浮点数
    MyInfoCellValueTextTypeMoney           = 7      //钱格式
};

//符号类型
typedef NS_ENUM(NSInteger, MyInfoCellValueSignType) {
    MyInfoCellValueSignTypeAll = 0,      //所有，负数正数和零
    MyInfoCellValueSignTypePositive = 1, //正数，不包含0
    MyInfoCellValueSignTypeNegative = 2, //负数，不包含0
    MyInfoCellValueSignTypeUnNegative = 3, //非负数，0和正数
    MyInfoCellValueSignTypeUnPositive = 4  //非正数，0和负数
};


//选择时间的模式
typedef UIDatePickerMode MyBasicInfoCellDatePickerMode;

//时间限制的模式
typedef NS_ENUM(NSInteger,MyBasicInfoCellDateLimitMode) {
    MyBasicInfoCellDateLimitModeToCurrent = 0,    //最大时间是now
    MyBasicInfoCellDateLimitModeFromCurrent = 1   //最小时间是now
};

//----------------------------------------------------------


@interface NSDictionary (MyBasicInfoCell)

- (NSDictionary *)infoCellInfo;

- (MyBasicInfoCellType)infoCellType;
- (MyBasicInfoCellEditType)infoCellEditType;

- (id<MyInfoCellEditerProtocol>)infoCellEditer;
- (MyBasicInfoCellDatePickerMode)infoCellDatePickerMode;
- (MyBasicInfoCellDateLimitMode)infoCellDateLimitMode;

//place holder
- (NSString *)infoCellPlaceholderText;
//最短字符长度
- (NSInteger)infoCellMinTextLenght;
//最长字符长度
- (NSInteger)infoCellMaxTextLenght;
//键盘输入的类型
- (UIKeyboardType)infoCellKeyboardType;
//文本值的类型
- (MyInfoCellValueTextType)infoCellValueTextType;
//符号类型
- (MyInfoCellValueSignType)infoCellValueSignType;
//文本正则表达式
- (NSString *)infoCellValueRegex;
//文本是否可以为null
- (BOOL)infoCellTextCanNull;

// yyyy-MM-dd HH-mm-ss
- (NSDate *)infoCellMaxDate;
- (NSDate *)infoCellMinDate;

- (NSDateFormatter *)infoDateFormatter;
- (NSDate *)infoDateForValue:(id)value;
- (NSString *)infoDateStrForValue:(id)value;

- (NSString *)infoCellKey;
- (NSArray *)infoValues;
- (id)value;

//值的place
- (NSString *)valuePlaceholder;

- (NSInteger)indexForValue:(id)value;
- (NSDictionary *)infoValueForValue:(id)value;


@end
