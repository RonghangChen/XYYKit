//
//  MyScanImageData.h
//  
//
//  Created by LeslieChen on 15/11/6.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 用于浏览的图片数据（包括图片的数据或url，及大小，原显示大小等信息）
 */
@interface MyScanImageData : NSObject

- (id)initWithSourceImageURL:(NSString *)sourceImageURL;

- (id)initWithImageView:(UIImageView *)imageView
            sourceImage:(UIImage *)sourceImage
         sourceImageURL:(NSString *)sourceImageURL;

- (id)initWithImageView:(UIImageView *)imageView
        sourceImageSize:(CGSize)sourceImageSize
            sourceImage:(UIImage *)sourceImage
         sourceImageURL:(NSString *)sourceImageURL;

- (id)initWithSourceImageSize:(CGSize)sourceImageSize
        imagePlaceholderColor:(UIColor *)imagePlaceholderColor
               sourceImageURL:(NSString *)sourceImageURL;

- (id)      initWithThumb:(UIImage *)thumb
          sourceImageSize:(CGSize)sourceImageSize
           thumbShowFrame:(CGRect)thumbShowFrame
    thumbShowCornerRadius:(CGFloat)thumbShowCornerRadius
    imagePlaceholderColor:(UIColor *)imagePlaceholderColor
              sourceImage:(UIImage *)sourceImage
           sourceImageURL:(NSString *)sourceImageURL;

//缩略图
@property(nonatomic,strong,readonly) UIImage * thumb;


//原图大小（基于像素），如果缩略图不为nil以缩略图size为准（用于无thumb时的占位大小）
@property(nonatomic,readonly) CGSize sourceImageSize;


//缩略图显示的位置（基于window,用于动画），如果改值为CRectZero则使用简单的动画
@property(nonatomic,readonly) CGRect thumbShowFrame;

//缩略图显示的边角（用于动画）
@property(nonatomic,readonly) CGFloat thumbShowCornerRadius;

//原图和原图url（有原图优先使用原图）
@property(nonatomic,strong,readonly) UIImage * sourceImage;
@property(nonatomic,strong,readonly) NSString * sourceImageURL;

//占位颜色
@property(nonatomic,strong,readonly) UIColor * imagePlaceholderColor;

//上下文
@property(nonatomic,strong) id context;

@end
