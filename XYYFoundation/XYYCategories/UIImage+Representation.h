//
//  UIImage+size.h
//  
//
//  Created by LeslieChen on 15/12/8.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (representation)

/**
 * @brief  返回图片占用的内存大小(bytes)，只是粗略计算图片内容占的内存大小
 * @return 图片占用的内存大小(bytes)
 */
- (NSUInteger)imageMemorySize;

/**
 * @brief 将图片进行特定编码，如果图片有alpha通道则使用png编码，没有则使用JPEG编码
 * @param compressionQuality compressionQuality为使用JPEG编码时的压缩质量，0~1之间
 * @param fixOrientation fixOrientation是否修正方向，默认为YES
 * @return 编码后的数据
 */
- (NSData *)representationData:(CGFloat)compressionQuality;
- (NSData *)representationData:(CGFloat)compressionQuality fixOrientation:(BOOL)fixOrientation;

/**
 * @brief 压缩图片获取大小小于maxSize(bytes)的图片编码数据，并修正方向
 * @param maxSize maxSize为最大占用的大小
 * @param minCompressionQuality minCompressionQuality为最小的压缩质量，0~1之间,默认为0.5f
 * @param fixOrientation fixOrientation是否修正方向，默认为YES
 * @return 编码后的数据,格式为jpeg
 */
- (NSData *)representationWithMaxSize:(NSUInteger)maxSize;
- (NSData *)representationWithMaxSize:(NSUInteger)maxSize
                minCompressionQuality:(CGFloat)minCompressionQuality
                       fixOrientation:(BOOL)fixOrientation;


/**
 * @brief  返回解码的图片对象
 * @return 返回图像对象
 */
+ (UIImage *)decodeImageWithData:(NSData *)data;

@end
