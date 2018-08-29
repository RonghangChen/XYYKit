//
//  MyMultipleImagePickerController.m
//  
//
//  Created by LeslieChen on 15/11/2.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyMultipleImagePickerController.h"
#import "MyImagePickerViewController.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@implementation MyMultipleImagePickerController
{
    MyViewControllerTransitioningDelegate * _myTransitioningDelegate;
}

+ (BOOL)isAuthorizedForImagePicker {
    return [MyImagePickerViewController isAuthorizedForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (instancetype)imagePickerViewControllerWithSelectedImageCount:(NSUInteger)selectedImageCount
                                                     filterType:(DNImagePickerFilterType)filterType
                                            canSelecteFullImage:(BOOL)canSelecteFullImage
                                                       delegate:(id<DNImagePickerControllerDelegate>)delegate
{
    if (![self isAuthorizedForImagePicker]) {
        [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:@"应用无权访问您的相册,请在\"设置->隐私\"中设置"];
    }else {
        
        MyMultipleImagePickerController * imagePickerViewController = [[self alloc] init];
        imagePickerViewController.maxSelectedImageCount = selectedImageCount;
        imagePickerViewController.filterType = filterType;
        imagePickerViewController.canSelecteFullImage = canSelecteFullImage;
        imagePickerViewController.imagePickerDelegate = delegate;
        return imagePickerViewController;
    }
    
    return nil;
}

//显示图像采集,显示成功返回实例否则返回nil
+ (instancetype)showImagePickerViewControllerWithSelectedImageCount:(NSUInteger)selectedImageCount
                                                         filterType:(DNImagePickerFilterType)filterType
                                                canSelecteFullImage:(BOOL)canSelecteFullImage
                                                basicViewController:(UIViewController *)basicViewController
                                                           delegate:(id<DNImagePickerControllerDelegate>)delegate
                                                           animated:(BOOL)animated
                                                     completedBlock:(void (^)(void))completedBlock
{
    MyMultipleImagePickerController * imagePickerController = [self imagePickerViewControllerWithSelectedImageCount:selectedImageCount
                                                                                                         filterType:filterType
                                                                                                canSelecteFullImage:canSelecteFullImage
                                                                                                           delegate:delegate];
    
    if (imagePickerController && basicViewController) {
        if ([basicViewController showViewControllerWithDesignatedWay:imagePickerController
                                                            animated:animated
                                                      completedBlock:completedBlock]) {
            return imagePickerController;
        }
    }
    
    return nil;
}

#pragma amrk -

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.interactiveDismissEnable = YES;
    
    if (![self.transitioningDelegate isKindOfClass:[MyViewControllerTransitioningDelegate class]]) {
        _myTransitioningDelegate = [[MyViewControllerTransitioningDelegate alloc] init];
        [_myTransitioningDelegate presentViewController:self];
    }
}

#pragma mark -

- (UIViewController *)childViewControllerForViewControllerTransitioning {
    return nil;
}

- (BOOL)interactiveDismissGestureShouldReceiveTouch:(UITouch *)touch {
    return CGRectContainsPoint(self.navigationBar.bounds, [touch locationInView:self.navigationBar]);
}

@end
