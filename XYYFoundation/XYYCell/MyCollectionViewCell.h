//
//  MyCollectionViewCell.h

//
//  Created by LeslieChen on 15/1/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MySelectionProtocol.h"
#import "MyBorderProtocol.h"

//----------------------------------------------------------

@interface MyCollectionViewCell : UICollectionViewCell < MySelectionProtocol,MyBorderProtocol>

@property(nonatomic) IBInspectable CGFloat  borderWidth;
@property(nonatomic,strong) IBInspectable UIColor * borderColor;

//是否显示boder，生成边界掩码
@property(nonatomic) IBInspectable BOOL showTopBorder;
@property(nonatomic) IBInspectable BOOL showLeftBorder;
@property(nonatomic) IBInspectable BOOL showRightBorder;
@property(nonatomic) IBInspectable BOOL showBottomBorder;

//设置需要更新cell
- (void)setNeedUpdateCell;
//更新cell，如果需要的话
- (void)updateCellIfNeeded;
//更新cell,子类重载进行必要的操作
- (void)updateCell;


@end
