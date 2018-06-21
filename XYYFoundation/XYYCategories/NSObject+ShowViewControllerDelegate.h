//
//  NSObject+ShowViewControllerDelegate.h

//
//  Created by LeslieChen on 14/11/24.
//  Copyright (c) 2014年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@protocol MyShowViewControllerDelegate <NSObject>

@optional

- (BOOL)object:(id)object wantToShowViewController:(UIViewController *)viewController animated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

- (BOOL)objectWantToHideViewController:(id)object animated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

@end

//----------------------------------------------------------

@interface NSObject(ShowViewControllerDelegate) <MyShowViewControllerDelegate>

//转发对象
- (id<MyShowViewControllerDelegate>)forwardingTargetForShowViewController:(UIViewController *)viewController;

@end



