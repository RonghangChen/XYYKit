//
//  XYYMessageUtil.h
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class     MBProgressHUD;
@protocol  MyActivityIndicatorViewProtocol;

MBProgressHUD * showCustomMBProgressHUDView(UIView *view,
                                            NSString *titleText,
                                            NSString * detailText,
                                            UIView * customView,
                                            void(^completedBlock)(void));

//显示带有用户视图的消息
MBProgressHUD * showMessageWithCustomView(UIView *view,
                                          NSString *titleText,
                                          NSString * detailText,
                                          UIView * customView);
MBProgressHUD * showMessageWithCustomView_c(UIView *view,
                                            NSString *titleText,
                                            NSString * detailText,
                                            UIView * customView,
                                            NSTimeInterval duration,
                                            void(^completedBlock)(void));

//显示文本消息
MBProgressHUD * showMessage(UIView *view,
                            NSString *titleText,
                            NSString * detailText);

MBProgressHUD * showMessage_c(UIView *view,
                              NSString *titleText,
                              NSString * detailText,
                              NSTimeInterval duration,
                              void(^completedBlock)(void));


//显示图像消息
MBProgressHUD * showMessageWithImage(UIView *view,
                                     NSString *titleText,
                                     NSString * detailText,
                                     UIImage * image);

MBProgressHUD * showMessageWithImage_c(UIView *view,
                                       NSString *titleText,
                                       NSString * detailText,
                                       UIImage * image,
                                       NSTimeInterval duration,
                                       void(^completedBlock)(void));

//显示错误消息
MBProgressHUD * showErrorMessage(UIView *view,
                                 NSError *error,
                                 NSString *titleText);
MBProgressHUD * showErrorMessage_b(UIView *view,
                                   NSError *error,
                                   NSString *titleText,
                                   void(^completedBlock)(void));
MBProgressHUD * showErrorMessage_c(UIView *view,
                                   NSString *titleText,
                                   NSString *detailText,
                                   NSTimeInterval duration,
                                   void(^completedBlock)(void));

//显示成功消息
MBProgressHUD * showSuccessMessage(UIView *view,
                                   NSString *titleText,
                                   NSString * detailText);
MBProgressHUD * showSuccessMessage_b(UIView *view,
                                     NSString *titleText,
                                     NSString * detailText,
                                     void(^completedBlock)(void));
MBProgressHUD * showSuccessMessage_c(UIView *view,
                                     NSString *titleText,
                                     NSString *detailText,
                                     NSTimeInterval duration,
                                     void(^completedBlock)(void));


//显示MBProgressHUD进度
MBProgressHUD * showHUDWithActivityIndicatorView(UIView * view,
                                                 UIView<MyActivityIndicatorViewProtocol> * activityIndicatorView,
                                                 NSString *title);
MBProgressHUD * showHUDWithMyActivityIndicatorView(UIView * view, UIColor *color, NSString *title);


//显示当前网络环境
void showNetworkStatusMessage(UIView *view);


//显示警告视图
UIAlertView * showAlertView(NSString *titleText,NSString * detailText);

