//
//  MyBlurredView.m
//  
//
//  Created by LeslieChen on 15/3/12.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBlurredView.h"
#import "UIImage+ImageEffects.h"
#import "XYYSizeUtil.h"
#import "ScreenAdaptation.h"
#import "UIView+Screenshot.h"

//----------------------------------------------------------

@interface MyBlurredView ()

@property(nonatomic,strong) UIView  * blurredEffectView;
@property(nonatomic,strong) UIColor * tmpBgColor;

//是否显示了毛玻璃视图
@property(nonatomic,readonly) BOOL hadShowBlurredView;

@end

//----------------------------------------------------------

@implementation MyBlurredView

@synthesize blurredBackgroundType = _blurredBackgroundType;
@synthesize applyBlurredEffectBlock = _applyBlurredEffectBlock;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@synthesize blurEffectStyle = _blurEffectStyle;
@synthesize blurEffectAlpha = _blurEffectAlpha;
#endif

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_MyBlurredView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyBlurredView];
    }
    
    return self;
}

- (void)_setup_MyBlurredView
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    self.blurEffectAlpha = 1.f;
#endif
    
}
#pragma mark -

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.hadShowBlurredView) { //正在显示毛玻璃效果则记录背景颜色
        self.tmpBgColor = backgroundColor;
    }else {
        super.backgroundColor = backgroundColor;
    }
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _updateBlurredEffectViewFrame];
}

- (void)_updateBlurredEffectViewFrame
{
    if (_blurredEffectView) {
        _blurredEffectView.frame = self.bounds;
        
        //如果是静态毛玻璃效果，设置其内容范围
        if ([_blurredEffectView isMemberOfClass:[UIView class]] && self.window) {
            CGRect rect = [self convertRect:self.bounds toView:self.window];
            _blurredEffectView.layer.contentsRect = ContentsRectForRect(rect,self.window.bounds);
        }
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        [self _updateBlurredEffectViewFrame];
    }
}

#pragma mark -

- (BOOL)hadShowBlurredView {
    return _blurredEffectView != nil;
}

- (void)updateBlurred {
    [self updateBlurredWithWindow:nil];
}

- (void)updateBlurredWithWindow:(UIWindow *)window
{
    //清除毛玻璃效果
    [self clearBlurred];
    
    window = window ?: self.window;
    
    //获取应该显示的毛玻璃类型
    MyBlurredBackgroundType currentBlurredBackgroundType = MyBlurredBackgroundTypeNone;
    if (self.blurredBackgroundType == MyBlurredBackgroundTypeStatic) {
        if (window) {
            currentBlurredBackgroundType = MyBlurredBackgroundTypeStatic;
        }else{
            NSLog(@"%@当前没有参照window或添加到window中无法添加静态毛玻璃效果,已取消显示",NSStringFromClass([self class]));
        }
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    
    else if (self.blurredBackgroundType == MyBlurredBackgroundTypeDynamic) {
        
        if (GreaterThanIOS8System) {
            currentBlurredBackgroundType = MyBlurredBackgroundTypeDynamic;
        }else{
            NSLog(@"IOS8以下系统不支持动态毛玻璃效果，已转化为静态效果显示");
            if (window) {
                currentBlurredBackgroundType = MyBlurredBackgroundTypeStatic;
            }else{
                NSLog(@"%@当前没有参照window或添加到window中无法添加静态毛玻璃效果,已取消显示",NSStringFromClass([self class]));
            }
        }
    }
    
#endif
    
    //设置毛玻璃效果
    if (currentBlurredBackgroundType == MyBlurredBackgroundTypeStatic) {
      
        //截屏
        UIImage * blurredImage = [window convertViewToImageWithRetina:NO];
        if (self.applyBlurredEffectBlock) {
            blurredImage = self.applyBlurredEffectBlock(blurredImage);
        }else{
            blurredImage = [blurredImage applyDarkEffect];
        }
        
        //添加到视图
        _blurredEffectView = [[UIView alloc] initWithFrame:self.bounds];
        _blurredEffectView.clipsToBounds = YES;
        _blurredEffectView.layer.contents = (id)blurredImage.CGImage;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    
    else if (currentBlurredBackgroundType == MyBlurredBackgroundTypeDynamic){
        
        UIVisualEffectView * blurredEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(self.blurEffectStyle)]];
        _blurredEffectView = blurredEffectView;
        _blurredEffectView.alpha = self.blurEffectAlpha;
    }
    
#endif
    
    if (_blurredEffectView) {
        
        //记录背景并清空背景
        self.tmpBgColor = self.backgroundColor;
        super.backgroundColor = [UIColor clearColor];
        
        //毛玻璃效果加入
        [self insertSubview:_blurredEffectView atIndex:0];
        [self setNeedsLayout];
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

- (UIView *)blurredContentView
{
    if ([_blurredEffectView isKindOfClass:[UIVisualEffectView class]]) {
        return [(UIVisualEffectView *)_blurredEffectView contentView];
    }
    
    return nil;
}

#endif

- (void)clearBlurred
{
    if (self.hadShowBlurredView) {
        
        //移除毛玻璃视图
        [_blurredEffectView removeFromSuperview];
        _blurredEffectView = nil;
        
        //回复原来背景颜色
        super.backgroundColor = self.tmpBgColor;
    }
}

@end
