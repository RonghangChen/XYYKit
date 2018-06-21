//
//  MyLabel.h

//
//  Created by LeslieChen on 15/1/16.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLabel : UILabel

//计算内建大小时单元扩张的比例，单位量，默认为CGSizeZero
@property(nonatomic) CGSize intrinsicSizeExpansionScale;

////计算内建大小时单元扩张的比例长度，绝对值，默认为CGSizeZero
@property(nonatomic) CGSize intrinsicSizeExpansionLength;


@end
