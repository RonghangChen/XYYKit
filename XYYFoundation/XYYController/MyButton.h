//
//  BT_ShowBottomButton.h
//  Bestone
//
//  Created by LeslieChen on 14-5-21.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyButton : UIButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;

//是否自动调节背景色
@property(nonatomic) BOOL autoAdjustBackgroundColor;
- (UIColor *)showingBackgroundColorForState:(UIControlState)state;

//计算内建大小时单元扩张的比例，单位量，默认为CGSizeZero
@property(nonatomic) CGSize intrinsicSizeExpansionScale;
////计算内建大小时单元扩张的长度，绝对值，默认为CGSizeZero
@property(nonatomic) CGSize intrinsicSizeExpansionLength;

//改变触摸状态时调用改block
@property(nonatomic,copy) void(^buttonDidChangeTouchStateBlock)(MyButton * button, BOOL isTouch);

@end

@interface MyButton (IBDesignable)

@property(nonatomic,strong) IBInspectable UIColor * highlightedBackgroundColor;
@property(nonatomic,strong) IBInspectable UIColor * disabledBackgroundColor;

@end
