//
//  testtt.m

//
//  Created by LeslieChen on 15/2/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "ScreenAdaptation.h"
#import "NSString+Extend.h"
#import "MyPathManager.h"

//----------------------------------------------------------

float systemVersion()
{
    static float version = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[UIDevice currentDevice] systemVersion] versionFloatVaule];
    });
    
    return version;
}

CGSize screenSize()
{
    static CGSize _screenSize;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize _screenSize_ = [UIScreen mainScreen].bounds.size;
        _screenSize.width = MIN(_screenSize_.width, _screenSize_.height);
        _screenSize.height = MAX(_screenSize_.width, _screenSize_.height);
        
    });
    
    return _screenSize;
}

void configurationContentScrollViewForAdaptation(UIScrollView * scrollView)
{
    if (scrollView == nil) {
        return;
    }
    
    //适配iOS11
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        if ([scrollView isKindOfClass:[UITableView class]]) {
            [(UITableView *)scrollView setEstimatedRowHeight:0.f];
            [(UITableView *)scrollView setEstimatedSectionHeaderHeight:0.f];
            [(UITableView *)scrollView setEstimatedSectionFooterHeight:0.f];
        }
    }
}

MyScreenSizeType mainScreenType()
{
    CGSize _screenSize = screenSize();
    if (_screenSize.width <= 320.f) {
        return _screenSize.height < 500.f ? MyScreenSizeTypeiPhone4 : MyScreenSizeTypeSmall;
    }else if (_screenSize.width <= 400.f){
        return _screenSize.height < 700.f ? MyScreenSizeTypeMiddle : MyScreenSizeTypeiPhoneX;
    }else if (_screenSize.height < 800.f){
        return MyScreenSizeTypeBig;
    }else {
        return MyScreenSizeTypeiPhoneXMax;
    }
}

//适配后的文件名称
NSArray * adaptationResourceNames(NSString * resourceName)
{
    if (resourceName.length) {
        
        MyScreenSizeType screenType = mainScreenType();
        
        switch (screenType) {
            case MyScreenSizeTypeiPhone4:
                return @[[resourceName stringByAppendingString:@"@iPhone4"],
                         [resourceName stringByAppendingString:@"@small_small"],
                         [resourceName stringByAppendingString:@"@small"]];
                break;
                
            case MyScreenSizeTypeSmall:
                return @[[resourceName stringByAppendingString:@"@small"]];
                break;
                
            case MyScreenSizeTypeMiddle:
                return @[[resourceName stringByAppendingString:@"@middle"]];
                break;
                
            case MyScreenSizeTypeiPhoneX:
                return @[[resourceName stringByAppendingString:@"@iPhoneX"],
                         [resourceName stringByAppendingString:@"@middle"]];
                break;
                
            case MyScreenSizeTypeBig:
                return @[[resourceName stringByAppendingString:@"@big"]];
                break;
                
            case MyScreenSizeTypeiPhoneXMax:
                return @[[resourceName stringByAppendingString:@"@iPhoneXMax"],
                         [resourceName stringByAppendingString:@"@big"]];
                break;
        }
        
    }
    
    return nil;
}

NSString * validAdaptationNibName(NSString * nibName,NSBundle * bundleOrNil)
{
    NSArray * adaptationNibNames = adaptationResourceNames(nibName);
    for (NSString * adaptationNibName in adaptationNibNames) {
        if (nibFileExist(adaptationNibName, bundleOrNil)) {
            return adaptationNibName;
        }
    }
    
    if(nibFileExist(nibName, bundleOrNil)){
        return nibName;
    }
    
    return nil;
}

//----------------------------------------------------------

@implementation NSDictionary (ScreenAdaptation)

- (id)adaptationValueForKey:(NSString *)key
{
    id value = nil;
    
    if (key.length) {
        
        NSArray * adaptationNames = adaptationResourceNames(key);
        for (NSString * adaptationName in adaptationNames) {
             value = self[adaptationName];
            if (value) break;
        }
        
        value = value ?: self[key];
    }
    
    return value;
}

- (id)adaptationValueForKey:(NSString *)key withClass:(Class)valueClass
{
    id value = [self adaptationValueForKey:key];
    
    if (!valueClass || [value isKindOfClass:valueClass]) {
        return value;
    }
    
    return nil;
}
- (id)adaptationValueForKey:(NSString *)key canRespondsToSelector:(SEL)selector
{
    id value = [self adaptationValueForKey:key];
    if (!selector || [value respondsToSelector:selector]) {
        return value;
    }
    
    return nil;
}

- (NSInteger)adaptationIntegerValueForKey:(NSString *)key {
    return [self adaptationIntegerValueForKey:key defaultValue:0];
}
- (NSInteger)adaptationIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    id value = [self adaptationValueForKey:key canRespondsToSelector:@selector(integerValue)];
    return value ? [value integerValue] : defaultValue;
}

- (CGFloat)adaptationFloatValueForKey:(NSString *)key {
    return [self adaptationFloatValueForKey:key defaultValue:0.f];
}
- (CGFloat)adaptationFloatValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue
{
    id value = [self adaptationValueForKey:key canRespondsToSelector:@selector(floatValue)];
    return value ? [value floatValue] : defaultValue;
}


@end

//----------------------------------------------------------

@implementation UIImage (ScreenAdaptation)

+ (UIImage *)adaptationImageWithName:(NSString *)name
{
    if (name.length == 0) {
        return nil;
    }
    
    NSString * extension = name.pathExtension;
    NSArray * names = adaptationResourceNames(name.stringByDeletingPathExtension);
    for (NSString * imageName in names) {
        UIImage * image = [self imageNamed:extension.length ? [imageName stringByAppendingPathExtension:extension] : imageName];
        if (image != nil) {
            return image;
        }
    }
    
    return [UIImage imageNamed:name];
}

@end



