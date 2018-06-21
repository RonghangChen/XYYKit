//
//  DNAssetsViewCell.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/11.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>

//----------------------------------------------------------

@class DNAssetsViewCell;

@protocol DNAssetsViewCellDelegate <NSObject>
@optional

- (BOOL)didSelectItemAssetsViewCell:(DNAssetsViewCell *)assetsCell;
- (void)didDeselectItemAssetsViewCell:(DNAssetsViewCell *)assetsCell;
@end

//----------------------------------------------------------

@interface DNAssetsViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImage * image;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, weak) id<DNAssetsViewCellDelegate> delegate;

@end
