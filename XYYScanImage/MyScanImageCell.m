//
//  MyScanImageCell.m
//  
//
//  Created by LeslieChen on 15/11/6.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyScanImageCell.h"
#import "XYYFoundation.h"
#import "XYYNetImage.h"
#import "MBProgressHUD.h"

//----------------------------------------------------------

@interface MyScanImageCell () < UIScrollViewDelegate,
                                MyImageDownLoadDelegate >

@property(nonatomic,strong,readonly) UIScrollView * scrollView;

@end

//----------------------------------------------------------

@implementation MyScanImageCell
{
    //双击时的最小缩放比例
    CGFloat _doubleTapMinScale;
}

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //点击消失手势
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerHandle:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        //双击放大手势
        UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerHandle:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        
        //单击手势需要双击手势失效
        [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.scrollEnabled = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        
        //适配
        configurationContentScrollViewForAdaptation(_scrollView);
        
        [self addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (void)updateWithSafeAreaInsets:(UIEdgeInsets)safeAreaInsets
{
//    //忽略除了iPhone X以外的安全区
//    if (safeAreaInsets.top <= StatusBarHeight) {
//        safeAreaInsets = UIEdgeInsetsZero;
//    }
//    
    //设置inset
    self.scrollView.contentInset = self.scrollView.scrollIndicatorInsets = safeAreaInsets;
}

#pragma mark -

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.scrollView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIImage *)displayingImage {
    return self.imageView.image;
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.scrollView.frame, self.contentView.bounds)) {
        [self _updateImageDisplay];
    }
}

- (void)displayImage:(MyScanImageData *)scanImageData {
    [self displayImage:scanImageData forAnimationCalculation:NO];
}

- (void)displayImage:(MyScanImageData *)scanImageData forAnimationCalculation:(BOOL)forAnimationCalculation
{
    _scanImageData = scanImageData;
    _imageDisplayState = MyScanImageDisplayStateNone;
    
    
    UIImage * sourceImage = scanImageData.sourceImage;
    if (sourceImage == nil && scanImageData.sourceImageURL.length) { //尝试从内存加载原图
        sourceImage = [[MyImageCachePool shareImageCachePool] imageWithKey:scanImageData.sourceImageURL
                                                                    policy:MyCacheImagePolicyUseOuterCache
                                                                      type:NULL];
    }
    
    //显示图片
    [self _changeToDisplayImage:sourceImage ?: scanImageData.thumb];
    
    if (forAnimationCalculation) {
        return;
    }
    
    //取消下载图片
    [self _cancleLoadImage];
    
    //异步开始下载和更新显示状态，防止代理回调方法失效
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (self.scanImageData != scanImageData) {
            return;
        }
        
        //更新显示状态
        if (sourceImage) {
            [self _setImageDisplayState:MyScanImageDisplayStateSource];
        }else {
            [self _setImageDisplayState:scanImageData.thumb ? MyScanImageDisplayStateThumb : MyScanImageDisplayStateNone];
            
            //开始加载原图
            [self _startLoadSourceImage];
        }
    });
}

#pragma mark -

- (void)_startLoadSourceImage
{
    if (self.imageDisplayState == MyScanImageDisplayStateSource || self.scanImageData.sourceImageURL.length == 0) {
        return;
    }
    
    //设置状态
    [self _setImageDisplayState:MyScanImageDisplayStateLoading | self.imageDisplayState];
    
    //加载指示视图
    MBProgressHUD * progressView = [[MBProgressHUD alloc] initWithView:self];
    progressView.margin = 0.f;
    progressView.minSize = CGSizeMake(45.f, 45.f);
    progressView.cornerRadius = 22.5f;
    progressView.opacity = 0.4f;
    
    MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] init];
    activityIndicatorView.lineWidth = 5.f;
    activityIndicatorView.startAngle = -90;
    activityIndicatorView.tintColor = [UIColor colorWithWhite:1.f alpha:0.5f];
    
    //没有文件缓存则显示进度加载视图
    if(![[MyImageCachePool shareImageCachePool] hadCacheImageForKey:self.scanImageData.sourceImageURL]){
        activityIndicatorView.style = MyActivityIndicatorViewStyleDeterminate;
    }else {
        [activityIndicatorView startAnimating];
    }
    
    progressView.customView = activityIndicatorView;
    progressView.mode = MBProgressHUDModeCustomView;
    
    [self addSubview:progressView];
    [progressView show:NO];
    
    //开始下载图片
    [[MyImageDownLoadManager shareImageDownLoadManager] startDownLoadImage:self
                                                                       URL:self.scanImageData.sourceImageURL
                                                            downLoadPolicy:MyImageDownLoadPolicyDefault];
}

//取消加载图片
- (void)_cancleLoadImage
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //取消下载
    [[MyImageDownLoadManager shareImageDownLoadManager] cancleDownLoadImage:self forceToCancle:NO];
    
    //隐藏加载指示视图
    [MBProgressHUD hideHUDForView:self animated:NO];
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
                    imageURL:(NSString *)url
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed
{
    MBProgressHUD * progressView = [MBProgressHUD HUDForView:self];
    if (expectedDataLength != NSURLResponseUnknownLength) { //设置进度
        [progressView setProgress:(float)receiveDataLength/expectedDataLength];
    }else{
        MyActivityIndicatorView * activityIndicatorView = (id)progressView.customView;
        activityIndicatorView.style = MyActivityIndicatorViewStyleIndeterminate;
        [activityIndicatorView startAnimating];
    }
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
        downloadFailedForURL:(NSString *)url
                       error:(NSError *)error
{
    //无网络可用时观察网络改变，网络有效时重新开始请求
    if (IS_SPECIFIC_ERROR(error, ImageDownLoadErrorDomain, ImageDownLoadErrorCodeNetUnavailable)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_netReachabilityChangedNotification:)
                                                     name:NetReachabilityChangedNotification
                                                   object:nil];
    }
    
    [MBProgressHUD hideHUDForView:self animated:NO];
    [self _setImageDisplayState:self.imageDisplayState & ~MyScanImageDisplayStateLoading];
}

- (void)_netReachabilityChangedNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
    [self _startLoadSourceImage];
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
       downloadSucceedForURL:(NSString *)url
                       image:(UIImage *)image
                  resultType:(MyImageDownLoadResultType)resultType
{
    [MBProgressHUD hideHUDForView:self animated:NO];
    
    [self _changeToDisplayImage:image];
    [self _setImageDisplayState:MyScanImageDisplayStateSource];
}

#pragma mark -

- (void)_changeToDisplayImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.backgroundColor = image ? [UIColor clearColor] : (self.scanImageData ? self.scanImageData.imagePlaceholderColor : [UIColor whiteColor]);
    
    //更新图片的显示
    [self _updateImageDisplay];
}

- (void)_updateImageDisplay
{
    //原图大小
    CGSize sourceImageSize = convertSizeToScale(self.scanImageData.sourceImageSize, 1.f, [UIScreen mainScreen].scale);

    //获取图片的大小
    CGSize imageSize = CGSizeZero;
    if (self.imageView.image) { 
        imageSize = [self.imageView.image perfectShowSize];
    }else if (!CGSizeEqualToSize(sourceImageSize, CGSizeZero)) {
        imageSize = sourceImageSize;
    }else if(!CGSizeEqualToSize(self.scanImageData.thumbShowFrame.size, CGSizeZero)){
        imageSize = self.scanImageData.thumbShowFrame.size;
    }else {
        imageSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) * 0.5f);
    }

    self.scrollView.zoomScale = 1.f;
    
    //设置大小
    self.imageView.bounds = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
    self.scrollView.contentSize = imageSize;
    
    //设置最大最小缩放比例
    CGSize scrollViewSize = self.bounds.size;
    CGFloat widthFactor = scrollViewSize.width / imageSize.width;
    CGFloat heigthFactor = scrollViewSize.height / imageSize.height;

    //是否是长图（图片长宽比大于屏幕长宽比）
    BOOL isLongImage = IS_LONGIMAGE(imageSize, scrollViewSize, 1.1f) ||
                       IS_LONGIMAGE(sourceImageSize, scrollViewSize, 1.1f);
    
    //计算缩放比例
    if (widthFactor > 1.f && heigthFactor > 1.f) { //图片小于屏幕
        self.scrollView.minimumZoomScale = _doubleTapMinScale = 1.f;
        self.scrollView.maximumZoomScale = isLongImage ? widthFactor : MIN(widthFactor, heigthFactor);
    }else if(widthFactor < 1.f && heigthFactor < 1.f) { //图片大于屏幕
        self.scrollView.minimumZoomScale = _doubleTapMinScale = isLongImage ? widthFactor :  MIN(widthFactor, heigthFactor);
        self.scrollView.maximumZoomScale = 2.f;
    }else { //介于
        self.scrollView.minimumZoomScale = isLongImage ? 1.f : MIN(widthFactor, heigthFactor);
        self.scrollView.maximumZoomScale = MAX(widthFactor, heigthFactor);
        _doubleTapMinScale = isLongImage ? widthFactor : MIN(widthFactor, heigthFactor);
    }
    
    self.scrollView.maximumZoomScale = MAX(2.f, self.scrollView.maximumZoomScale);
    self.scrollView.zoomScale = (isLongImage ? widthFactor : MIN(widthFactor, heigthFactor));
    
    //更新视图
    [self _updateViewWhenViewDidZoom];
    self.scrollView.contentOffset = CGPointZero;
}

- (void)_updateViewWhenViewDidZoom
{
    //设置滑动可用性
    //滑动区域小于内容大小则不允许滑动防止滑动失效
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    self.scrollView.scrollEnabled = floorf(contentSize.width)  - 2.f > boundsSize.width ||
                                    floorf(contentSize.height) - 2.f > boundsSize.height;
    
    //图片定位到中心
    CGFloat offsetX = boundsSize.width > contentSize.width ? (boundsSize.width - contentSize.width) * 0.5f : 0.f;
    CGFloat offsetY = boundsSize.height > contentSize.height ? (boundsSize.height - contentSize.height) * 0.5f : 0.f;
    self.imageView.center = CGPointMake(contentSize.width * 0.5f + offsetX, contentSize.height * 0.5f + offsetY);
}

#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self _updateViewWhenViewDidZoom];
}

#pragma mark -

- (void)_setImageDisplayState:(MyScanImageDisplayState)imageDisplayState
{
    if (_imageDisplayState != imageDisplayState) {
        _imageDisplayState = imageDisplayState;
        
        id<MyScanImageCellDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(scanImageCellDidChangeImageDisplayState:)) {
            [delegate scanImageCellDidChangeImageDisplayState:self];
        }
    }
}

#pragma mark -

- (void)_tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.numberOfTapsRequired == 1) {
        
        id<MyScanImageCellDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(scanImageCellDidTapHide:)) {
            [delegate scanImageCellDidTapHide:self];
        }
        
        
    }else{ //双击 ,缩放到最大或最小
        
        if ((self.imageDisplayState == MyScanImageDisplayStateThumb || self.imageDisplayState == MyScanImageDisplayStateSource)) {
            
            CGSize boundsSize = self.scrollView.bounds.size;
            CGPoint touchPoint = [tapGestureRecognizer locationInView:self.imageView];
            
            //最大时缩放到最小，其他情况缩放到最大
            CGFloat newScale = (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) ? _doubleTapMinScale : self.scrollView.maximumZoomScale;
            CGFloat w = boundsSize.width / newScale;
            CGFloat h = boundsSize.height / newScale;
            CGFloat x = touchPoint.x - w / 2.f;
            CGFloat y = touchPoint.y - h / 2.f;
            
            [self.scrollView zoomToRect:CGRectMake(x, y, w, h) animated:YES];
        }
    }
}

#pragma mark -

- (BOOL)isDisplayLongImage
{
    return IS_LONGIMAGE_BASIC_SCREEN(self.imageView.frame.size, 2.f) ||
           IS_LONGIMAGE_BASIC_SCREEN(convertSizeToScale(self.scanImageData.sourceImageSize, 1.f, [UIScreen mainScreen].scale), 2.f);
}

@end
