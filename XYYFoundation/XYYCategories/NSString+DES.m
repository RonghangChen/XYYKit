//
//  NSString+DES.m
//  
//
//  Created by 陈荣航 on 2017/12/27.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import "NSString+DES.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSString+Base64.h"

@implementation NSString (DES)

- (NSData *)DESEncodedDataWithKey:(NSString *)key iv:(const void *)iv
{
    if (self.length == 0 || key.length == 0) {
        return nil;
    }
    
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    //生成缓存区
    size_t plainTextBufferSize = [data length];
    size_t bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    uint8_t * bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0, sizeof(uint8_t));
    
    //加密
    size_t numBytesEncrypted = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                                       kCCAlgorithmDES,
                                       iv == NULL ? (kCCOptionECBMode | kCCOptionPKCS7Padding) : kCCOptionPKCS7Padding,
                                       [key UTF8String],
                                       kCCKeySizeDES,
                                       iv,
                                       [data bytes],
                                       plainTextBufferSize,
                                       bufferPtr,
                                       bufferPtrSize,
                                       &numBytesEncrypted);
    
    //生成结果数据
    NSData * desData = nil;
    if (ccStatus == kCCSuccess) {
        desData = [NSData dataWithBytes:bufferPtr length:numBytesEncrypted];
    }
    
    //释放内存
    free(bufferPtr);
    
    return desData;
}

- (NSString *)DESEncodedStringWithKey:(NSString *)key {
    return [self DESEncodedStringWithKey:key iv:NULL];
}

- (NSString *)HexDESEncodedStringWithKey:(NSString *)key
{
    NSData * data = [self DESEncodedDataWithKey:key iv:NULL];
    if (data.length == 0) {
        return nil;
    }
    
    NSUInteger length = data.length;
    NSMutableString * sbuf = [NSMutableString stringWithCapacity:length * 2];
    const unsigned char * buf = data.bytes;
    for (NSInteger i = 0; i < length; ++i) {
        [sbuf appendFormat:@"%02x", (unsigned short)buf[i]];
    }
    
    return [sbuf copy];
}

- (NSString *)DESEncodedStringWithKey:(NSString *)key iv:(const void *)iv {
    return [NSString base64EncodedStringWithData:[self DESEncodedDataWithKey:key iv:iv]];
}


+ (NSData *)_dataWithDESEncodedData:(NSData *)desData key:(NSString *)key iv:(const void *)iv
{
    if (desData.length == 0 || key.length == 0) {
        return nil;
    }
    
    //生成缓存区
    size_t plainTextBufferSize = [desData length];
    size_t bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    uint8_t * bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0, sizeof(uint8_t));
    
    //加密
    size_t numBytesEncrypted = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithmDES,
                                       iv == NULL ? (kCCOptionECBMode | kCCOptionPKCS7Padding) : kCCOptionPKCS7Padding,
                                       [key UTF8String],
                                       kCCKeySizeDES,
                                       iv,
                                       [desData bytes],
                                       plainTextBufferSize,
                                       bufferPtr,
                                       bufferPtrSize,
                                       &numBytesEncrypted);
    
    //生成结果数据
    NSData * data = nil;
    if (ccStatus == kCCSuccess) {
        data = [NSData dataWithBytes:bufferPtr length:numBytesEncrypted];
    }
    
    //释放内存
    free(bufferPtr);
    
    return data;
}

+ (NSString *)stringWithDESEncodedData:(NSData *)desData key:(NSString *)key iv:(const void *)iv
{
    return [[NSString alloc] initWithData:[self _dataWithDESEncodedData:desData key:key iv:iv] encoding:NSUTF8StringEncoding];
}

- (NSData *)DESDecodedDataWithKey:(NSString *)key iv:(const void *)iv {
    return [[self class] _dataWithDESEncodedData:[self base64DecodedData] key:key iv:iv];
}

- (NSString *)DESDecodedStringWithKey:(NSString *)key {
    return [self DESDecodedStringWithKey:key iv:NULL];
}

- (NSString *)DESDecodedStringWithKey:(NSString *)key iv:(const void *)iv
{
    return [[NSString alloc] initWithData:[self DESDecodedDataWithKey:key iv:iv] encoding:NSUTF8StringEncoding];
}

@end
