//
//  MyTintTableViewCell.h
//  5idj_ios
//
//  Created by LeslieChen on 14-7-29.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MySelectionProtocol.h"

//----------------------------------------------------------

typedef NS_ENUM(int,MyTableViewCellSeparatorLineStyle){
    MyTableViewCellSeparatorLineStyleNone,
    MyTableViewCellSeparatorLineStyleLine,
    MyTableViewCellSeparatorLineStyleGradient
};


//----------------------------------------------------------

@interface MyTableViewCell : UITableViewCell <MySelectionProtocol>

//默认为MyTableViewCellSeparatorLineStyleNone
@property(nonatomic) MyTableViewCellSeparatorLineStyle separatorLineStyle;
//分割线颜色,默认为灰色
@property(nonatomic,strong) UIColor * separatorLineColor;
//分割线宽度
@property(nonatomic) CGFloat separatorLineWidth;
//分割线inset
@property(nonatomic) UIEdgeInsets mySeparatorLineInset;


//设置需要更新cell
- (void)setNeedUpdateCell;
//更新cell，如果需要的话
- (void)updateCellIfNeeded;
//更新cell,子类重载进行必要的操作
- (void)updateCell;

@end
