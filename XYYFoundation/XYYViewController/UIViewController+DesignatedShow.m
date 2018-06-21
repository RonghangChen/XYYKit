//
//  UIViewController+DesignatedShow.m
//  
//
//  Created by LeslieChen on 15/3/18.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "UIViewController+DesignatedShow.h"
#import "UIViewController+Instance.h"
#import <objc/runtime.h>

static char showViewControllerDelegateKey;

@implementation UIViewController (DesignatedShow)

- (MyViewControllerDesignatedShowWay)viewControllerDesignatedShowWay {
    return MyViewControllerDesignatedShowWayPresent;
}

- (BOOL)showViewControllerWithDesignatedWay:(UIViewController *)viewController
                                   animated:(BOOL)animated
                             completedBlock:(void (^)(void))completedBlock
{
    //进行转发
    id<MyShowViewControllerDelegate> delegate = self.showViewControllerDelegate;
    if (delegate && [delegate respondsToSelector:@selector(object:wantToShowViewController:animated:completedBlock:)]) {
        return [delegate object:self wantToShowViewController:viewController animated:animated completedBlock:completedBlock];
    }
    
    if (!viewController) {
        NSLog(@"viewController为nil,显示失败");
        return NO;
    }
    
    //将要显示视图
    if ([viewController respondsToSelector:@selector(willShowBaseViewController:animated:completedBlock:)] &&
        ![viewController willShowBaseViewController:self animated:animated completedBlock:completedBlock]) {
        return NO;
    }
    
    //获取要显示的视图
    UIViewController * viewControllerForShow = [viewController relocationViewControllerForShowBaseViewController:self];
    
    switch ([viewController viewControllerDesignatedShowWay]) {
        case MyViewControllerDesignatedShowWayPush:
        {
            
            UINavigationController * navigationController = [self isKindOfClass:[UINavigationController class]] ? (UINavigationController *)self : self.navigationController;
            
            if (!navigationController) {
                NSLog(@"当前ViewController不为UINavigationController实例或者不在navigationController中,无法用push方式显示视图");
                return NO;
            }else{
                [navigationController pushViewController:viewControllerForShow animated:animated];
                
                if (completedBlock) {
                    completedBlock();
                }
            }
        }
            break;
            
        case MyViewControllerDesignatedShowWayPresent:
            [self presentViewController:viewControllerForShow animated:animated completion:completedBlock];
            break;
            
        case MyViewControllerDesignatedShowWayUserDefine:
            return [viewControllerForShow showWithUserDefineWayBasicViewController:self
                                                                          animated:animated
                                                                    completedBlock:completedBlock];

            break;
    }

    return YES;
}

- (UIViewController *)relocationViewControllerForShowBaseViewController:(UIViewController *)baseViewController {
    return self;
}

- (BOOL)showWithUserDefineWayBasicViewController:(UIViewController *)basicViewController
                                        animated:(BOOL)animated
                                  completedBlock:(void (^)(void))completedBlock
{
    if ([self viewControllerDesignatedShowWay] != MyViewControllerDesignatedShowWayUserDefine) {
        NSLog(@"当前viewController设计的显示方式非用户自定义，自定义显示失败");
        return NO;
    }
    
    NSLog(@"无默认的自定义显示方式，显示失败");
    
    return NO;
}

- (BOOL)hideWithDesignatedWay:(BOOL)animated completedBlock:(void(^)(void))completedBlock
{
    //首先进行转发
    id<MyShowViewControllerDelegate> delegate = self.showViewControllerDelegate;
    if (delegate && [delegate respondsToSelector:@selector(objectWantToHideViewController:animated:completedBlock:)]) {
        return [delegate objectWantToHideViewController:self animated:animated completedBlock:completedBlock];
    }
    
    switch ([self viewControllerDesignatedShowWay]) {
        case MyViewControllerDesignatedShowWayPush:
            
            if(!self.navigationController){
                NSLog(@"当前viewController不在navigationController中，无法以pop方式隐藏");
                return NO;
            }else{
                
                NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
                if (index >= 1 && index != NSNotFound) {
                    [self.navigationController popToViewController:self.navigationController.viewControllers[index - 1]
                                                          animated:YES];
                    
                    if (completedBlock) {
                        completedBlock();
                    }
                    
                }else {
                    
                    NSLog(@"当前viewController输入根视图或存在问题无法隐藏，无法以pop方式隐藏");
                    return NO;
                }
            }
            
            break;
            
        case MyViewControllerDesignatedShowWayPresent:
            
            if (!self.presentingViewController) {
                NSLog(@"当前viewController未被Present，无法以Dimiss方式隐藏");
                return NO;
            }else{
                [self.presentingViewController dismissViewControllerAnimated:animated completion:completedBlock];
            }
            
            break;
            
        case MyViewControllerDesignatedShowWayUserDefine:
            
            return [self hideWithUserDefineWay:animated completedBlock:completedBlock];
            
            break;
    }
    
    return YES;
}

- (BOOL)hideWithUserDefineWay:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    if ([self viewControllerDesignatedShowWay] != MyViewControllerDesignatedShowWayUserDefine) {
        NSLog(@"当前viewController设计的隐藏方式非用户自定义，自定义隐藏失败");
        return NO;
    }
    
    NSLog(@"无默认的自定义隐藏方式，显示失败");
    return NO;
}


#pragma mark -

+ (instancetype)showViewControllerWithContext:(id)context
                           baseViewController:(UIViewController *)baseViewController
                                     animated:(BOOL)animated
                               completedBlock:(void (^)(void))completedBlock
{
    baseViewController = baseViewController ?: [self defaultShowBaseViewController];
    if (baseViewController && [self willCreateInstaceWithContext:context
                                       forShowBaseViewController:baseViewController
                                                        animated:animated
                                                  completedBlock:completedBlock])
    {
        
        UIViewController * instance = [self viewControllerWithContext:context];
        if ([baseViewController showViewControllerWithDesignatedWay:instance animated:animated completedBlock:completedBlock]) {
            return instance;
        }
    }
    
    return nil;
}

+ (UIViewController *)defaultShowBaseViewController {
    return nil;
}

+ (BOOL)willCreateInstaceWithContext:(id)context
           forShowBaseViewController:(UIViewController *)baseViewController
                            animated:(BOOL)animated
                      completedBlock:(void(^)(void))completedBlock
{
    return YES;
}

#pragma mark -

- (id<MyShowViewControllerDelegate>)showViewControllerDelegate {
    return objc_getAssociatedObject(self, &showViewControllerDelegateKey);
}

- (void)setShowViewControllerDelegate:(id<MyShowViewControllerDelegate>)showViewControllerDelegate {
    objc_setAssociatedObject(self, &showViewControllerDelegateKey, showViewControllerDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<MyShowViewControllerDelegate>)forwardingTargetForShowViewController:(UIViewController *)viewController {
    return self.showViewControllerDelegate;
}

#pragma mark -

//替换显示
- (BOOL)replaceShowViewController:(UIViewController *)viewController
                         animated:(BOOL)animated
                   completedBlock:(void(^)(void))completedBlock
{
    if (!viewController) {
        NSLog(@"viewController为nil,无法替换显示");
        return NO;
    }
    
    switch ([self viewControllerDesignatedShowWay]) {
        case MyViewControllerDesignatedShowWayPush:
        {
            UINavigationController * navigationController = self.navigationController;
            if (navigationController) {
                
                if ([viewController viewControllerDesignatedShowWay] == MyViewControllerDesignatedShowWayPush) { //目标视图也是push
                    
                    //显示新视图并隐藏当前视图
                    NSMutableArray * viewControllers = [NSMutableArray arrayWithArray:navigationController.viewControllers];
                    
                    //移除当前的并加入将要显示的
                    NSUInteger index = [viewControllers indexOfObjectIdenticalTo:self];
                    [viewControllers removeObjectsInRange:NSMakeRange(index, viewControllers.count - index)];
                    [viewControllers addObject:viewController];
                    
                    //显示
                    [navigationController setViewControllers:viewControllers animated:animated];
                    
                    if (completedBlock) {
                        completedBlock();
                    }
                    
                }else {
                    
                    //先隐藏后显示
                    [self hideWithDesignatedWay:animated completedBlock:^{
                        [navigationController showViewControllerWithDesignatedWay:viewController animated:animated completedBlock:completedBlock];
                    }];
                }
                
                return YES;
                
            }else {
                NSLog(@"viewController不在导航控制器中，无法替换显示");
            }
            
        }
            break;
            
        case MyViewControllerDesignatedShowWayPresent:
        {
            UIViewController * presentingViewController = self.presentingViewController;
            if (presentingViewController) {
                
                [presentingViewController dismissViewControllerAnimated:animated completion:^{
                    [presentingViewController showViewControllerWithDesignatedWay:viewController animated:animated completedBlock:completedBlock];
                }];
                
                return YES;
                
            }else {
                NSLog(@"viewController没有被present显示，无法替换显示");
            }
        }
            break;
            
        default:
            NSLog(@"自定义显示方法不支持替换显示");
            break;
    }
    
    return NO;
}

@end
