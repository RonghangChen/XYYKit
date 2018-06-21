//
//  NSDictionary+MyCategory.m

//
//  Created by LeslieChen on 15/1/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "NSDictionary+MyCategory.h"
#import "UIViewController+Instance.h"
#import "ScreenAdaptation.h"
#import "UIColor+HexString.h"

@implementation NSDictionary (MyCategory)

#pragma mark -

- (id)valueForKey:(id)key withClass:(Class)valueClass
{
    if (key != nil) {
        id value = self[key];
        if (!valueClass || [value isKindOfClass:valueClass]) {
            return value;
        }
    }
    return nil;
}

- (id)valueForKey:(id)key canRespondsToSelector:(SEL)selector
{
    if (key != nil) {
        id value = self[key];
        if (!selector || [value respondsToSelector:selector]) {
            return value;
        }
    }
    return nil;
}

#pragma mark -

- (NSString *)stringValueForKey:(id)key
{
    if (key != nil) {
        id value = self[key];
        return  (value == nil || [value isEqual:[NSNull null]]) ? nil : ([value isKindOfClass:[NSString class]] ? value : [value description]);
    }
    
    return nil;
}

- (NSInteger)integerValueForKey:(id)key {
    return [self integerValueForKey:key defaultValue:0];
}
- (NSInteger)integerValueForKey:(id)key defaultValue:(NSInteger)defaultValue
{
    id value = [self valueForKey:key canRespondsToSelector:@selector(integerValue)];
    return value ? [value integerValue] : defaultValue;
}

- (CGFloat)floatValueForKey:(id)key {
    return [self floatValueForKey:key defaultValue:0.f];
}
- (CGFloat)floatValueForKey:(id)key defaultValue:(CGFloat)defaultValue
{
    id value = [self valueForKey:key canRespondsToSelector:@selector(floatValue)];
    return value ? [value floatValue] : defaultValue;
}

- (double)doubleValueForKey:(id)key {
    return [self doubleValueForKey:key defaultValue:0.0];
}
- (double)doubleValueForKey:(id)key defaultValue:(double)defaultValue
{
    id value = [self valueForKey:key canRespondsToSelector:@selector(doubleValue)];
    return value ? [value doubleValue] : defaultValue;
}

- (BOOL)boolValueForKey:(id)key {
    return [self boolValueForKey:key defaultValue:NO];
}
- (BOOL)boolValueForKey:(id)key defaultValue:(BOOL)defaultValue
{
    id value = [self valueForKey:key canRespondsToSelector:@selector(boolValue)];
    return value ? [value boolValue] : defaultValue;
}

- (UIImage *)imageValueForKey:(id)key
{
    NSString * imageName = [self stringValueForKey:key];
    return imageName.length ? [UIImage imageNamed:imageName] : nil;
}

- (UIColor *)colorValueForKey:(id)key {
    return [UIColor colorWithHexStr:[self stringValueForKey:key]];
}

- (NSArray *)arrayValueForKey:(id)key {
    return [self valueForKey:key withClass:[NSArray class]];
}
- (NSDictionary *)dictionaryValueForKey:(id)key {
    return [self valueForKey:key withClass:[NSDictionary class]];
}

#pragma mark -

- (NSString *)myTitle {
    return [self stringValueForKey:@"title"];
}
- (NSString *)myDetailTitle {
    return [self stringValueForKey:@"detailTitle"];
}

- (UIImage *)myImage {
    return [self imageValueForKey:@"image"];
}
- (UIImage *)myHighlightedImage {
    return [self imageValueForKey:@"highlightedImage"];
}
- (UIImage *)mySelectedImage {
    return [self imageValueForKey:@"selectedImage"];
}
- (UIImage *)myDisabledImage {
    return [self imageValueForKey:@"disabledImage"];
}


#pragma mark -

- (NSString *)sizeValue {
    return [self adaptationValueForKey:@"size" withClass:[NSString class]];
}

- (id)widthValue {
    return [self adaptationValueForKey:@"width" canRespondsToSelector:@selector(floatValue)];
}

- (id)heightValue {
    return [self adaptationValueForKey:@"height" canRespondsToSelector:@selector(floatValue)];
}

- (CGSize)size {
    return CGSizeFromString([self sizeValue]);
}

- (CGFloat)width {
    return [[self widthValue] floatValue];
}

- (CGFloat)height {
    return [[self heightValue] floatValue];
}


#pragma mark -

- (CGFloat)fontSize:(CGFloat)defaultValue
{
    id fontSize = [self adaptationValueForKey:@"fontSize" canRespondsToSelector:@selector(floatValue)];
    return fontSize ? [fontSize floatValue] : defaultValue;
}

- (NSString *)fontName {
    return  [self stringValueForKey:@"fontName"];
}

- (UIFont *)textFont
{
    CGFloat fontSize = [self fontSize:17.f];
    NSString * fontName = [self fontName];
    
    if (fontName.length) {
        return [UIFont fontWithName:fontName size:fontSize];
    }else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

- (UIColor *)textColor {
    return [self colorValueForKey:@"textColor"];
}

- (UIColor *)highlightedTextColor; {
    return [self colorValueForKey:@"highlightedTextColor"];
}

- (NSTextAlignment)textAlignment:(NSTextAlignment)defaultValue {
    return [self integerValueForKey:@"textAlignment" defaultValue:defaultValue];
}

#pragma mark -

- (NSString *)targetKey {
    return [self stringValueForKey:@"targetKey"];
}

- (Class)targetViewControllerClass
{
    Class class = NSClassFromString([self targetKey]);
    return [class isSubclassOfClass:[UIViewController class]] ? class : nil;
}

- (UIViewController *)targetViewController {
    return [self targetViewControllerWithContext:nil];
}

- (UIViewController *)targetViewControllerWithContext:(id)context {
    return [[self targetViewControllerClass] viewControllerWithContext:context];
}

#pragma mark -

- (NSArray *)rows {
    return [self valueForKey:@"rows" withClass:[NSArray class]];
}

- (NSString *)headerTitle {
    return [self stringValueForKey:@"headerTitle"];
}
- (NSString *)footerTitle {
    return [self stringValueForKey:@"footerTitle"];
}

- (CGFloat)sectionHeaderHeight:(CGFloat)defaultValue {
    return [self adaptationFloatValueForKey:@"sectionHeaderHeight" defaultValue:defaultValue];
}
- (CGFloat)sectionFooterHeight:(CGFloat)defaultValue {
    return [self adaptationFloatValueForKey:@"sectionFooterHeight" defaultValue:defaultValue];
}


#pragma mark -

- (NSArray *)items {
    return [self valueForKey:@"items" withClass:[NSArray class]];
}

- (CGFloat)minimumLineSpacing:(CGFloat)defaultValue {
    return [self adaptationFloatValueForKey:@"minimumLineSpacing" defaultValue:defaultValue];
}
- (CGFloat)minimumInteritemSpacing:(CGFloat)defaultValue {
    return [self adaptationFloatValueForKey:@"minimumInteritemSpacing" defaultValue:defaultValue];
}

- (UIEdgeInsets)sectionInset:(UIEdgeInsets)defaultValue
{
    NSString * sectionInsetStr = [self adaptationValueForKey:@"sectionInset" withClass:[NSString class]];
    return sectionInsetStr ? UIEdgeInsetsFromString(sectionInsetStr) : defaultValue;
}

#pragma mark -

- (NSDictionary *)objectsForKeys:(NSArray *)keys
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString * key in keys) {
        id value = self[key];
        if (value) {
            dictionary[key] = value;
        }
    }
    
    return dictionary;
}


@end
