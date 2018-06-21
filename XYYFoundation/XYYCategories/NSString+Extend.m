//
//  NSString+Extend.m
//  
//
//  Created by 陈荣航 on 16/4/20.
//  Copyright © 2016年 ED. All rights reserved.
//

#import "NSString+Extend.h"
#import <UIKit/UIKit.h>

@implementation NSString (Extend)

- (NSArray *)allRangeOfString:(NSString *)string
{
    if (string.length == 0 || self.length == 0) {
        return nil;
    }
    
    NSMutableArray * ranges = [NSMutableArray array];
    NSRange filterRange = [self rangeOfString:string];
    while (filterRange.length) {
        [ranges addObject:[NSValue valueWithRange:filterRange]];
        filterRange = [self rangeOfString:string options:NSCaseInsensitiveSearch range:NSMakeRange(filterRange.location + filterRange.length, self.length - filterRange.location - filterRange.length)];
    }

    return ranges;
}

- (NSString *)stringByInsertMark:(NSString *)mark withSpace:(NSUInteger)space {
    return [self stringByInsertMark:mark withSpace:space reverse:NO];
}

- (NSString *)stringByInsertMark:(NSString *)mark withSpace:(NSUInteger)space reverse:(BOOL)reverse
{
    if (self.length < space || space <= 0 || mark.length == 0) {
        return self;
    }
    
    NSInteger count = ceilf(self.length / (CGFloat)space) - 1;
    NSMutableString * string = [NSMutableString stringWithCapacity:self.length + count];
    for (NSInteger i = 0; i <= count ; ++ i) {
        
        if (reverse) {
            
            [string insertString:[self substringWithRange:NSMakeRange(MAX(0, (NSInteger)(self.length - i * space - space)), MIN(space, self.length - i * 4))] atIndex:0];
            
            if (i < count) {
                [string insertString:mark atIndex:0];
            }
            
        }else {
            
            [string appendString:[self substringWithRange:NSMakeRange(i * space, MIN(space, self.length - i * space))]];
            
            if (i < count) {
                [string appendString:mark];
            }
        }
    }
    
    return [NSString stringWithString:string];
}

- (NSString *)firstUppercaseString
{
    if (self.length == 0) {
        return self;
    }else if (self.length == 1) {
        return self.uppercaseString;
    }else {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[self substringWithRange:NSMakeRange(0, 1)].uppercaseString];
    }
}

- (NSString *)firstLowercaseString
{
    if (self.length == 0) {
        return self;
    }else if (self.length == 1) {
        return self.lowercaseString;
    }else {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[self substringWithRange:NSMakeRange(0, 1)].lowercaseString];
    }
}

+ (NSString *)randomStringWithLength:(NSUInteger)length
{
    NSString * randomString = nil;
    
    if (length != 0) {
        
        char  *digest = malloc(length * sizeof(char));
        
        for (int i = 0; i< length;  ++ i) {
            
            int j = '0' + (arc4random_uniform(75));
            
            if((j>=58 && j<= 64) || (j>=91 && j<=96)){
                -- i;
            }else{
                digest[i] = (char)j;
            }
        }
        
        randomString = [[NSString alloc] initWithBytes:digest length:length encoding:NSUTF8StringEncoding];
        
        free(digest);
    }
    
    return randomString;
}

+ (NSString *)uniqueIDString
{
    //创建一个CFUUIDRef类型对象
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    
    //获得一个唯一的字符ID
    CFStringRef newUniqueString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    //转换成NSString
    NSString *str = (__bridge NSString *)newUniqueString;
    
    //释放
    CFRelease(newUniqueID);
    CFRelease(newUniqueString);
    
    return str;
}

- (float)versionFloatVaule
{
    if (self.length == 0) {
        return 0.f;
    }
    
    NSArray * components = [self componentsSeparatedByString:@"."];
    
    NSInteger count = components.count;
    if (count >= 2) {
        NSMutableString * versionStr = [NSMutableString stringWithFormat:@"%@.",[components firstObject]];
        for (NSInteger i = 1; i < count; ++ i) {
            [versionStr appendString:components[i]];
        }
        return [versionStr floatValue];
    }else {
        return [[components firstObject] floatValue];
    }
}

@end
