//
//  DNBrowserCell.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/28.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class DNPhotoBrowser;

@interface DNBrowserCell : UICollectionViewCell

@property (nonatomic, weak) DNPhotoBrowser *photoBrowser;

@property (nonatomic, strong) ALAsset *asset;

@property(nonatomic,strong) UIImage * image;
- (void)setImage:(UIImage *)image sourceImageSize:(CGSize)sourceImageSize;

@end
