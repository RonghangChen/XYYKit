//
//  MyContentView.h
//  
//
//  Created by LeslieChen on 15/12/16.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyContentView : UIView

//通知需要更新视图
- (void)setNeedUpdateView;

//更新视图如果需要的话
- (BOOL)updateViewIfNeeded;

//子类重载该方法进行视图更新
- (void)updateView;

@end
