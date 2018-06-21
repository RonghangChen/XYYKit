//
//  XYYMessageUtil.m
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "XYYMessageUtil.h"
#import <MBProgressHUD.h>
#import "UIImage+XYYExtend.h"
#import "MyActivityIndicatorView.h"
#import "MyNetReachability.h"
#import "XYYBaseDef.h"


#pragma mark-

@interface _MyMBProgressHUDViewController : UIViewController

@end

@implementation _MyMBProgressHUDViewController

- (BOOL)prefersStatusBarHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIApplication sharedApplication].statusBarStyle;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end

MBProgressHUD * showCustomMBProgressHUDView(UIView *view,NSString *titleText,NSString * detailText,UIView * customView,void(^completedBlock)(void))
{
    //初始化
    MBProgressHUD * progressHUD = [[MBProgressHUD alloc] init];
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.mode = MBProgressHUDModeCustomView;
    progressHUD.customView = customView;
    progressHUD.labelText = titleText;
    progressHUD.detailsLabelText = detailText;
    progressHUD.userInteractionEnabled = NO;
    
    if (!view) {
        
        UIWindow * topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        topWindow.windowLevel = UIWindowLevelAlert;
        topWindow.userInteractionEnabled = NO;
        topWindow.tintColor = [UIApplication sharedApplication].keyWindow.tintColor;
        
        _MyMBProgressHUDViewController * vc = [[_MyMBProgressHUDViewController alloc] init];
        vc.view.frame = topWindow.bounds;
        topWindow.rootViewController = vc;
        [vc.view addSubview:progressHUD];
        
        [topWindow makeKeyAndVisible];
        
        //构成短暂的循环保留
        progressHUD.completionBlock = ^{
            topWindow.hidden= YES;
            
            if (completedBlock) {
                completedBlock();
            }
        };
        
    }else{
        progressHUD.completionBlock = completedBlock;
        [view addSubview:progressHUD];
    }
    
    //显示
    [progressHUD show:YES];
    
    return progressHUD;
}

MBProgressHUD * showMessageWithCustomView(UIView *view,
                                          NSString *titleText,
                                          NSString * detailText,
                                          UIView * customView)
{
    return  showMessageWithCustomView_c(view, titleText, detailText, customView, 0.0, nil);
}

MBProgressHUD * showMessageWithCustomView_c(UIView *view,
                                            NSString *titleText,
                                            NSString * detailText,
                                            UIView * customView,
                                            NSTimeInterval duration,
                                            void(^completedBlock)(void))
{
    MBProgressHUD * progressHUD = showCustomMBProgressHUDView(view, titleText, detailText, customView, completedBlock);
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    [progressHUD hide:YES afterDelay:duration <= 0.f ? 2.0 : duration];
    
    return progressHUD;
}

MBProgressHUD * showMessage(UIView *view,NSString * titleText,NSString * detailText) {
    return showMessage_c(view, titleText, detailText, 0.0, nil);
}

MBProgressHUD * showMessage_c(UIView *view,
                              NSString *titleText,
                              NSString * detailText,
                              NSTimeInterval duration,
                              void(^completedBlock)(void))
{
    MBProgressHUD * progressHUD = showMessageWithCustomView_c(view,titleText,detailText,nil,duration,completedBlock);
    progressHUD.mode = MBProgressHUDModeText;
    
    return progressHUD;
}

MBProgressHUD * showMessageWithImage(UIView *view,
                                     NSString *titleText,
                                     NSString * detailText,
                                     UIImage * image)
{
    return showMessageWithImage_c(view, titleText, detailText, image, 0.0, nil);
}

MBProgressHUD * showMessageWithImage_c(UIView *view,
                                       NSString *titleText,
                                       NSString * detailText,
                                       UIImage * image,
                                       NSTimeInterval duration,
                                       void(^completedBlock)(void))
{
    UIImageView * imageView = image ? [[UIImageView alloc] initWithImage:image] : nil;
    return showMessageWithCustomView_c(view, titleText, detailText, imageView, duration, completedBlock);
}

//显示错误消息
MBProgressHUD * showErrorMessage(UIView *view, NSError *error, NSString *titleText) {
    return showErrorMessage_b(view, error, titleText,nil);
}

MBProgressHUD * showErrorMessage_b(UIView *view,
                                   NSError *error,
                                   NSString *titleText,
                                   void(^completedBlock)(void))
{
    return showErrorMessage_c(view, titleText, error.localizedDescription, 0.0, completedBlock);
}

MBProgressHUD * showErrorMessage_c(UIView *view,
                                   NSString *titleText,
                                   NSString *detailText,
                                   NSTimeInterval duration,
                                   void(^completedBlock)(void))
{
    return showMessageWithImage_c(view,
                                  titleText,
                                  detailText,
                                  ImageWithName(@"error_msg.png"),
                                  duration,
                                  completedBlock);
}

//显示成功消息
MBProgressHUD * showSuccessMessage(UIView *view, NSString *titleText, NSString * detailText) {
    return showSuccessMessage_b(view, titleText, detailText, nil);
}

MBProgressHUD * showSuccessMessage_b(UIView *view,
                                     NSString *titleText,
                                     NSString * detailText,
                                     void(^completedBlock)(void))
{
    return showSuccessMessage_c(view, titleText, detailText, 0.0, completedBlock);
}

MBProgressHUD * showSuccessMessage_c(UIView *view,
                                     NSString *titleText,
                                     NSString *detailText,
                                     NSTimeInterval duration,
                                     void(^completedBlock)(void))
{
    return showMessageWithImage_c(view,
                                  titleText,
                                  detailText,
                                  ImageWithName(@"success_msg.png"),
                                  duration,
                                  completedBlock);
}

MBProgressHUD * showHUDWithActivityIndicatorView(UIView * view,
                                                 UIView<MyActivityIndicatorViewProtocol> * activityIndicatorView,
                                                 NSString *title)
{
    MBProgressHUD * progressHUD = showCustomMBProgressHUDView(view,
                                                              title,
                                                              nil,
                                                              activityIndicatorView,
                                                              nil);
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    progressHUD.userInteractionEnabled = YES;
    if (!view) {
        progressHUD.superview.userInteractionEnabled = YES;
    }
    [activityIndicatorView startAnimating];
    
    return progressHUD;
}

MBProgressHUD * showHUDWithMyActivityIndicatorView(UIView * view,UIColor *color,NSString *title)
{
    MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
    activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 30.f, 30.f);
    activityIndicatorView.twoStepAnimation = NO;
    activityIndicatorView.tintColor = color ?: [UIColor whiteColor];
    
    return showHUDWithActivityIndicatorView(view, activityIndicatorView,title);
}


void showNetworkStatusMessage(UIView *view)
{
    //网络状态
    NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
    
    if (status == NotReachable) {
        showMessage(view, @"当前无可用网络", nil);
    }else if (status == ReachableViaWWAN){
        showMessage(view, @"当前处于蜂窝移动网络", nil);
    }else{
        showMessage(view, @"当前处于WIFI网络", nil);
    }
}

UIAlertView * showAlertView(NSString *titleText,NSString * detailText)
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:titleText
                                                         message:detailText
                                                        delegate:nil
                                               cancelButtonTitle:@"知道了"
                                               otherButtonTitles:nil];
    
    [alertView show];
    
    return alertView;
}
