//
//  MyScanImageData.m
//  
//
//  Created by LeslieChen on 15/11/6.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "MyScanImageData.h"

@implementation MyScanImageData

@synthesize imagePlaceholderColor = _imagePlaceholderColor;

- (id)initWithSourceImageURL:(NSString *)sourceImageURL
{
    return [self initWithThumb:nil
               sourceImageSize:CGSizeZero
                thumbShowFrame:CGRectZero
         thumbShowCornerRadius:0.f
         imagePlaceholderColor:nil
                   sourceImage:nil
                sourceImageURL:sourceImageURL];
}

- (id)initWithImageView:(UIImageView *)imageView
            sourceImage:(UIImage *)sourceImage
         sourceImageURL:(NSString *)sourceImageURL
{
    return [self initWithImageView:imageView
                   sourceImageSize:CGSizeZero
                       sourceImage:sourceImage
                    sourceImageURL:sourceImageURL];
}

- (id)initWithImageView:(UIImageView *)imageView
        sourceImageSize:(CGSize)sourceImageSize
            sourceImage:(UIImage *)sourceImage
         sourceImageURL:(NSString *)sourceImageURL
{
    return [self initWithThumb:imageView.image
               sourceImageSize:sourceImageSize
                thumbShowFrame:[imageView convertRect:imageView.bounds toView:imageView.window]
         thumbShowCornerRadius:imageView.layer.cornerRadius
         imagePlaceholderColor:imageView.backgroundColor
                   sourceImage:sourceImage
                sourceImageURL:sourceImageURL];
}

- (id)initWithSourceImageSize:(CGSize)sourceImageSize
        imagePlaceholderColor:(UIColor *)imagePlaceholderColor
               sourceImageURL:(NSString *)sourceImageURL
{
    return [self initWithThumb:nil
               sourceImageSize:sourceImageSize
                thumbShowFrame:CGRectZero
         thumbShowCornerRadius:0.f
         imagePlaceholderColor:imagePlaceholderColor
                   sourceImage:nil
                sourceImageURL:sourceImageURL];
}

- (id)      initWithThumb:(UIImage *)thumb
          sourceImageSize:(CGSize)sourceImageSize
           thumbShowFrame:(CGRect)thumbShowFrame
    thumbShowCornerRadius:(CGFloat)thumbShowCornerRadius
    imagePlaceholderColor:(UIColor *)imagePlaceholderColor
              sourceImage:(UIImage *)sourceImage
           sourceImageURL:(NSString *)sourceImageURL
{ 
    self = [super init];
    if (self) {
        
        _thumb = thumb;
        _sourceImageSize = sourceImageSize;
        _thumbShowFrame = thumbShowFrame;
        _thumbShowCornerRadius = thumbShowCornerRadius;
        _sourceImage = sourceImage;
        _sourceImageURL = sourceImageURL;
        
        //确保背景色不是透明的
        if (imagePlaceholderColor) {
            CGFloat alpha = 0.f;
            if([imagePlaceholderColor getWhite:NULL alpha:&alpha] ||
               [imagePlaceholderColor getRed:NULL green:NULL blue:NULL alpha:&alpha] ||
               [imagePlaceholderColor getHue:NULL saturation:NULL brightness:NULL alpha:&alpha]) {
                if (alpha <= 0.f) {
                    imagePlaceholderColor = nil;
                }
            }else {
                imagePlaceholderColor = nil;
            }
        }
        _imagePlaceholderColor = imagePlaceholderColor;
    }
    
    return self;
}

- (UIColor *)imagePlaceholderColor {
    return _imagePlaceholderColor ?: (_imagePlaceholderColor = [UIColor whiteColor]);
}

@end
