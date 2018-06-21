//
//  NSString+DES.h
//  
//
//  Created by 陈荣航 on 2017/12/27.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DES)

//des加密,返回string时会进行base64编码
- (NSData *)DESEncodedDataWithKey:(NSString *)key iv:(const void *)iv;
- (NSString *)DESEncodedStringWithKey:(NSString *)key;
- (NSString *)HexDESEncodedStringWithKey:(NSString *)key;//16进制格式化输出
- (NSString *)DESEncodedStringWithKey:(NSString *)key iv:(const void *)iv;

//des解密，使用string时会进行base64解码
+ (NSString *)stringWithDESEncodedData:(NSData *)desData key:(NSString *)key iv:(const void *)iv;
- (NSData *)DESDecodedDataWithKey:(NSString *)key iv:(const void *)iv;
- (NSString *)DESDecodedStringWithKey:(NSString *)key;
- (NSString *)DESDecodedStringWithKey:(NSString *)key iv:(const void *)iv;

@end
