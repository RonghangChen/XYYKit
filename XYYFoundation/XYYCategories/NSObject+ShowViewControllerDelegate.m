//
//  NSObject+ShowViewControllerDelegate.m

//
//  Created by LeslieChen on 14/11/24.
//  Copyright (c) 2014年 ED. All rights reserved.
//

#import "NSObject+ShowViewControllerDelegate.h"
#import "UIViewController+DesignatedShow.h"

@implementation NSObject (ShowViewControllerDelegate)

- (BOOL)object:(id)object wantToShowViewController:(UIViewController *)viewController animated:(BOOL)animated completedBlock:(void(^)())completedBlock
{
    id<MyShowViewControllerDelegate> forwardingTarget = [self forwardingTargetForShowViewController:viewController];
    
    if (forwardingTarget && [forwardingTarget respondsToSelector:_cmd]) {
        
        return [forwardingTarget object:self wantToShowViewController:viewController animated:animated completedBlock:completedBlock];
        
    }else if ([self isKindOfClass:[UIViewController class]]) {
        
        return [(UIViewController *)self showViewControllerWithDesignatedWay:viewController
                                                                    animated:animated
                                                              completedBlock:completedBlock];
    }
    
    return NO;
}

- (BOOL)objectWantToHideViewController:(id)object animated:(BOOL)animated completedBlock:(void(^)())completedBlock
{
    id<MyShowViewControllerDelegate> forwardingTarget = [self forwardingTargetForShowViewController:nil];
    
    if (forwardingTarget && [forwardingTarget respondsToSelector:_cmd]) {
        
        return [forwardingTarget objectWantToHideViewController:object animated:animated completedBlock:completedBlock];
        
    }else if ([self isKindOfClass:[UIViewController class]]) {
        
        return [(UIViewController *)self hideWithDesignatedWay:animated completedBlock:completedBlock];
        
    }
    
    return NO;
}

- (id<MyShowViewControllerDelegate>)forwardingTargetForShowViewController:(UIViewController *)viewController {
    return nil;
}


@end
