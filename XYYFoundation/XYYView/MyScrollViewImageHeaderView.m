//
//  MyTableviewImageHeaderView.m
//  
//
//  Created by LeslieChen on 15/11/25.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "MyScrollViewImageHeaderView.h"
#import "UIView+Frame.h"

@implementation MyScrollViewImageHeaderView
{
    CGPoint _contentOffset;
    CGRect _maskLayerBounds;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame completedShowHeight:0.f];
}

- (id)initWithFrame:(CGRect)frame completedShowHeight:(CGFloat)completedShowHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _originShowHeight = CGRectGetHeight(frame);
        _completedShowHeight = MAX(_originShowHeight, completedShowHeight);
//        _maxImageOffset = MAX(0.f, completedShowHeight - _originShowHeight);
        _offsetFactor = 0.5f;
        _hideOffsetFactor = 0.3f;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_imageView];
    }
    
    return self;
}

#pragma mark -

- (void)setImage:(UIImage *)image {
    [self setImage:image animated:NO];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    _imageView.image = image;
    
    if (animated) { //添加动画
        CATransition * transition = [CATransition animation];
        transition.duration = 1.0;
        [_imageView.layer addAnimation:transition forKey:nil];
    }
}

- (UIImage *)image {
    return _imageView.image;
}

#pragma mark -

- (void)setOriginShowHeight:(CGFloat)originShowHeight
{
    if (_originShowHeight != originShowHeight) {
        _originShowHeight = originShowHeight;
        [self setNeedsLayout];
    }
}

- (void)setCompletedShowHeight:(CGFloat)completedShowHeight
{
    completedShowHeight = MAX(_originShowHeight, completedShowHeight);
    if (_completedShowHeight != completedShowHeight) {
        _completedShowHeight = completedShowHeight;
        [self setNeedsLayout];
    }
}

- (void)setOffsetFactor:(CGFloat)offsetFactor
{
    offsetFactor = MAX(0.f, MIN(1.f, offsetFactor));
    if (_offsetFactor != offsetFactor) {
        _offsetFactor = offsetFactor;
        [self setNeedsLayout];
    }
}

- (void)setHideOffsetFactor:(CGFloat)hideOffsetFactor
{
    hideOffsetFactor = MAX(0.f, MIN(1.f, hideOffsetFactor));
    if (_hideOffsetFactor != hideOffsetFactor) {
        _hideOffsetFactor = hideOffsetFactor;
        [self setNeedsLayout];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    if (!CGPointEqualToPoint(_contentOffset, contentOffset)) {
        _contentOffset = contentOffset;
        [self _updateImageViewFrame];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    if (CGRectGetHeight(frame) != _originShowHeight) {
        frame.size.height = _originShowHeight;
        self.frame = frame;
    }
    
    [self _updateImageViewFrame];
}

- (void)_updateImageViewFrame
{
    CGFloat originY = 0.f;
    CGFloat scaleFacter = 1.f;
    CGFloat maxImageOffset = _completedShowHeight - _originShowHeight;
    
    if (_contentOffset.y <= - maxImageOffset) {
        originY = _contentOffset.y;
        scaleFacter = _completedShowHeight ?  (- originY + _originShowHeight) / _completedShowHeight : 1.f;
    }else if (_contentOffset.y <= 0.f) {
        originY = - _offsetFactor * maxImageOffset + (1.f - _offsetFactor) * _contentOffset.y;
    }else if (_contentOffset.y <= _originShowHeight) {
        originY = - _offsetFactor * maxImageOffset + _contentOffset.y * _hideOffsetFactor;
    }
    
    //设置图片视图的frame
    CGFloat width = self.width;
    _imageView.frame = CGRectMake(width * (1.f - scaleFacter) * 0.5f, originY, width * scaleFacter, scaleFacter * _completedShowHeight);
    
    //设置裁减蒙版
    CGRect maskLayerBounds = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(MIN(originY, 0.f), 0.f, 0.f, 0.f));
    if (!CGRectEqualToRect(maskLayerBounds, _maskLayerBounds)) {
        _maskLayerBounds = maskLayerBounds;
        
        CAShapeLayer * maskLayer = (id)self.layer.mask;
        if (![maskLayer isKindOfClass:[CAShapeLayer class]]) {
            maskLayer = [[CAShapeLayer alloc] init];
        }
        maskLayer.path = [UIBezierPath bezierPathWithRect:maskLayerBounds].CGPath;
        self.layer.mask = maskLayer;
    }
}

@end
