//
//  UIFont+SystemFont.m
//  
//
//  Created by 钱伟龙 on 16/7/27.
//  Copyright © 2016年 ED. All rights reserved.
//

#import "UIFont+SystemFont.h"

@implementation UIFont (SystemFont)

+ (instancetype)lightSystemFontWithSize:(CGFloat)fontSize
{
    UIFontDescriptor * fd = [UIFontDescriptor fontDescriptorWithFontAttributes:@{@"NSCTFontUIUsageAttribute" : @"CTFontLightUsage"}];
    return [UIFont fontWithDescriptor:fd size:fontSize];
}

+ (instancetype)mediumSystemFontWithSize:(CGFloat)fontSize
{
    UIFontDescriptor * fd = [UIFontDescriptor fontDescriptorWithFontAttributes:@{@"NSCTFontUIUsageAttribute" : @"CTFontMediumUsage"}];
    return [UIFont fontWithDescriptor:fd size:fontSize];
}

+ (instancetype)semiBoldSystemFontWithSize:(CGFloat)fontSize
{
    UIFontDescriptor * fd = [UIFontDescriptor fontDescriptorWithFontAttributes:@{@"NSCTFontUIUsageAttribute" : @"CTFontEmphasizedUsage"}];
    return [UIFont fontWithDescriptor:fd size:fontSize];
}

@end
