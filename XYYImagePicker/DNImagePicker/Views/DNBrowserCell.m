//
//  DNBrowserCell.m
//  ImagePicker
//
//  Created by DingXiao on 15/2/28.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import "DNBrowserCell.h"
#import "DNPhotoBrowser.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface DNBrowserCell () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *zoomingScrollView;
@property (nonatomic, strong) UIImageView *photoImageView;

@end

//----------------------------------------------------------

@implementation DNBrowserCell
{
    CGSize _sourceImageSize;
}

#pragma mark - 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //点击消失手势
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerHandle:)];
        tapGestureRecognizer.delegate  =self;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        //双击放大手势
        UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerHandle:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        doubleTapGestureRecognizer.delegate  =self;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        
        //需要双击失效
        [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    }
    
    return self;
}

- (UIImageView *)photoImageView
{
    if (nil == _photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.clipsToBounds = YES;
        [self.zoomingScrollView addSubview:_photoImageView];
    }
    return _photoImageView;
}

- (UIScrollView *)zoomingScrollView
{
    if (nil == _zoomingScrollView) {
        _zoomingScrollView = [[UIScrollView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 10.f, 0.f)];
        _zoomingScrollView.delegate = self;
        _zoomingScrollView.scrollEnabled = YES;
        _zoomingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_zoomingScrollView];
    }
    return _zoomingScrollView;
}

#pragma mark -

- (void)setImage:(UIImage *)image {
    [self setImage:image sourceImageSize:[image perfectShowSizeInScale:1.f]];
}

- (void)setImage:(UIImage *)image sourceImageSize:(CGSize)sourceImageSize
{
    _sourceImageSize = convertSizeToScale(sourceImageSize, 1.f, [UIScreen mainScreen].scale);
    self.photoImageView.image = image;
    
    [self _displayImage];
}

- (UIImage *)image {
    return self.photoImageView.image;
}

- (void)_displayImage
{
    if (!self.image) {
        self.zoomingScrollView.maximumZoomScale = 1;
        self.zoomingScrollView.minimumZoomScale = 1;
        self.zoomingScrollView.zoomScale = 1;
        self.zoomingScrollView.contentSize = CGSizeMake(0, 0);
    }else {
        
        //获取图片完美显示的尺寸
        CGSize imageSize = [self.image perfectShowSize];
        self.zoomingScrollView.zoomScale = 1.f;
        
        //设置大小和中心
        self.photoImageView.bounds = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
        self.zoomingScrollView.contentSize = imageSize;
        
        //设置最大最小缩放比例
        CGSize scrollViewSize = self.zoomingScrollView.frame.size;
        CGFloat widthFactor = scrollViewSize.width / imageSize.width;
        CGFloat heigthFactor = scrollViewSize.height / imageSize.height;
        
        //是否是长图（图片长宽比大于2.0倍屏幕长宽比）
        BOOL isLongImage = IS_LONGIMAGE(imageSize, scrollViewSize, 2.f) ||
                           IS_LONGIMAGE(_sourceImageSize, scrollViewSize, 2.f);

        //图片小于屏幕
        if (widthFactor > 1.f && heigthFactor > 1.f) {
            self.zoomingScrollView.minimumZoomScale = 1.f;
            self.zoomingScrollView.maximumZoomScale = isLongImage ? widthFactor : MIN(widthFactor, heigthFactor);
        }else if(widthFactor < 1.f && heigthFactor < 1.f) { //图片大于屏幕
            self.zoomingScrollView.minimumZoomScale = MIN(widthFactor, heigthFactor);
            self.zoomingScrollView.maximumZoomScale = 2.f;
        }else { //介于
            self.zoomingScrollView.minimumZoomScale = MIN(widthFactor, heigthFactor);
            self.zoomingScrollView.maximumZoomScale = MAX(widthFactor, heigthFactor);
        }
        
        self.zoomingScrollView.maximumZoomScale = MAX(2.f, self.zoomingScrollView.maximumZoomScale);
        self.zoomingScrollView.zoomScale = (isLongImage ? widthFactor : MIN(widthFactor, heigthFactor));
        
        //更新视图
        [self _updateViewWhenViewDidZoom];
        self.zoomingScrollView.contentOffset = CGPointZero;
    }
}

- (void)_updateViewWhenViewDidZoom
{
    //滑动区域小于内容大小则不允许滑动防止滑动失效
    CGSize contentSize = self.zoomingScrollView.contentSize;
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    self.zoomingScrollView.scrollEnabled = floorf(contentSize.width)  - 2.f > boundsSize.width ||
                                           floorf(contentSize.height) - 2.f > boundsSize.height;
    
    //定位到中心
    CGFloat offsetX = boundsSize.width > contentSize.width ? (boundsSize.width - contentSize.width) * 0.5f : 0.f;
    CGFloat offsetY = boundsSize.height > contentSize.height ? (boundsSize.height - contentSize.height) * 0.5f : 0.f;
    self.photoImageView.center = CGPointMake(contentSize.width * 0.5f + offsetX, contentSize.height * 0.5f + offsetY);
}

#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self _updateViewWhenViewDidZoom];
}

#pragma mark - Tap Detection

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.image != nil;
}

- (void)_tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.numberOfTapsRequired == 1) {
        [self.photoBrowser toggleControls];
    }else { //双击缩放视图

        CGSize boundsSize = self.zoomingScrollView.bounds.size;
        CGPoint touchPoint = [tapGestureRecognizer locationInView:self.photoImageView];
        
        //最大时缩放到最小，其他情况缩放到最大
        CGFloat newScale = (self.zoomingScrollView.zoomScale == self.zoomingScrollView.maximumZoomScale) ? self.zoomingScrollView.minimumZoomScale : self.zoomingScrollView.maximumZoomScale;
        
        CGFloat w = boundsSize.width / newScale;
        CGFloat h = boundsSize.height / newScale;
        CGFloat x = touchPoint.x - w / 2.f;
        CGFloat y = touchPoint.y - h / 2.f;
        
        [self.zoomingScrollView zoomToRect:CGRectMake(x, y, w, h) animated:YES];
    }
}

@end
