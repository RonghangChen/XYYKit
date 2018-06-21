//
//  MyBasicInfoCellEditerPopoverView.h
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyBasicInfoCellEditerView.h"

@interface MyBasicInfoCellEditerPopoverView : MyBasicInfoCellEditerView

//内容的锚点，默认是（0.5f，0.5f）中心
@property(nonatomic) CGPoint contentAnchorPoint;
//定位的锚点，默认是（0.5f，0.5f）中心
@property(nonatomic) CGPoint locationAnchorPoint;

@property(nonatomic,strong,readonly) NSArray * values;

@end
