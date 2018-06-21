//
//  MyGradientView.h
//
//
//  Created by LeslieChen on 14/11/4.
//  Copyright (c) 2014年 YB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGradientView : UIView

@property(nonatomic,strong) NSArray * colors;
@property(nonatomic,strong) NSArray * locations;

@property(nonatomic) CGPoint startPoint,endPoint;

@end
