//
//  NSString+Base64.m
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 15/2/8.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "NSString+Base64.h"
#import "NSData+Base64.h"

@implementation NSString (Base64)

+ (NSString *)base64EncodedStringWithData:(NSData *)data {
    return [data base64EncodedString];
}

+ (NSString *)stringWithBase64EncodedData:(NSData *)base64Data {
    return [base64Data base64DecodedString];
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSData *)base64EncodedDataWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedDataWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString {
    return [self base64EncodedStringWithWrapWidth:0];
}

- (NSData *)base64EncodedData {
    return [self base64EncodedDataWithWrapWidth:0];
}

- (NSString *)base64DecodedString
{
    NSData * data = [NSData dataWithBase64EncodedString:self];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)base64DecodedData {
    return [NSData dataWithBase64EncodedString:self];
}
@end
