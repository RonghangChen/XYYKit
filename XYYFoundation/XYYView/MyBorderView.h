//
//  MyBorderView.h

//
//  Created by LeslieChen on 15/2/28.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyBorderProtocol.h"

@interface MyBorderView : UIView <MyBorderProtocol>

@property(nonatomic) IBInspectable CGFloat  borderWidth;
@property(nonatomic,strong) IBInspectable UIColor * borderColor;

//是否显示boder，生成边界掩码
@property(nonatomic) IBInspectable BOOL showTopBorder;
@property(nonatomic) IBInspectable BOOL showLeftBorder;
@property(nonatomic) IBInspectable BOOL showRightBorder;
@property(nonatomic) IBInspectable BOOL showBottomBorder;


@end
