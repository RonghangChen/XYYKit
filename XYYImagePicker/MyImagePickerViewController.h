//
//  MyImagePickerViewController.h
//  
//
//  Created by LeslieChen on 15/3/19.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class MyImagePickerViewController;

//----------------------------------------------------------

@protocol MyImagePickerControllerDelegate<NSObject>

@optional

- (void)imagePickerController:(MyImagePickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(MyImagePickerViewController *)picker;

@end

//----------------------------------------------------------

@interface MyImagePickerViewController : UIImagePickerController

//是否认证通过
+ (BOOL)isAuthorizedForSourceType:(UIImagePickerControllerSourceType)sourceType;


+ (instancetype)imagePickerViewControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
                                              delegate:(id<MyImagePickerControllerDelegate>)delegate;

//显示图像采集,显示成功返回实例否则返回nil
+ (instancetype)showImagePickerViewControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
                                       basicViewController:(UIViewController *)basicViewController
                                                  delegate:(id<MyImagePickerControllerDelegate>)delegate
                                                  animated:(BOOL)animated
                                            completedBlock:(void (^)(void))completedBlock;

@property(nonatomic) UIStatusBarStyle statusBarStyle;
@property(nonatomic,weak) id<MyImagePickerControllerDelegate> imagePickerDelegate;

@end
