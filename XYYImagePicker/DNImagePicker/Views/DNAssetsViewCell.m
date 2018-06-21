//
//  DNAssetsViewCell.m
//  ImagePicker
//
//  Created by DingXiao on 15/2/11.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import "DNAssetsViewCell.h"

//----------------------------------------------------------

@interface DNAssetsViewCell ()

@property (nonatomic, strong,readonly) UIImageView *imageView;
@property (nonatomic, strong,readonly) UIButton *checkButton;
@property (nonatomic, strong,readonly) UIImageView *checkImage;


@property (nonatomic, strong,readonly) UIView *imageHoverView;


@end

//----------------------------------------------------------

@implementation DNAssetsViewCell

@synthesize imageView = _imageView;
@synthesize checkButton = _checkButton;
@synthesize checkImage = _checkImage;
@synthesize imageHoverView = _imageHoverView;

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIView *)imageHoverView
{
    if (!_imageHoverView) {
        _imageHoverView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _imageHoverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageHoverView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
        [self.imageView addSubview:_imageHoverView];
    }
    
    return _imageHoverView;
}

- (UIButton *)checkButton
{
    if (!_checkButton) {
        _checkButton = [[UIButton alloc] init];
        [_checkButton addTarget:self action:@selector(checkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_checkButton];
    }
    
    return _checkButton;
}

- (UIImageView *)checkImage
{
    if (!_checkImage) {
        _checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_check_default"]];
        [self.contentView addSubview:_checkImage];
    }
    
    return _checkImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.checkImage.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 27.f, 3.f, 25.f, 25.f);
    CGFloat width = CGRectGetWidth(self.contentView.bounds) * 0.5f;
    self.checkButton.frame = CGRectMake(width, 0.f, width, width);
}

#pragma mark -

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        _image = image;
        self.imageView.image = image ?: [UIImage imageNamed:@"assets_placeholder_picture"];
    }
}

- (void)setSelected:(BOOL)selected
{
    if (self.isSelected != selected) {
        [super setSelected:selected];
        self.checkImage.image = selected ? [UIImage imageNamed:@"photo_check_selected"] : [UIImage imageNamed:@"photo_check_default"];
    }
}

- (void)checkButtonAction:(id)sender
{
    if (self.isSelected) {
        if ([self.delegate respondsToSelector:@selector(didDeselectItemAssetsViewCell:)]) {
            [self.delegate didDeselectItemAssetsViewCell:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didSelectItemAssetsViewCell:)]) {
            if ([self.delegate didSelectItemAssetsViewCell:self]) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.checkImage.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                }
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:0.2 animations:^{
                                         self.checkImage.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                     }];
                                 }];
                
            }
        }
    }
}

#pragma mark -

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.isHighlighted != highlighted) {
        [super setHighlighted:highlighted];
        self.imageHoverView.hidden = !highlighted;
    }
}

@end