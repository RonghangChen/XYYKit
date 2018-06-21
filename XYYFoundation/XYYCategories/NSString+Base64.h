//
//  NSString+Base64.h
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 15/2/8.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

//编码
+ (NSString *)base64EncodedStringWithData:(NSData *)data;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSData *)base64EncodedDataWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSData *)base64EncodedData;

//解码
+ (NSString *)stringWithBase64EncodedData:(NSData *)base64Data;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

@end
