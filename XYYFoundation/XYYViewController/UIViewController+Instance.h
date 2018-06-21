//
//  UIViewController+Instance.h
//
//
//  Created by LeslieChen on 14-7-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Instance)

+ (instancetype)viewController;
+ (instancetype)viewControllerWithContext:(id)context;
+ (instancetype)viewControllerWithNibName:(NSString *)nibNameOrNil
                                   bundle:(NSBundle *)bundleOrNil
                                  context:(id)context;

- (void)setupViewContext:(id)context;

@end
