//
//  MyTextView.m
//  
//
//  Created by LeslieChen on 15/4/15.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyTextView.h"

//----------------------------------------------------------

@interface MyTextView ()

@property(nonatomic,strong,readonly) UILabel * placeholderTextLabel;

@end

//----------------------------------------------------------

@implementation MyTextView

@synthesize placeholderTextLabel = _placeholderTextLabel;

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        if (![super respondsToSelector:@selector(initWithFrame:textContainer:)]) {
            [self _setup_MyTextView];
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    
    if (self) {
        [self _setup_MyTextView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyTextView];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setup_MyTextView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textViewTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

- (void)_textViewTextDidChangeNotification:(NSNotification *)notification {
    [self _updatePlaceholderTextVisbleStatus];
}

#pragma mark -

- (void)setText:(NSString *)text
{
    if (self.text != text) {
        [super setText:text];
        [self _updatePlaceholderTextVisbleStatus];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (self.attributedText != attributedText) {
        [super setAttributedText:attributedText];
        [self _updatePlaceholderTextVisbleStatus];
    }
}

#pragma mark -

- (UILabel *)placeholderTextLabel
{
    if (!_placeholderTextLabel) {
        _placeholderTextLabel = [[UILabel alloc] init];
        _placeholderTextLabel.hidden = [self hasText];
        _placeholderTextLabel.numberOfLines = 0;
        [self insertSubview:_placeholderTextLabel atIndex:0];
    }
    
    return _placeholderTextLabel;
}

- (void)_updatePlaceholderTextVisbleStatus
{
    self.placeholderTextLabel.hidden = [self hasText];
    [self setNeedsLayout];
}

#pragma mark -

- (void)setPlaceholderText:(NSString *)placeholderText
{
    if (_placeholderText != placeholderText) {
        _placeholderText = placeholderText;
        [self _updatePlaceHoderTextLabelText];
    }
}

- (void)setPlaceholderAttributed:(NSDictionary *)placeholderAttributed
{
    if (_placeholderAttributed != placeholderAttributed) {
        _placeholderAttributed = placeholderAttributed;
        [self _updatePlaceHoderTextLabelText];
    }
}

- (void)setTypingAttributes:(NSDictionary *)typingAttributes
{
    [super setTypingAttributes:typingAttributes];
    [self _updatePlaceHoderTextLabelText];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self _updatePlaceHoderTextLabelText];
}

- (void)_updatePlaceHoderTextLabelText
{
    self.placeholderTextLabel.text = self.placeholderText;
    self.placeholderTextLabel.font = self.placeholderAttributed[NSFontAttributeName] ?: (self.typingAttributes[NSFontAttributeName] ?: self.font);
    self.placeholderTextLabel.textColor = self.placeholderAttributed[NSForegroundColorAttributeName] ?: [UIColor lightGrayColor];
    
    [self setNeedsLayout];
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _updatePlaceHoderTextPosition];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    if ([super respondsToSelector:@selector(setTextContainerInset:)]) {
        [super setTextContainerInset:textContainerInset];
        [self setNeedsLayout];
    }
}

- (void)_updatePlaceHoderTextPosition
{
    if (!self.placeholderTextLabel.isHidden) {
        
        CGRect caretRect = [self caretRectForPosition:[self beginningOfDocument]];

        self.placeholderTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds) - 2 * CGRectGetMaxX(caretRect);
        
        //计算一行的文本高度
        self.placeholderTextLabel.text = @"我";
        CGFloat oneLineTextHeight = [self.placeholderTextLabel intrinsicContentSize].height;
        
        //计算文本显示大小
        self.placeholderTextLabel.text = self.placeholderText;
        CGSize intrinsicContentSize = [self.placeholderTextLabel intrinsicContentSize];
        
        //设置占位文本的位置
        self.placeholderTextLabel.frame = CGRectMake(CGRectGetMaxX(caretRect), CGRectGetMinY(caretRect) + (CGRectGetHeight(caretRect) - oneLineTextHeight) * 0.5f, intrinsicContentSize.width, intrinsicContentSize.height);
    }
}

#pragma mark -

- (CGSize)sizeForFullShowWithWidth:(CGFloat)width {
    return [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
}


@end
