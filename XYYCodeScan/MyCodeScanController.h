//
//  MyCodeScanController.h
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyCodeTypeDef.h"

//----------------------------------------------------------

@interface MyCodeScanController : NSObject

//获取编码后的图片
+ (UIImage *)codeImageWithData:(NSString *)data
                          size:(CGSize)imageSize
                          type:(MyCodeType)codeType;
+ (UIImage *)codeImageWithData:(NSString *)data
                          size:(CGSize)imageSize
                        margin:(CGFloat)margin
                          type:(MyCodeType)codeType;


//解码图片
+ (NSArray<NSString *> *)dataWithCodeImage:(UIImage *)codeImage forType:(MyCodeType)codeType;

@end
