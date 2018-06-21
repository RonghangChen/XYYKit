//
//  UIImage+size.m
//  
//
//  Created by LeslieChen on 15/12/8.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "UIImage+Representation.h"
#import "UIImage+Alpha.h"
#import "XYYConst.h"
#import "UIImage+Size.h"
#import "UIImage+Orientation.h"

@implementation UIImage (representation)

- (NSUInteger)imageMemorySize
{
    CGImageRef imageRef = [self CGImage];
    return imageRef ? CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef) : 0;
}

#pragma mark -

- (NSData *)representationWithMaxSize:(NSUInteger)maxSize {
    return [self representationWithMaxSize:maxSize minCompressionQuality:0.5f fixOrientation:YES];
}

- (NSData *)representationWithMaxSize:(NSUInteger)maxSize
                minCompressionQuality:(CGFloat)minCompressionQuality
                       fixOrientation:(BOOL)fixOrientation
{
    if (maxSize == 0) {
        return nil;
    }
    
    //修正方向
    UIImage * image = fixOrientation ? [self fixOrientationImage] : self;
    
    //首先进行编码的压缩
    minCompressionQuality = ChangeInMinToMax(minCompressionQuality, 0.f, 1.f);
    NSData * representationData = [image _representationWithMaxSize:maxSize minCompressionQuality:minCompressionQuality];
    if (representationData == nil) { //如果最小质量下仍大于maxSize，则进行尺寸的压缩
        
        CGSize imageSize = self.size;
        
        //缩小图片尺寸直至图片编码后的大小小于maxSize
        do {
            
            imageSize.width  *= 0.9f;
            imageSize.height *= 0.9f;
            
            representationData = [[image imageWithSize:imageSize zoomMode:MyZoomModeFill]  _representationWithMaxSize:maxSize minCompressionQuality:minCompressionQuality];
            
        } while (representationData == nil);
        
    }
    
    return representationData;
}

- (NSData *)_representationWithMaxSize:(NSUInteger)maxSize minCompressionQuality:(CGFloat)minCompressionQuality
{
    //尝试使用jpeg压缩编码，降低压缩质量直至不能降低或者质量达到最低
    NSData * representationData = nil;
    CGFloat compressionQuality = 1.f;
    do {
        @autoreleasepool {
            representationData = UIImageJPEGRepresentation(self, compressionQuality);
        }
        if (compressionQuality > minCompressionQuality) {
            compressionQuality = MAX(MAX(0.f, minCompressionQuality - 0.0001f), compressionQuality - 0.1f);
        }else {
            break;
        }
        
    } while (representationData.length > maxSize);
    
    
    return representationData.length <= maxSize ? representationData : nil;
}

#pragma mark -

- (NSData *)representationData:(CGFloat)compressionQuality {
    return [self representationData:compressionQuality fixOrientation:YES];
}

- (NSData *)representationData:(CGFloat)compressionQuality fixOrientation:(BOOL)fixOrientation
{
    UIImage * image = fixOrientation ? [self fixOrientationImage] : nil;
    return [image hasAlpha] ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, compressionQuality);
}

#pragma mark -

+ (UIImage *)decodeImageWithData:(NSData *)data
{
    UIImage * image = [UIImage imageWithData:data];
    if (image != nil) {
        
        CGImageRef cgImage = image.CGImage;
        if (cgImage == NULL) {
            return image;
        }
        
        size_t width = CGImageGetWidth(cgImage);
        size_t height = CGImageGetHeight(cgImage);
        if (width == 0 || height == 0) {
            return image;
        }
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        //是否有alpha通道
        BOOL hasAlpha = NO;
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
        if (alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaFirst||
            alphaInfo == kCGImageAlphaLast) {
            hasAlpha = YES;
        }
        
        //
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host | (hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
        
        CGContextRef ctx = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);

        //绘制图像
        CGContextDrawImage(ctx, CGRectMake(0.f, 0.f, width, height), cgImage);


        CGImageRef newImage = CGBitmapContextCreateImage(ctx);
        UIImage * result = [UIImage imageWithCGImage:newImage];

        //释放内存
        CGContextRelease(ctx);
        CGImageRelease(newImage);
        CGColorSpaceRelease(colorSpace);

        return result;
    }

    return nil;
}


@end
