//
//  DNImagePickerController.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/10.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "DNAsset.h"

//----------------------------------------------------------

FOUNDATION_EXTERN NSString *kDNImagePickerStoredGroupKey;
typedef NS_ENUM(NSUInteger, DNImagePickerFilterType) {
    DNImagePickerFilterTypeNone,
    DNImagePickerFilterTypePhotos,
    DNImagePickerFilterTypeVideos,
};

//----------------------------------------------------------

//共享资源库
UIKIT_EXTERN ALAssetsLibrary * shareAssetsLibrary();
UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromDNImagePickerControllerFilterType(DNImagePickerFilterType type);

//----------------------------------------------------------

@class DNImagePickerController;
@protocol DNImagePickerControllerDelegate <NSObject>
@optional
/**
 *  imagePickerController‘s seleted photos
 *
 *  @param imagePickerController
 *  @param imageAssets           the seleted photos packaged DNAsset type instances
 *  @param fullImage             if the value is yes, the seleted photos is full image
 */
- (void)dnImagePickerController:(DNImagePickerController *)imagePicker
                     sendImages:(NSArray<DNAsset *> *)imageAssets
                    isFullImage:(BOOL)fullImage;

- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker;
@end

//----------------------------------------------------------

@interface DNImagePickerController : UINavigationController

//最多选择多少个图片（默认为9）
@property(nonatomic) NSUInteger maxSelectedImageCount;

//是否可以选择原图，默认为NO
@property(nonatomic) BOOL canSelecteFullImage;

@property (nonatomic, assign) DNImagePickerFilterType filterType;
@property (nonatomic, weak) id<DNImagePickerControllerDelegate> imagePickerDelegate;

@end

//----------------------------------------------------------

@interface ALAsset (DNImagePickerController)

//@property(nonatomic,readonly) BOOL isLongImage;

//返回合适的缩略图片
- (UIImage *)suitableThumbnail;
//保持比例
- (UIImage *)suitableAspectRatioThumbnail:(BOOL)copy;


//返回合适的全屏显示图片（考虑长图情况）
- (UIImage *)suitableFullScreenImage;

////返回适合size大小完美显示的封面图
//- (UIImage *)thumbnailForPerfectShowWithSize:(CGSize)size forceClip:(BOOL)forceClip;


@end
