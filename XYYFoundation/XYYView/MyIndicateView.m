//
//  MyLoadingIndicateView.m
//  5idj_ios
//
//  Created by LeslieChen on 14-7-27.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyIndicateView.h"
//#import "MacroDef.h"
//#import "help.h"
#import "UILabel+CaculaterShowSize.h"

//----------------------------------------------------------

@interface MyIndicateView ()

@property(nonatomic,strong,readonly) UIImageView  *imageView;

@end

//----------------------------------------------------------

@implementation MyIndicateView
{
    UIView * _contentView;
    UIView * _indicateView;
    
    UILabel * _titleLabel;
    UILabel * _detailLabel;
    
    BOOL      _ignoreFrameChange;
    
}

@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize imageView             = _imageView;


#pragma mark - life circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init_MyIndicateView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init_MyIndicateView];
    }
    
    return self;
}

- (void)_init_MyIndicateView
{
    self.backgroundColor  = [UIColor clearColor];
    _style            = MyIndicateViewStyleActivityView;
    _topMargin        = 10.f;
    _bottomMargin     = 5.f;
    _titleLabelFont   = [UIFont boldSystemFontOfSize:17.f];
    _titleLabelColor  = [UIColor grayColor];
    _detailLabelFont  = [UIFont systemFontOfSize:13.f];
    _detailLabelColor = [UIColor lightGrayColor];
    
    //内容视图
    _contentView = [[UIView alloc] init];
//    _contentView.backgroundColor = [UIColor redColor];
    [self addSubview:_contentView];
    
    //标题视图
    [self _setupLabels];
    
    //标记视图
    [self _updateIndicateView];
    
    //注册KVO
    [self _registerForKVO];
    
}

- (void)dealloc {
    [self _unregisterFromKVO];
}

- (void)_setupLabels
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.adjustsFontSizeToFitWidth = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = self.titleLabelFont;
    _titleLabel.textColor = self.titleLabelColor;
    _titleLabel.numberOfLines = 0;
    [_contentView addSubview:_titleLabel];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.adjustsFontSizeToFitWidth = NO;
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.font = self.detailLabelFont;
    _detailLabel.textColor = self.detailLabelColor;
    _detailLabel.numberOfLines = 0;
    [_contentView addSubview:_detailLabel];
}

#pragma mark - KVO

- (void)_registerForKVO
{
    for (NSString *keyPath in [self _observableKeypaths]) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:NULL];
    }
}

- (void)_unregisterFromKVO
{
    for (NSString *keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
    
    [_activityIndicatorView removeObserver:self forKeyPath:@"frame"];
}

- (NSArray *)_observableKeypaths
{
    return @[@"style",
             @"contentOffset",
             @"contentLayout",
             @"marginScale",
             @"marginValue",
             @"topMargin",
             @"bottomMargin",
             @"customView",
             @"titleLabelText",
             @"titleLabelFont",
             @"titleLabelColor",
             @"detailLabelText",
             @"detailLabelFont",
             @"detailLabelColor",
             @"progress",
             @"image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self || object == _activityIndicatorView) && ![change[@"old"] isEqual:change[@"new"]]) {
        
        //
        if (![NSThread isMainThread]) {
            [self performSelectorOnMainThread:@selector(_updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
        } else {
            [self _updateUIForKeypath:keyPath];
        }

    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"style"]) {
        [self _updateIndicateView];
    }else if ([keyPath isEqualToString:@"titleLabelText"]) {
        _titleLabel.text = self.titleLabelText;
    }else if ([keyPath isEqualToString:@"detailLabelText"]) {
        _detailLabel.text = self.detailLabelText;
    }else if ([keyPath isEqualToString:@"progress"]) {
        if ([_indicateView respondsToSelector:@selector(setProgress:)]) {
            [(id)_indicateView setProgress:self.progress];
        }
        return;
    }else if ([keyPath isEqualToString:@"image"]){
        
        if (_imageView) {
            _imageView.image = self.image;
            if (self.style != MyIndicateViewStyleImageView) {
                return;
            }
            
        }else{
            return;
        }
    }else if ([keyPath isEqualToString:@"customView"]){
        
        if (self.style == MyIndicateViewStyleCustomView) {
            [self _updateIndicateView];
        }else{
            return;
        }
    }else if ([keyPath isEqualToString:@"frame"]) {
        if (self.style != MyIndicateViewStyleActivityView || _ignoreFrameChange) {
            return;
        }
    }else if ([keyPath isEqualToString:@"titleLabelFont"]) {
        _titleLabel.font = self.titleLabelFont;
    }else if ([keyPath isEqualToString:@"titleLabelColor"]) {
        _titleLabel.textColor = self.titleLabelColor;
        return;
    }else if ([keyPath isEqualToString:@"detailLabelFont"]) {
        _detailLabel.font = self.detailLabelFont;
    }else if ([keyPath isEqualToString:@"detailLabelColor"]) {
        _detailLabel.textColor = self.detailLabelColor;
        return;
    }
    
    [self setNeedsLayout];
}


#pragma mark -

- (void)_updateIndicateView
{
    [_indicateView removeFromSuperview];
    
    switch (_style) {
        case MyIndicateViewStyleActivityView:
            _indicateView = self.activityIndicatorView;
            break;
            
        case MyIndicateViewStyleCustomView:
            _indicateView = self.customView;
            break;
            
        case MyIndicateViewStyleImageView:            
            _indicateView = self.imageView;
            break;
            
        default:
            _indicateView = nil;
            break;
    }
    
//    _indicateView.translatesAutoresizingMaskIntoConstraints = NO;
    _indicateView.autoresizingMask = UIViewAutoresizingNone;
    [_contentView addSubview:_indicateView];
}

- (MyActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        
        _activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
        _activityIndicatorView.lineWidth = 1.5f;
        [_activityIndicatorView startAnimating];
        
        [_activityIndicatorView addObserver:self
                                 forKeyPath:@"frame"
                                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                    context:nil];
    }
    
    return _activityIndicatorView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.image];
    }
    
    return _imageView;
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _ignoreFrameChange = YES;
    
    CGRect bounds = self.bounds;
    
    //inset
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetHeight(bounds)  * self.marginScale.top + self.marginValue.top,
                                           CGRectGetWidth(bounds)   * self.marginScale.left + self.marginValue.left,
                                           CGRectGetHeight(bounds)  * self.marginScale.bottom + self.marginValue.bottom,
                                           CGRectGetWidth(bounds)   * self.marginScale.right + self.marginValue.right);
    
    //内容矩形
    CGRect contentRect = UIEdgeInsetsInsetRect(bounds, insets);
    
    //内容矩形大小太小
    if (CGRectGetWidth(contentRect) <= 0 || CGRectGetHeight(contentRect) <= 0) {
        _contentView.frame = CGRectZero;
    }else {
        
        //值规范化
        contentRect.origin.x    = floor(contentRect.origin.x);
        contentRect.origin.y    = floor(contentRect.origin.y);
        contentRect.size.width  = ceil(contentRect.size.width);
        contentRect.size.height = ceil(contentRect.size.height);
        
        //内容大小
        CGSize contentSize = CGSizeMake(CGRectGetWidth(contentRect), 0.f);
        
        //_indicateView
        if (_indicateView) {
            
            CGSize indicateViewSize = CGSizeZero;
            
            if (_style == MyIndicateViewStyleImageView) {
                indicateViewSize = self.image.size;
                
                if (indicateViewSize.width) {
                    
                    indicateViewSize.width  = MIN(indicateViewSize.width, contentSize.width);
                    indicateViewSize.height *= (indicateViewSize.width / self.image.size.width);
                    indicateViewSize.height = roundf(indicateViewSize.height);
                }
                
            }else{
                indicateViewSize = _indicateView.frame.size;
            }
            
            _indicateView.frame = CGRectMake((contentSize.width - indicateViewSize.width) * 0.5f, 0.f, indicateViewSize.width, indicateViewSize.height);
            
            contentSize.height += indicateViewSize.height;
        }
        
        
        CGSize titleLabelSize = [UILabel showSizeWithText:self.titleLabelText font:self.titleLabelFont width:contentSize.width];
        CGSize detailLabelSize = [UILabel showSizeWithText:self.detailLabelText font:self.detailLabelFont width:contentSize.width];
        
        //文字和指示视图高不为0有间隙
        if ((titleLabelSize.height || detailLabelSize.height) && contentSize.height) {
            contentSize.height += self.topMargin;
        }
        
        _titleLabel.frame = CGRectMake((contentSize.width - titleLabelSize.width) * 0.5f, contentSize.height, titleLabelSize.width, titleLabelSize.height);
        contentSize.height += titleLabelSize.height;
        
        //加上间隙
        if (titleLabelSize.height && detailLabelSize.height) {
            contentSize.height += self.bottomMargin;
        }
        
        _detailLabel.frame = CGRectMake((contentSize.width - detailLabelSize.width) * 0.5f, contentSize.height, detailLabelSize.width, detailLabelSize.height);
        contentSize.height += detailLabelSize.height;
        
        
        if (_style == MyIndicateViewStyleImageView && _indicateView && contentSize.height > CGRectGetHeight(contentRect)) {
            
            CGFloat indicateViewHightInset = contentSize.height - CGRectGetHeight(contentRect);
            CGFloat indicateViewHight = CGRectGetHeight(_indicateView.frame);
            indicateViewHightInset = MIN(indicateViewHightInset, indicateViewHight);
            
            if (indicateViewHightInset > 0) {
                
                CGFloat indicateViewWidth = CGRectGetWidth(_indicateView.frame);
                
                indicateViewWidth *= ((indicateViewHight - indicateViewHightInset) / indicateViewHight);
                indicateViewWidth = roundf(indicateViewWidth);
                indicateViewHight  = indicateViewHight - indicateViewHightInset;
                
                _indicateView.frame = CGRectMake((contentSize.width - indicateViewWidth) * 0.5f, 0.f, indicateViewWidth,indicateViewHight);
                
                _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0.f, - indicateViewHightInset);
                _detailLabel.frame = CGRectOffset(_detailLabel.frame, 0.f, - indicateViewHightInset);
                
                contentSize.height -= indicateViewHightInset;
            }
        }
        
        //偏移
        contentRect = CGRectOffset(contentRect, self.contentOffset.x, self.contentOffset.y);
        
        //布局
        _contentView.frame = contentRectForLayout(contentRect, contentSize, self.contentLayout);
    }
    
    _ignoreFrameChange = NO;
}

@end
