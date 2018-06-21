//
//  MyImageTitleStaticCollectionViewCell.m
//  
//
//  Created by LeslieChen on 15/4/4.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageTitleStaticCollectionViewCell.h"
#import "UIImage+Tint.h"

//----------------------------------------------------------

typedef NS_ENUM(NSInteger,_Attributed_Index) {
    _Attributed_Index_AttributedTexts,
    _Attributed_Index_TextColors,
    _Attributed_Index_Texts,
    _Attributed_Index_Images,
    _Attributed_Index_Count
};

//----------------------------------------------------------

@interface MyImageTitleStaticCollectionViewCell ()

@property(nonatomic,strong,readonly) NSMutableArray * attributedes;

@end

//----------------------------------------------------------

@implementation MyImageTitleStaticCollectionViewCell
{
    //内容是否有效
    BOOL _contentVaild;
}

@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;

@synthesize attributedes = _attributedes;

#pragma mark -

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self _setup_MyImageTitleStaticCollectionViewCell];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyImageTitleStaticCollectionViewCell];
    }
    
    return self;
}

- (void)_setup_MyImageTitleStaticCollectionViewCell
{
    _autoAdjustTextColor = YES;
    _titleImageMargin = 5.f;
    _adjustImageWithTextColor = YES;
    
    [self _registerKVO];
}

- (void)dealloc {
    [self _unregisterKVO];
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[//@"autoAdjustImage",
             @"adjustImageWithTextColor",
             @"autoAdjustTextColor",
             @"textFont",
             @"layout",
             @"contentLayout",
             @"contentAlign",
             @"titleImageMargin",
             @"contentInset",
             @"titleImageMargin",
             @"contentLayoutBlock"];
}

- (void)_registerKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)_unregisterKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self == object && ![change[@"old"] isEqual:change[@"new"]]) {
        
        if ([NSThread isMainThread]) {
            [self _updateUIForKeypath:keyPath];
        }else{
            [self performSelectorOnMainThread:@selector(_updateUIForKeypath:)
                                   withObject:keyPath
                                waitUntilDone:NO];
        }
    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"autoAdjustTextColor"] ||
        [keyPath isEqualToString:@"adjustImageWithTextColor"] ||
        [keyPath isEqualToString:@"textFont"]) {
        _contentVaild = NO;
    }else if ([keyPath isEqualToString:@"contentLayout"] ||
              [keyPath isEqualToString:@"contentAlign"]) {
        
        //存在自定义布局忽略
        if (self.contentLayoutBlock) {
            return;
        }
    }
    
    [self setNeedsLayout];
}

#pragma mark -

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    
    return _imageView ;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [self addSubview:_textLabel];
    }
    
    return _textLabel;
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    if (!_contentVaild) {
        _contentVaild = YES;

        MyImageTitleStaticCollectionViewCellState state = self.state;
        
        //设置字体和颜色
        self.textLabel.font = self.textFont;
        self.textLabel.textColor = [self showingTextColorForState:state];
        
        //设置文本
        NSAttributedString * attributedText = [self showingAttributedTextForState:state];
        if (attributedText) {
            self.textLabel.text = nil;
            self.textLabel.attributedText = attributedText;
        }else{
            self.textLabel.attributedText = nil;
            self.textLabel.text = [self showingTextForState:state];
        }
        
        self.imageView.image = [self showingImageForState:state];
    }

    CGRect containerRect =  UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    CGRect contentRect   =  CGRectMake(0.f, 0.f, CGRectGetWidth(containerRect), CGRectGetHeight(containerRect));
    CGRect titleRect     =  CGRectZero;
    CGRect imageRect     =  CGRectZero;
    
    if(CGRectGetWidth(contentRect) > 0 && CGRectGetHeight(contentRect) > 0){
        
        //计算大小
        CGSize titleDrawSize = [self.textLabel intrinsicContentSize];
        CGSize imageDrawSize = self.imageView.image.size;

        //水平布局
        if (self.layout == MyImageTitleStaticCollectionViewCellLayoutImageLeft ||
            self.layout == MyImageTitleStaticCollectionViewCellLayoutImageRight) {
            
            //计算内容大小
            BOOL hasMargin = (titleDrawSize.width && imageDrawSize.width);
            
            CGSize imageMaxSize = CGSizeZero;
            imageMaxSize.width = CGRectGetWidth(contentRect) - (hasMargin? self.titleImageMargin : 0.f);
            imageMaxSize.width = MAX(0.f, imageMaxSize.width);
            imageMaxSize.height = CGRectGetHeight(contentRect);
            
            //缩小图片到合适大小
            CGSize targetSize = sizeZoomToTagetSize(imageDrawSize, imageMaxSize, MyZoomModeAspectFit);
            if (targetSize.width < imageDrawSize.width) {
                imageDrawSize = targetSize;
            }
            
            //显示不下则缩小
            if (imageMaxSize.width < imageDrawSize.width + titleDrawSize.width){
                titleDrawSize.width = imageMaxSize.width - imageDrawSize.width;
            }
            
            contentRect.size.width = titleDrawSize.width + imageDrawSize.width + (hasMargin ? self.titleImageMargin : 0.f);
            contentRect.size.height = MAX(titleDrawSize.height, imageDrawSize.height);
            
        }else{ //竖直布局
            
            //计算内容大小
            BOOL hasMargin = (titleDrawSize.height && imageDrawSize.height);
            
            CGSize imageMaxSize = CGSizeZero;
            imageMaxSize.height = CGRectGetHeight(contentRect) - (hasMargin? self.titleImageMargin : 0.f);
            imageMaxSize.height = MAX(0.f, imageMaxSize.height);
            imageMaxSize.width = CGRectGetWidth(contentRect);
            
            //缩小图片到合适大小
            CGSize targetSize = sizeZoomToTagetSize(imageDrawSize, imageMaxSize, MyZoomModeAspectFit);
            if (targetSize.height < imageDrawSize.height) {
                imageDrawSize = targetSize;
            }
            
            if (imageMaxSize.height < imageDrawSize.height + titleDrawSize.height){
                titleDrawSize.height = imageMaxSize.height - imageDrawSize.height;
            }
            
            contentRect.size.height = titleDrawSize.height + imageDrawSize.height + (hasMargin ? self.titleImageMargin : 0.f);
            contentRect.size.width = MAX(titleDrawSize.width, imageDrawSize.width);
        }
        
        
        if (self.contentLayoutBlock) { //自定义布局
            
            self.contentLayoutBlock(containerRect,
                                    contentRect.size,
                                    imageDrawSize,
                                    titleDrawSize,
                                    &contentRect,
                                    &imageRect,
                                    &titleRect);
        }else {
            
            //计算布局方式
            MyContentLayout imageLayout,titleLayout;
            
            if (self.layout == MyImageTitleStaticCollectionViewCellLayoutImageLeft ||
                self.layout == MyImageTitleStaticCollectionViewCellLayoutImageRight) {
                
                if (self.contentAlign == MyImageTitleStaticCollectionViewCellContentAlignTop) {
                    imageLayout = MyContentLayoutTop;
                }else if (self.contentAlign == MyImageTitleStaticCollectionViewCellContentAlignBottom){
                    imageLayout = MyContentLayoutBottom;
                }else{
                    imageLayout = MyContentLayoutCenter;
                }
                
                titleLayout = imageLayout;
                
                if (self.layout == MyImageTitleStaticCollectionViewCellLayoutImageLeft) { //图左文右
                    imageLayout |= MyContentLayoutLeft;
                    titleLayout |= MyContentLayoutRight;
                }else{ //文左图右
                    imageLayout |= MyContentLayoutRight;
                    titleLayout |= MyContentLayoutLeft;
                }

                
            }else {
                
                if (self.contentAlign == MyImageTitleStaticCollectionViewCellContentAlignLeft) {
                    imageLayout = MyContentLayoutLeft;
                }else if (self.contentAlign == MyImageTitleStaticCollectionViewCellContentAlignRight){
                    imageLayout = MyContentLayoutRight;
                }else{
                    imageLayout = MyContentLayoutCenter;
                }
                
                titleLayout = imageLayout;
                
                if (self.layout == MyImageTitleStaticCollectionViewCellLayoutImageTop) { //图上文下
                    imageLayout |= MyContentLayoutTop;
                    titleLayout |= MyContentLayoutBottom;
                }else{ //文上图下
                    imageLayout |= MyContentLayoutBottom;
                    titleLayout |= MyContentLayoutLeft;
                }
            }
            
            //计算内容视图的rect
            contentRect = contentRectForLayout(containerRect, contentRect.size, self.contentLayout);
            contentRect = CGRectOffset(contentRect, self.contentOffset.x, self.contentOffset.y);
            
            //计算文字和图片位置
            titleRect = contentRectForLayout(contentRect, titleDrawSize, titleLayout);
            imageRect = contentRectForLayout(contentRect, imageDrawSize, imageLayout);
        }
    }
    
    self.imageView.frame = imageRect;
    self.textLabel.frame = titleRect;
}

- (CGPoint)_offsetForRect:(CGRect)rect
                     size:(CGSize)size
                   layout:(MyContentLayout)layout
{
    CGPoint offset = CGPointZero;
    
    //水平
    if (layout & MyContentLayoutLeft) {
        offset.x = CGRectGetMinX(rect);
    }else if(layout & MyContentLayoutRight){
        offset.x = CGRectGetMaxX(rect) - size.width;
    }else{
        offset.x = CGRectGetMinX(rect) + (CGRectGetWidth(rect) - size.width) * 0.5f;
    }
    
    //竖直
    if (layout & MyContentLayoutTop) {
        offset.y = CGRectGetMinY(rect);
    }else if(layout & MyContentLayoutBottom){
        offset.y = CGRectGetMaxY(rect) - size.height;
    }else{
        offset.y = CGRectGetMinY(rect) + (CGRectGetHeight(rect) - size.height) * 0.5f;
    }
    
    return offset;
}

- (CGRect)_alignRectForRect:(CGRect)rect
                       size:(CGSize)size
                     layout:(MyContentLayout)layout
{
    CGPoint offset = [self _offsetForRect:rect
                                     size:size
                                   layout:layout];
    
    return CGRectMake(offset.x, offset.y, size.width, size.height);
}


#pragma mark -

- (NSMutableArray *)attributedes
{
    if (!_attributedes) {
        _attributedes = [NSMutableArray arrayWithCapacity:_Attributed_Index_Count];
        for (NSUInteger i = 0; i < _Attributed_Index_Count ; ++ i) {
            [_attributedes addObject:[NSMutableDictionary dictionaryWithCapacity:4]];
        }
    }
    
    return _attributedes;
}

- (void)_setAttributed:(id)attributed
              forState:(MyImageTitleStaticCollectionViewCellState)state
               atIndex:(NSUInteger)index
{
    BOOL neeTryLayout = YES;
    
    if (attributed) {
        [self.attributedes[index] setObject:attributed forKey:@(state)];
    }else if([self _attributedForState:state atIndex:index]){
        [self.attributedes[index] removeObjectForKey:@(state)];
    }else{
        neeTryLayout = NO;
    }
    
    if (neeTryLayout) {
        [self _layoutViewIfNeedWhenPropertyChangeForState:state];
    }
}

- (id)_attributedForState:(MyImageTitleStaticCollectionViewCellState)state atIndex:(NSUInteger)index {
    return [self.attributedes[index] objectForKey:@(state)];
}

- (void)_layoutViewIfNeedWhenPropertyChangeForState:(MyImageTitleStaticCollectionViewCellState)state
{
    if (self.state == state || state == MyImageTitleStaticCollectionViewCellStateNormal) {
        _contentVaild = NO;
        [self setNeedsLayout];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
                  forState:(MyImageTitleStaticCollectionViewCellState)state
{
    [self _setAttributed:attributedText forState:state atIndex:_Attributed_Index_AttributedTexts];
}


- (NSAttributedString *)attributedTextForState:(MyImageTitleStaticCollectionViewCellState)state {
    return [self _attributedForState:state atIndex:_Attributed_Index_AttributedTexts];
}

- (NSAttributedString *)showingAttributedTextForState:(MyImageTitleStaticCollectionViewCellState)state
{
    NSAttributedString * attributedTexts = [self attributedTextForState:state];
    if (!attributedTexts && state != MyImageTitleStaticCollectionViewCellStateNormal) {
        attributedTexts = [self attributedTextForState:MyImageTitleStaticCollectionViewCellStateNormal];
    }
 
    return attributedTexts;
}

- (void)setTextColor:(UIColor *)textColor forState:(MyImageTitleStaticCollectionViewCellState)state {
    [self _setAttributed:textColor forState:state atIndex:_Attributed_Index_TextColors];
}

- (UIColor *)textColorForState:(MyImageTitleStaticCollectionViewCellState)state {
    return [self _attributedForState:state atIndex:_Attributed_Index_TextColors];
}

- (UIColor *)showingTextColorForState:(MyImageTitleStaticCollectionViewCellState)state
{
    UIColor * textColor = [self textColorForState:state];
    
    if (!textColor && state !=  MyImageTitleStaticCollectionViewCellStateNormal) {
        if (self.autoAdjustTextColor && (state & MyImageTitleStaticCollectionViewCellStateHighlighted)) {
            textColor = [[self showingTextColorForState:MyImageTitleStaticCollectionViewCellStateSelected] colorWithAlphaComponent:0.5f];
        }else{
            textColor = [self textColorForState:MyImageTitleStaticCollectionViewCellStateNormal];
        }
    }
    
    return textColor ?: [UIColor blackColor];
}

- (void)setText:(NSString *)text forState:(MyImageTitleStaticCollectionViewCellState)state {
    [self _setAttributed:text forState:state atIndex:_Attributed_Index_Texts];
}

- (NSString *)textForState:(MyImageTitleStaticCollectionViewCellState)state {
    return [self _attributedForState:state atIndex:_Attributed_Index_Texts];
}

- (NSString *)showingTextForState:(MyImageTitleStaticCollectionViewCellState)state
{
    NSString * text = [self textForState:state];
    if (!text && state != MyImageTitleStaticCollectionViewCellStateNormal) {
        return [self textForState:MyImageTitleStaticCollectionViewCellStateNormal];
    }
    
    return text;
}

- (UIFont *)textFont {
    return _textFont ?: [UIFont systemFontOfSize:17.f];
}

- (void)setImage:(UIImage *)image forState:(MyImageTitleStaticCollectionViewCellState)state {
    [self _setAttributed:image forState:state atIndex:_Attributed_Index_Images];
}

- (UIImage *)imageForState:(MyImageTitleStaticCollectionViewCellState)state {
    return [self _attributedForState:state atIndex:_Attributed_Index_Images];
}

- (UIImage *)showingImageForState:(MyImageTitleStaticCollectionViewCellState)state
{
    UIImage * image = [self imageForState:state];
    if (!image && state != MyImageTitleStaticCollectionViewCellStateNormal) {
        image = [self imageForState:MyImageTitleStaticCollectionViewCellStateNormal];
    }
    
    return (image && self.adjustImageWithTextColor) ? [image imageWithTintColor:[self showingTextColorForState:state]] : image;
}


#pragma mark -

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.isHighlighted != highlighted) {
        
        MyImageTitleStaticCollectionViewCellState fromState = self.state;
        [super setHighlighted:highlighted animated:animated];
        [self cellStateDidChangeFromState:fromState];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.isSelected != selected) {
        
        MyImageTitleStaticCollectionViewCellState fromState = self.state;
        [super setSelected:selected animated:animated];
        [self cellStateDidChangeFromState:fromState];
    }
}

- (MyImageTitleStaticCollectionViewCellState)state
{
    MyImageTitleStaticCollectionViewCellState state = MyImageTitleStaticCollectionViewCellStateNormal;
    
    if (self.isHighlighted) {
        state |= MyImageTitleStaticCollectionViewCellStateHighlighted;
    }
    
    if (self.isSelected) {
        state |= MyImageTitleStaticCollectionViewCellStateSelected;
    }
    
    return state;
}

- (void)cellStateDidChangeFromState:(MyImageTitleStaticCollectionViewCellState)fromState
{
    _contentVaild = NO;
    [self setNeedsLayout];
}
@end
