//
//  UIView+Instance.h
//
//
//  Created by LeslieChen on 14/10/28.
//  Copyright (c) 2014年 YB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Instance)

//首先从nib加载不成功则使用默认加载方式
+ (instancetype)xyy_createInstance;
+ (instancetype)xyy_createInstanceWithContext:(id)context;
+ (instancetype)xyy_createInstanceWithNibName:(NSString *)nibNameOrNil
                                       bundle:(NSBundle *)bundleOrNil
                                      context:(id)context;

//初始化
- (id)xyy_initWithContext:(id)context NS_REPLACES_RECEIVER;
- (void)xyy_setupViewWithContext:(id)context;

//nib桥接
//是否需要nib桥接（默认返回NO）
+ (BOOL)xyy_shouldApplyNibBridging;

@end
