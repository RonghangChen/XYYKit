//
//  MyScanImageCell.h
//  
//
//  Created by LeslieChen on 15/11/6.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyScanImageData.h"
#import "MyScanImageView.h"

//----------------------------------------------------------

@class MyScanImageCell;
@protocol MyScanImageCellDelegate <NSObject>

@optional

//点击了隐藏（单击）
- (void)scanImageCellDidTapHide:(MyScanImageCell *)cell;

//改变了图片加载状态
- (void)scanImageCellDidChangeImageDisplayState:(MyScanImageCell *)cell;

@end

//----------------------------------------------------------

@interface MyScanImageCell : UICollectionViewCell

- (void)displayImage:(MyScanImageData *)scanImageData;
- (void)displayImage:(MyScanImageData *)scanImageData forAnimationCalculation:(BOOL)forAnimationCalculation;

//更新安全区
- (void)updateWithSafeAreaInsets:(UIEdgeInsets)safeAreaInsets;

@property(nonatomic,strong,readonly) MyScanImageData * scanImageData;

//正在显示的图片
@property(nonatomic,strong,readonly) UIImage * displayingImage;
//图片的显示状态
@property(nonatomic,readonly) MyScanImageDisplayState imageDisplayState;

//图片视图
@property(nonatomic,strong,readonly) UIImageView * imageView;
@property(nonatomic,weak) id<MyScanImageCellDelegate> delegate;

//是否显示的图片是长图
@property(nonatomic,readonly) BOOL isDisplayLongImage;

@end
