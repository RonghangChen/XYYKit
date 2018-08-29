//
//  MyImagePickerViewController.m
//  
//
//  Created by LeslieChen on 15/3/19.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyImagePickerViewController.h"
#import "XYYFoundation.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

//----------------------------------------------------------

@interface MyImagePickerViewController () < UINavigationControllerDelegate,
                                            UIImagePickerControllerDelegate >

@end

//----------------------------------------------------------

@implementation MyImagePickerViewController
{
    MyViewControllerTransitioningDelegate * _myTransitioningDelegate;
}

+ (BOOL)isAuthorizedForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if(sourceType == UIImagePickerControllerSourceTypeCamera){
        
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        return authorizationStatus == AVAuthorizationStatusAuthorized || authorizationStatus == AVAuthorizationStatusNotDetermined;
    }else{
        
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        return authorizationStatus == ALAuthorizationStatusAuthorized || authorizationStatus == ALAuthorizationStatusNotDetermined;
    }
}

+ (instancetype)imagePickerViewControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
                                              delegate:(id<MyImagePickerControllerDelegate>)delegate
{
    if (![self isSourceTypeAvailable:sourceType]) {
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:@"无相机资源可获取"];
        }else{
            [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:@"无相册资源可获取"];
        }
    }else if (![self isAuthorizedForSourceType:sourceType]){
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:@"应用无权访问您的相机,请在\"设置->隐私\"中设置"];
        }else{
            [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:@"应用无权访问您的相册,请在\"设置->隐私\"中设置"];
        }
    }else{
        MyImagePickerViewController * imagePickerViewController = [[self alloc] init];
        imagePickerViewController.sourceType = sourceType;
        imagePickerViewController.imagePickerDelegate = delegate;
        return imagePickerViewController;
    }
    
    return nil;
}

+ (instancetype)showImagePickerViewControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
                                       basicViewController:(UIViewController *)basicViewController
                                                  delegate:(id<MyImagePickerControllerDelegate>)delegate
                                                  animated:(BOOL)animated
                                            completedBlock:(void (^)(void))completedBlock
{
    MyImagePickerViewController * imagePickerViewController = [self imagePickerViewControllerForSourceType:sourceType delegate:delegate];
    
    if (imagePickerViewController && basicViewController) {
        
        if ([basicViewController showViewControllerWithDesignatedWay:imagePickerViewController
                                                            animated:animated
                                                      completedBlock:completedBlock]) {
            return imagePickerViewController;
        }
    }
    
    return nil;
}

#pragma amrk -

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.interactiveDismissEnable = YES;
    self.delegate = self;
    
    if (![self.transitioningDelegate isKindOfClass:[MyViewControllerTransitioningDelegate class]]) {
        _myTransitioningDelegate = [[MyViewControllerTransitioningDelegate alloc] init];
        [_myTransitioningDelegate presentViewController:self];
    }
}

#pragma amrk -

- (UIViewController *)childViewControllerForViewControllerTransitioning {
    return nil;
}

- (BOOL)interactiveDismissGestureShouldReceiveTouch:(UITouch *)touch
{
    if (self.sourceType != UIImagePickerControllerSourceTypeCamera) {
        return CGRectContainsPoint(self.navigationBar.bounds, [touch locationInView:self.navigationBar]);
    }
    
    return YES;
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<MyImagePickerControllerDelegate> imagePickerDelegate = self.imagePickerDelegate;
    ifRespondsSelector(imagePickerDelegate, @selector(imagePickerController:didFinishPickingMediaWithInfo:)){
        [imagePickerDelegate imagePickerController:(MyImagePickerViewController*)picker
                     didFinishPickingMediaWithInfo:info];
    }else{
        [picker hideWithDesignatedWay:YES completedBlock:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    id<MyImagePickerControllerDelegate> imagePickerDelegate = self.imagePickerDelegate;
    ifRespondsSelector(imagePickerDelegate, @selector(imagePickerControllerDidCancel:)){
        [imagePickerDelegate imagePickerControllerDidCancel:(MyImagePickerViewController *)picker];
    }else{
        [picker hideWithDesignatedWay:YES completedBlock:nil];
    }
}

#pragma mark -

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarHidden:self.sourceType == UIImagePickerControllerSourceTypeCamera];
}

#pragma mark -

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.sourceType == UIImagePickerControllerSourceTypeCamera;
}

@end
