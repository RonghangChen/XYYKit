//
//  NSDictionary+MyCategory.h

//
//  Created by LeslieChen on 15/1/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDictionary (MyCategory)

- (id)valueForKey:(id)key withClass:(Class)valueClass;
- (id)valueForKey:(id)key canRespondsToSelector:(SEL)selector;

- (NSString *)stringValueForKey:(id)key;

- (NSInteger)integerValueForKey:(id)key;
- (NSInteger)integerValueForKey:(id)key defaultValue:(NSInteger)defaultValue;
- (CGFloat)floatValueForKey:(id)key;
- (CGFloat)floatValueForKey:(id)key defaultValue:(CGFloat)defaultValue;
- (double)doubleValueForKey:(id)key;
- (double)doubleValueForKey:(id)key defaultValue:(double)defaultValue;
- (BOOL)boolValueForKey:(id)key;
- (BOOL)boolValueForKey:(id)key defaultValue:(BOOL)defaultValue;;

- (UIImage *)imageValueForKey:(id)key;
- (UIColor *)colorValueForKey:(id)key;

- (NSArray *)arrayValueForKey:(id)key;
- (NSDictionary *)dictionaryValueForKey:(id)key;

//文本图片内容相关
- (NSString *)myTitle;
- (NSString *)myDetailTitle;
- (UIImage *)myImage;
- (UIImage *)myHighlightedImage;
- (UIImage *)mySelectedImage;
- (UIImage *)myDisabledImage;

//尺寸相关（进行了适配）
- (NSString *)sizeValue;
- (id)heightValue;
- (id)widthValue;
- (CGSize)size;
- (CGFloat)height;
- (CGFloat)width;

//字体内容相关
- (CGFloat)fontSize:(CGFloat)defaultValue;
- (NSString *)fontName;
- (UIFont *)textFont;

- (UIColor *)textColor;
- (UIColor *)highlightedTextColor;
- (NSTextAlignment)textAlignment:(NSTextAlignment)defaultValue;


//target
- (NSString *)targetKey;
- (Class)targetViewControllerClass;
- (UIViewController *)targetViewController;
- (UIViewController *)targetViewControllerWithContext:(id)context;

//tableView
- (NSArray *)rows;
- (NSString *)headerTitle;
- (NSString *)footerTitle;
- (CGFloat)sectionHeaderHeight:(CGFloat)defaultValue;
- (CGFloat)sectionFooterHeight:(CGFloat)defaultValue;

//flowlayput
- (NSArray *)items;
- (CGFloat)minimumLineSpacing:(CGFloat)defaultValue;
- (CGFloat)minimumInteritemSpacing:(CGFloat)defaultValue;;
- (UIEdgeInsets)sectionInset:(UIEdgeInsets)defaultValue;;


//返回keys对应的键值对，不存在则忽略
- (NSDictionary *)objectsForKeys:(NSArray *)keys;


@end
