//
//  XYYMessageUtil.h
//  XYYFoundation
//
//  Created by 陈荣航 on 2018/6/21.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XYYProgressViewProtocol <NSObject>
- (void)hideWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;
@end


@interface XYYMessageUtil : NSObject

//共享的
+ (XYYMessageUtil *)shareMessageUtil;
//设置使用共享的消息工具类，可以设置继承的工具类自定义消息展示
+ (void)setupShareMessageUtil:(XYYMessageUtil *)messageUtil;

//自定义视图消息
- (void)showMessageInView:(UIView *)view
                withTitle:(NSString *)titleText
                   detail:(NSString *)detailText
               customView:(UIView *)customView
                 duration:(NSTimeInterval)duration
           completedBlock:(void(^)(void))completedBlock;

//文本消息
- (void)showMessageInView:(UIView *)view
                withTitle:(NSString *)titleText
                   detail:(NSString *)detailText
                 duration:(NSTimeInterval)duration
           completedBlock:(void(^)(void))completedBlock;


//错误消息
- (void)showErrorMessageInView:(UIView *)view
                     withTitle:(NSString *)titleText
                        detail:(NSString *)detailText
                      duration:(NSTimeInterval)duration
                completedBlock:(void(^)(void))completedBlock;
- (void)showErrorMessageInView:(UIView *)view
                     withTitle:(NSString *)titleText
                         error:(NSError *)error
                      duration:(NSTimeInterval)duration
                completedBlock:(void(^)(void))completedBlock;

//成功消息
- (void)showSuccessMessageInView:(UIView *)view
                       withTitle:(NSString *)titleText
                           detail:(NSString *)detailText
                        duration:(NSTimeInterval)duration
                  completedBlock:(void(^)(void))completedBlock;

//显示Alert视图
- (void)showAlertViewWithTitle:(NSString *)titleText content:(NSString *)contentText;
- (void)showAlertViewWithTitle:(NSString *)titleText
                       content:(NSString *)contentText
                        okText:(NSString *)okText
                    cancleText:(NSString *)cancleText
                   actionBlock:(void(^)(BOOL ok))actionBlock;


//进度视图
- (id<XYYProgressViewProtocol>)showProgressViewInView:(UIView *)view
                                            withTitle:(NSString *)titleText
                                             animated:(BOOL)animated;


@end


@class     MBProgressHUD;
@protocol  MyActivityIndicatorViewProtocol;


MBProgressHUD * showCustomMBProgressHUDView(UIView *view,
                                            NSString *titleText,
                                            NSString * detailText,
                                            UIView * customView,
                                            BOOL animated,
                                            void(^completedBlock)(void));

//显示带有用户视图的消息
MBProgressHUD * showMessageWithCustomView(UIView *view,
                                          NSString *titleText,
                                          NSString * detailText,
                                          UIView * customView,
                                          NSTimeInterval duration,
                                          void(^completedBlock)(void));

//显示文本消息
MBProgressHUD * showMessage(UIView *view,
                            NSString *titleText,
                            NSString * detailText,
                            NSTimeInterval duration,
                            void(^completedBlock)(void));


//显示图像消息
MBProgressHUD * showMessageWithImage(UIView *view,
                                     NSString *titleText,
                                     NSString * detailText,
                                     UIImage * image,
                                     NSTimeInterval duration,
                                     void(^completedBlock)(void));

//显示错误消息
MBProgressHUD * showErrorMessage(UIView *view,
                                 NSString *titleText,
                                 NSString *detailText,
                                 NSTimeInterval duration,
                                 void(^completedBlock)(void));

//显示成功消息
MBProgressHUD * showSuccessMessage(UIView *view,
                                   NSString *titleText,
                                   NSString * detailText,
                                   NSTimeInterval duration,
                                   void(^completedBlock)(void));


//显示MBProgressHUD进度
MBProgressHUD * showHUDWithActivityIndicatorView(UIView * view,
                                                 UIView<MyActivityIndicatorViewProtocol> * activityIndicatorView,
                                                 NSString *title,
                                                 BOOL animated);
MBProgressHUD * showHUDWithMyActivityIndicatorView(UIView * view,
                                                   UIColor *color,
                                                   NSString *title,
                                                   BOOL animated);


//显示当前网络环境
void showNetworkStatusMessage(UIView *view);

