//
//  XYYMessageUtil.m
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "XYYMessageUtil.h"
#import "MBProgressHUD.h"
#import "UIImage+XYYExtend.h"
#import "MyActivityIndicatorView.h"
#import "MyNetReachability.h"
#import "XYYBaseDef.h"
#import "UIAlertView+Block.h"

#pragma mark-

@interface MBProgressHUD(XYYMessageUtil) <XYYProgressViewProtocol>


@end

@implementation MBProgressHUD(XYYMessageUtil)

- (void)hideWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    self.completionBlock = completedBlock;
    [self hide:animated];
}

@end

#pragma mark-

@implementation XYYMessageUtil

static XYYMessageUtil * _shareMessageUtil = nil;
+ (XYYMessageUtil *)shareMessageUtil
{
    if (!_shareMessageUtil) {
        _shareMessageUtil = [[XYYMessageUtil alloc] init];
    }
    
    return _shareMessageUtil;
}

- (void)setupShareMessageUtil:(XYYMessageUtil *)messageUtil {
    _shareMessageUtil = messageUtil;
}

- (void)showMessageInView:(UIView *)view
                withTitle:(NSString *)titleText
                   detail:(NSString *)detailText
               customView:(UIView *)customView
                 duration:(NSTimeInterval)duration
           completedBlock:(void (^)(void))completedBlock
{
    showMessageWithCustomView(view, titleText, detailText, customView, duration, completedBlock);
}

- (void)showMessageInView:(UIView *)view
                withTitle:(NSString *)titleText
                   detail:(NSString *)detailText
                 duration:(NSTimeInterval)duration
           completedBlock:(void (^)(void))completedBlock
{
    showMessage(view, titleText, detailText, duration, completedBlock);
}

- (void)showErrorMessageInView:(UIView *)view
                     withTitle:(NSString *)titleText
                         error:(NSError *)error
                      duration:(NSTimeInterval)duration
                completedBlock:(void (^)(void))completedBlock
{
    [self showErrorMessageInView:view
                       withTitle:titleText
                          detail:error.localizedDescription
                        duration:duration
                  completedBlock:completedBlock];
}


- (void)showErrorMessageInView:(UIView *)view
                     withTitle:(NSString *)titleText
                        detail:(NSString *)detailText
                      duration:(NSTimeInterval)duration
                completedBlock:(void (^)(void))completedBlock
{
    showErrorMessage(view, titleText, detailText, duration, completedBlock);
}

- (void)showSuccessMessageInView:(UIView *)view
                       withTitle:(NSString *)titleText
                          detail:(NSString *)detailText
                        duration:(NSTimeInterval)duration
                  completedBlock:(void (^)(void))completedBlock
{
    showSuccessMessage(view, titleText, detailText, duration, completedBlock);
}

- (void)showAlertViewWithTitle:(NSString *)titleText content:(NSString *)contentText {
    [self showAlertViewWithTitle:titleText content:contentText okText:nil cancleText:@"知道了" actionBlock:nil];
}

- (void)showAlertViewWithTitle:(NSString *)titleText
                       content:(NSString *)contentText
                        okText:(NSString *)okText
                    cancleText:(NSString *)cancleText
                   actionBlock:(void(^)(BOOL ok))actionBlock
{
    UIAlertView * alertView = [UIAlertView alertWithCallBackBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (actionBlock) {
            actionBlock(alertView.cancelButtonIndex != buttonIndex);
        }
    }
                                                            title:titleText
                                                          message:contentText
                                                 cancelButtonName:cancleText
                                                otherButtonTitles:okText, nil];
    
    
    [alertView show];
}

- (id<XYYProgressViewProtocol>)showProgressViewInView:(UIView *)view
                                            withTitle:(NSString *)titleText
                                             animated:(BOOL)animated
{
    return showHUDWithMyActivityIndicatorView(view, nil, titleText, animated);
}

@end




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

MBProgressHUD * showCustomMBProgressHUDView(UIView *view,
                                            NSString *titleText,
                                            NSString * detailText,
                                            UIView * customView,
                                            BOOL animated,
                                            void(^completedBlock)(void))
{
    //初始化
    MBProgressHUD * progressHUD = [[MBProgressHUD alloc] init];
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.mode = MBProgressHUDModeCustomView;
    progressHUD.customView = customView;
    progressHUD.label.text = titleText;
    progressHUD.detailsLabel.text =detailText;
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
    [progressHUD show:animated];
    
    return progressHUD;
}

MBProgressHUD * showMessageWithCustomView(UIView *view,
                                          NSString *titleText,
                                          NSString * detailText,
                                          UIView * customView,
                                          NSTimeInterval duration,
                                          void(^completedBlock)(void))
{
    MBProgressHUD * progressHUD = showCustomMBProgressHUDView(view, titleText, detailText, customView, YES, completedBlock);
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    [progressHUD hide:YES afterDelay:duration <= 0.f ? 2.0 : duration];
    
    return progressHUD;
}

MBProgressHUD * showMessage(UIView *view,
                            NSString *titleText,
                            NSString * detailText,
                            NSTimeInterval duration,
                            void(^completedBlock)(void))
{
    MBProgressHUD * progressHUD = showMessageWithCustomView(view,titleText,detailText,nil,duration,completedBlock);
    progressHUD.mode = MBProgressHUDModeText;
    
    return progressHUD;
}

MBProgressHUD * showMessageWithImage(UIView *view,
                                     NSString *titleText,
                                     NSString * detailText,
                                     UIImage * image,
                                     NSTimeInterval duration,
                                     void(^completedBlock)(void))
{
    UIImageView * imageView = image ? [[UIImageView alloc] initWithImage:image] : nil;
    return showMessageWithCustomView(view, titleText, detailText, imageView, duration, completedBlock);
}

MBProgressHUD * showErrorMessage(UIView *view,
                                 NSString *titleText,
                                 NSString *detailText,
                                 NSTimeInterval duration,
                                 void(^completedBlock)(void))
{
    return showMessageWithImage(view,
                                titleText,
                                detailText,
                                ImageWithName(@"error_msg.png"),
                                duration,
                                completedBlock);
}


//显示成功消息
MBProgressHUD * showSuccessMessage(UIView *view,
                                   NSString *titleText,
                                   NSString *detailText,
                                   NSTimeInterval duration,
                                   void(^completedBlock)(void))
{
    return showMessageWithImage(view,
                                titleText,
                                detailText,
                                ImageWithName(@"success_msg.png"),
                                duration,
                                completedBlock);
}

MBProgressHUD * showHUDWithActivityIndicatorView(UIView * view,
                                                 UIView<MyActivityIndicatorViewProtocol> * activityIndicatorView,
                                                 NSString *title,
                                                 BOOL animated)
{
    MBProgressHUD * progressHUD = showCustomMBProgressHUDView(view,
                                                              title,
                                                              nil,
                                                              activityIndicatorView,
                                                              animated,
                                                              nil);
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    progressHUD.userInteractionEnabled = YES;
    if (!view) {
        progressHUD.superview.userInteractionEnabled = YES;
    }
    [activityIndicatorView startAnimating];
    
    return progressHUD;
}

MBProgressHUD * showHUDWithMyActivityIndicatorView(UIView * view, UIColor *color, NSString *title, BOOL animated)
{
    MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
    activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 30.f, 30.f);
    activityIndicatorView.twoStepAnimation = NO;
    activityIndicatorView.tintColor = color ?: [UIColor whiteColor];
    
    return showHUDWithActivityIndicatorView(view, activityIndicatorView, title, animated);
}


void showNetworkStatusMessage(UIView *view)
{
    NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
    if (status == NotReachable) {
        [[XYYMessageUtil shareMessageUtil] showMessageInView:view withTitle:@"当前无可用网络" detail:nil duration:0.0 completedBlock:nil];
    }else if (status == ReachableViaWWAN){
        [[XYYMessageUtil shareMessageUtil] showMessageInView:view withTitle:@"当前处于蜂窝移动网络" detail:nil duration:0.0 completedBlock:nil];
    }else{
        [[XYYMessageUtil shareMessageUtil] showMessageInView:view withTitle:@"当前处于WI-FI网络" detail:nil duration:0.0 completedBlock:nil];
    }
}

