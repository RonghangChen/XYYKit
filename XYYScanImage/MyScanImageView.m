//
//  MyScanImageView.m
//  
//
//  Created by LeslieChen on 15/11/6.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyScanImageView.h"
#import "MyScanImageCell.h"
#import "XYYPageView.h"
#import "MBProgressHUD.h"

//----------------------------------------------------------

NSString * const MyScanImageOverlayViewFrameDidInvalidateNotification = @"MyScanImageOverlayViewFrameDidInvalidateNotification";

//----------------------------------------------------------

@interface _MyScanImageViewController : UIViewController

@end

//----------------------------------------------------------

@implementation _MyScanImageViewController


- (BOOL)prefersStatusBarHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIApplication sharedApplication].statusBarStyle;
}

//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
//    return UIStatusBarAnimationFade;
//}

- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end

//----------------------------------------------------------

@interface _MyScanImageViewDataSource : NSObject<MyScanImageViewDataSource>

- (id)initWithImages:(NSArray<MyScanImageData *> *)imageDatas;
@property(nonatomic,strong,readonly) NSArray<MyScanImageData *> * imageDatas;

@end

//----------------------------------------------------------

@implementation _MyScanImageViewDataSource

- (id)initWithImages:(NSArray<MyScanImageData *> *)imageDatas
{
    self = [super init];
    if (self) {
        _imageDatas = imageDatas;
    }
    
    return self;
}

- (NSUInteger)scanImageView:(MyScanImageView *)scanImageView numberOfImagesForScanWithContext:(id)context
{
    MyAssert(context == self);
    return self.imageDatas.count;
}

- (MyScanImageData *)scanImageView:(MyScanImageView *)scanImageView imageForScanAtIndex:(NSUInteger)index withContext:(id)context
{
    MyAssert(context == self);
    return self.imageDatas[index];
}

@end

//----------------------------------------------------------

@interface MyScanImageView () < MyPageViewDelegate,
                                MyPageViewDataSource,
                                MyScanImageCellDelegate,
                                UIGestureRecognizerDelegate>

//显示的窗口
@property(nonatomic,strong) UIWindow * s_window;

//背景视图，用于显示背景色和毛玻璃效果
@property(nonatomic,strong) MyBlurredView * backgroundView;

//page视图
@property(nonatomic,strong) MyPageView * pageView;

//索引指示label
@property(nonatomic,strong) UILabel * indexIndicaterLabel;

@end

//----------------------------------------------------------

@implementation MyScanImageView

@synthesize scanBackgroundColor = _scanBackgroundColor;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@synthesize blurEffectStyle = _blurEffectStyle;
@synthesize blurEffectAlpha = _blurEffectAlpha;
#endif
@synthesize blurredBackgroundType = _blurredBackgroundType;
@synthesize applyBlurredEffectBlock = _applyBlurredEffectBlock;

#pragma mark - 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        super.backgroundColor = [UIColor clearColor];
        
        _indexIndicaterMinimumDisplayImageCount = 2;
        _displayIndexIndicater = YES;
        _canLongPerssSaveImageToPhotosAlbum = YES;
        _currentDispalyImageIndex = NSNotFound;
        
        //长按保存手势
        UILongPressGestureRecognizer * longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressGestureRecognizerHandle:)];
        longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    //do nothing
}

#pragma mark -

- (void)setOverlayView:(UIView *)overlayView
{
    if (_overlayView != overlayView) {
        
        if (_overlayView) {
            [_overlayView removeFromSuperview];
            
            //移除通知
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MyScanImageOverlayViewFrameDidInvalidateNotification object:_overlayView];
        }
        
        _overlayView = overlayView;
        
        if (_overlayView) {
            
            //添加通知
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_overlayViewFrameInvalidateNotification:)
                                                         name:MyScanImageOverlayViewFrameDidInvalidateNotification
                                                       object:_overlayView];
            
            //如果正在浏览则家兔
            if (self.isScanning) {
                [self addSubview:_overlayView];
                [self setNeedsLayout];
                
                [_overlayView didChangeDisplayImage];
            }
        }
    }
}

- (void)_overlayViewFrameInvalidateNotification:(NSNotification *)notification
{
    if (notification.object == self.overlayView) {
        if (self.isScanning) {
            [self setNeedsLayout];
        }
    }
}

- (void)_updateOverlayViewFrame
{
    if (_overlayView) {
        _overlayView.frame = [_overlayView frameThatFitForScanImageOverlayView:self.bounds safeAreaInsets:[self _safeAreaInsetsBaseOrientation]];
    }
}

#pragma mark -

- (UIColor *)scanBackgroundColor {
    return _scanBackgroundColor ?: (_scanBackgroundColor = [UIColor blackColor]);
}

- (void)setScanBackgroundColor:(UIColor *)scanBackgroundColor
{
    if (_scanBackgroundColor != scanBackgroundColor) {
        _scanBackgroundColor = scanBackgroundColor;
        
        if (self.isScanning) {
            self.backgroundView.backgroundColor = self.scanBackgroundColor;
        }
    }
}

#pragma mark - 

- (void)setDisplayIndexIndicater:(BOOL)displayIndexIndicater
{
    if (_displayIndexIndicater != displayIndexIndicater) {
        _displayIndexIndicater = displayIndexIndicater;
        [self _updateIndexIndicater];
    }
}

- (void)setIndexIndicaterMinimumDisplayImageCount:(NSUInteger)indexIndicaterMinimumDisplayImageCount
{
    if (_indexIndicaterMinimumDisplayImageCount != indexIndicaterMinimumDisplayImageCount) {
        _indexIndicaterMinimumDisplayImageCount = indexIndicaterMinimumDisplayImageCount;
        [self _updateIndexIndicater];
    }
}

- (void)_updateIndexIndicater
{
    if (self.isScanning) {
        
        if (self.displayIndexIndicater && self.indexIndicaterMinimumDisplayImageCount <= self.numberOfImages) {
            if (!self.indexIndicaterLabel) {
                
                self.indexIndicaterLabel = [[UILabel alloc] init];
                self.indexIndicaterLabel.font = [UIFont boldSystemFontOfSize:18.f];
                self.indexIndicaterLabel.textAlignment = NSTextAlignmentCenter;
                self.indexIndicaterLabel.textColor = [UIColor whiteColor];
                self.indexIndicaterLabel.backgroundColor = BlackColorWithAlpha(0.3f);
                self.indexIndicaterLabel.layer.cornerRadius = 20.f;
                self.indexIndicaterLabel.clipsToBounds = YES;
                [self addSubview:self.indexIndicaterLabel];
                
                //计算大小
                CGSize indexIndicaterLabelSize = [UILabel showSizeWithText:[NSString stringWithFormat:@"%i/%i",(int)self.numberOfImages,(int)self.numberOfImages] font:self.indexIndicaterLabel.font width:MAXFLOAT];
                indexIndicaterLabelSize.width += 30.f;
                indexIndicaterLabelSize.height = 40.f;
                self.indexIndicaterLabel.bounds = CGRectMake(0.f, 0.f, indexIndicaterLabelSize.width, indexIndicaterLabelSize.height);
                
                //更新位置
                [self _updateIndexIndicaterFrame];
            }
            
            //更新显示的值
            [self _updateIndexIndicaterValue];
            
        }else if(self.indexIndicaterLabel) {
            [self.indexIndicaterLabel removeFromSuperview];
            self.indexIndicaterLabel = nil;
        }
    }
}

- (void)_updateIndexIndicaterFrame
{
    if (self.indexIndicaterLabel) {
        CGFloat topMargin = MAX([self _safeAreaInsetsBaseOrientation].top, StatusBarHeight);
        self.indexIndicaterLabel.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5f, topMargin + CGRectGetHeight(self.indexIndicaterLabel.bounds) * 0.5f);
    }
}

- (void)_updateIndexIndicaterValue
{
    if (self.indexIndicaterLabel) {
        self.indexIndicaterLabel.text = [NSString stringWithFormat:@"%i/%i",(int)(self.currentDispalyImageIndex + 1),(int)self.numberOfImages];
    }
}

#pragma mark -

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
 
    if (self.isScanning) {
        [self setNeedsLayout];
        [self.pageView reloadPages:YES];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isScanning) {
        [self _updateOverlayViewFrame];
        [self _updateIndexIndicaterFrame];
    }
}

#pragma mark -

- (void)startScanImage:(MyScanImageData *)image
            baseWindow:(UIWindow *)baseWindow
              animated:(BOOL)animated
        completedBlock:(void (^)(void))completedBlock
{
    [self startScanImageAtIndex:0 withImages:@[image] baseWindow:baseWindow animated:animated completedBlock:completedBlock];
}

- (void)startScanImageAtIndex:(NSUInteger)index
                   withImages:(NSArray<MyScanImageData *> *)images
                   baseWindow:(UIWindow *)baseWindow
                     animated:(BOOL)animated
               completedBlock:(void (^)(void))completedBlock
{
    _MyScanImageViewDataSource * dataSource = [[_MyScanImageViewDataSource alloc] initWithImages:images];
    
    [self startScanImageAtIndex:index
                 withDataSource:dataSource
                        context:dataSource
                     baseWindow:baseWindow
                       animated:animated
                 completedBlock:completedBlock];
}

- (void)startScanImageAtIndex:(NSUInteger)index
               withDataSource:(id<MyScanImageViewDataSource>)dataSource
                      context:(id)context
                   baseWindow:(UIWindow *)baseWindow
                     animated:(BOOL)animated
               completedBlock:(void(^)(void))completedBlock
{
    [self endScanImageWithAnimated:NO completedBlock:nil];
 
    if (dataSource == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"数据源不能为nil"
                                     userInfo:nil];
    }else if(![dataSource respondsToSelector:@selector(scanImageView:imageForScanAtIndex:withContext:)]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"数据源必须实现scanImageView:imageForScanAtIndex:withContext:方法"
                                     userInfo:nil];
    }
    
    _dataSource = dataSource;
    _scanContext = context;
    
    //数据总数
    _numberOfImages = [self _numberOfImages];
    _scanning = YES;
    
    //创建window并显示
    baseWindow = baseWindow ?: [UIApplication sharedApplication].keyWindow;
    if (baseWindow.rootViewController.interfaceOrientation != UIInterfaceOrientationPortrait) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"当前只支持baseWindow没有旋转的情况"
                                     userInfo:nil];
    }
    
    //创建window
    self.s_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.s_window.windowLevel = MAX(baseWindow.windowLevel, UIWindowLevelStatusBar);
    self.s_window.tintColor = baseWindow.tintColor;
    
    //毛玻璃视图
    self.backgroundView = [[MyBlurredView alloc] initWithFrame:self.s_window.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    self.backgroundView.blurEffectStyle = self.blurEffectStyle;
    self.backgroundView.blurEffectAlpha = self.blurEffectAlpha;
#endif
    self.backgroundView.blurredBackgroundType = self.blurredBackgroundType;
    self.backgroundView.applyBlurredEffectBlock = self.applyBlurredEffectBlock;
    self.backgroundView.backgroundColor = self.scanBackgroundColor;
    [self.s_window addSubview:self.backgroundView];
    
    //更新毛玻璃效果
    [self.backgroundView updateBlurredWithWindow:baseWindow];
    
    //加入window
    _MyScanImageViewController * vc = [[_MyScanImageViewController alloc] init];
    vc.automaticallyAdjustsScrollViewInsets = NO;
    vc.view.frame = self.s_window.bounds;
    self.s_window.rootViewController = vc;
    
    self.frame = vc.view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [vc.view addSubview:self];

    //旋转到设备方向
    _orientation = UIInterfaceOrientationPortrait;
    UIInterfaceOrientation deviceOrientation = [self _currentDeviceOrientation];
    if (deviceOrientation != UIInterfaceOrientationUnknown) {
        [self _setOrientation:deviceOrientation];
    }
    
    //显示
    [self.s_window makeKeyAndVisible];
    
    //初始化page视图
    self.pageView = [[MyPageView alloc] initWithFrame:self.bounds];
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    self.pageView.pageMargin = 20.f;
    self.pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.pageView];
    
    //注册复用
    [self.pageView registerCellForPage:[MyScanImageCell class] andReuseIdentifier:defaultReuseDef];
    
    
    //移动到当前显示的位置
    _currentDispalyImageIndex = index;
    [self.pageView setDispalyPageIndex:index];

    //加入overlay视图
    if (self.overlayView) {
        [self addSubview:self.overlayView];
        [self _updateOverlayViewFrame];
        [_overlayView didChangeDisplayImage];
    }

    //更新索引指示视图
    [self _updateIndexIndicater];
    
    //完成时调用的block
    void (^_completedBlock)(void) = ^ {
        
        //更新注册设备方向改变通知
        [self _updateRegisterDeviceOrientationDidChangeNotification];
        
        if (completedBlock) {
            completedBlock();
        }
    };
    
    if (animated) {
        
        MyScanImageData * imageData = [self _imageDataAtIndex:self.currentDispalyImageIndex];
        MyScanImageCell * cell = [[MyScanImageCell alloc] initWithFrame:self.bounds];
        [cell displayImage:imageData forAnimationCalculation:YES];
        
        //图片显示的位置
        CGRect imageDisplayFrame = [cell convertRect:cell.imageView.bounds fromView:cell.imageView];
        //缩略图位置
        CGRect thumbShowFrame =  imageData.thumbShowFrame;
        
        //旋转到竖直方向
        UIInterfaceOrientation currentOrientation = self.orientation;
        if (currentOrientation != UIInterfaceOrientationPortrait) {
            [self _setOrientation:UIInterfaceOrientationPortrait];
            [self _updateIndexIndicater];
            [self _updateOverlayViewFrame];
        }
        
        //初始化用于动画的图片视图
        UIView * imageView = [self _createImageForAnimatedWithSourceImageView:cell.imageView];
        
        //将图片的锚点定位到视图中点防止放大时偏移
        imageView.frame = imageDisplayFrame;
        CGPoint center = [imageView convertPoint:CenterForRect(self.bounds) fromView:self];
        imageView.layer.anchorPoint = CGPointMake(center.x / CGRectGetWidth(imageDisplayFrame),
                                                  center.y / CGRectGetHeight(imageDisplayFrame));
        imageView.frame = imageDisplayFrame;
        
        
        if (CGRectEqualToRect(thumbShowFrame, CGRectZero)) { //无缩略图位置，显示简单动画
            
            imageView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
            imageView.alpha = 0.f;
            
            self.backgroundView.alpha = 0.f;
            self.overlayView.alpha = 0.f;
            self.indexIndicaterLabel.alpha = 0.f;
            
            //动画期间不可交互和当前视图隐藏
            self.userInteractionEnabled = NO;
            self.pageView.hidden = YES;
            
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.overlayView.alpha = 1.f;
                self.backgroundView.alpha = 1.f;
                self.indexIndicaterLabel.alpha = 1.f;
                
                if (currentOrientation != UIInterfaceOrientationPortrait) {
                    [self _setOrientation:currentOrientation];
                    [self _updateIndexIndicater];
                    [self _updateOverlayViewFrame];
                }
                
                imageView.transform = CGAffineTransformIdentity;
                imageView.alpha = 1.f;
                
            } completion:^(BOOL finished) {
                
                [imageView removeFromSuperview];
                
                self.userInteractionEnabled = YES;
                self.pageView.hidden = NO;
                
                _completedBlock();
            }];
            
        }else{
            
            imageView.center = CenterForRect(thumbShowFrame);
            
            //缩放后的缩略图大小
            CGSize scaledThumbSize = sizeZoomToTagetSize(thumbShowFrame.size, imageDisplayFrame.size, MyZoomModeAspectFit);
            
            //缩放倍数
            CGFloat scale = CGRectGetWidth(thumbShowFrame) / scaledThumbSize.width;
            imageView.transform = CGAffineTransformMakeScale(scale, scale);
            
            //缩放后的大小不等于现在显示的大小，即需要裁剪动画
            if (fabs(scaledThumbSize.width / scaledThumbSize.height - CGRectGetWidth(imageDisplayFrame) / CGRectGetHeight(imageDisplayFrame)) > 0.01f || imageData.thumbShowCornerRadius > 0.f) {
                
                CALayer * maskLayer = [[CALayer alloc] init];
                maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
                maskLayer.frame = imageView.bounds;
                imageView.layer.mask = maskLayer;
                
                CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                animation.duration = 0.1;
                animation.fromValue = [NSValue valueWithCGRect:CGRectMake(0.f, 0.f, scaledThumbSize.width, scaledThumbSize.height)];
                [maskLayer addAnimation:animation forKey:nil];
                
                if (imageData.thumbShowCornerRadius > 0.f) {
                    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    animation.duration = 0.1;
                    animation.fromValue = @(imageData.thumbShowCornerRadius / scale);
                    [maskLayer addAnimation:animation forKey:nil];
                }
            }
            
            //背景色和overlayView视图动画
            self.backgroundView.alpha = 0.f;
            self.overlayView.alpha = 0.f;
            self.indexIndicaterLabel.alpha = 0.f;
            [UIView animateWithDuration:0.3 animations:^{
                self.backgroundView.alpha = 1.f;
                self.overlayView.alpha = 1.f;
                self.indexIndicaterLabel.alpha = 1.f;
            }];
            
            //动画期间不可交互和当前视图隐藏
            self.userInteractionEnabled = NO;
            self.pageView.hidden = YES;
            
            if (currentOrientation != UIInterfaceOrientationPortrait) {
                
                //图片移动和放大动画
                [UIView animateWithDuration:0.4
                                 animations:^{
                                     
                                     imageView.transform = CGAffineTransformIdentity;
                                     imageView.center = CenterForRect(self.bounds);
                                     
                                     [self _setOrientation:currentOrientation];
                                     [self _updateIndexIndicater];
                                     [self _updateOverlayViewFrame];

                                     
                                 } completion:^(BOOL finished) {
                                     
                                     [imageView removeFromSuperview];
                                     self.userInteractionEnabled = YES;
                                     self.pageView.hidden = NO;
                                     
                                     _completedBlock();
                                 }];
                
            }else {
                
                //图片移动和放大动画
                [UIView animateWithDuration:0.6
                                      delay:0.0
                     usingSpringWithDamping:0.6f
                      initialSpringVelocity:0.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     imageView.transform = CGAffineTransformIdentity;
                                     imageView.center = CenterForRect(self.bounds);
                                     
                                 } completion:^(BOOL finished) {
                                     
                                     [imageView removeFromSuperview];
                                     self.userInteractionEnabled = YES;
                                     self.pageView.hidden = NO;
                                     
                                     _completedBlock();
                                 }]; 
                
            }
        }
        
    }else {
        _completedBlock();
    }
    
    //开始浏览
    id<MyScanImageViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(scanImageViewDidStartScan:)) {
        [delegate scanImageViewDidStartScan:self];
    }
}

- (UIImageView *)_createImageForAnimatedWithSourceImageView:(UIImageView *)sourceImageView
{
    UIImageView * imageView = [[UIImageView alloc] initWithImage:sourceImageView.image];
    imageView.backgroundColor = sourceImageView.backgroundColor;
    imageView.clipsToBounds = YES;
    [self insertSubview:imageView aboveSubview:self.pageView];
    
    return imageView;
}

- (NSUInteger)_numberOfImages
{
    NSUInteger numberOfImages = 1;
    id<MyScanImageViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(scanImageView:numberOfImagesForScanWithContext:)) {
        numberOfImages = [dataSource scanImageView:self numberOfImagesForScanWithContext:self.scanContext];
    }
    
    return numberOfImages;
}

- (MyScanImageData *)_imageDataAtIndex:(NSUInteger)index
{
    if (self.numberOfImages <= index) { //索引应该小于数据总数
        return nil;
    }
    
    MyScanImageData * image = [self.dataSource scanImageView:self imageForScanAtIndex:index withContext:self.scanContext];
    if (image == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"数据源返回的图片数据不能为nil"
                                     userInfo:nil];
    }
    
    return image;
}

- (MyScanImageData *)imageAtIndex:(NSUInteger)index
{
    if (self.scanning) {
        
        MyScanImageCell * cell = [self.pageView cellForPageAtIndex:index];
        if (cell != nil) {
            return cell.scanImageData;
        }else {
            return [self _imageDataAtIndex:index];
        }
    }
    
    return nil;
}

- (void)reloadImages:(BOOL)keepDispalyImage
{
    if (self.isScanning) {
        
        //重新获取总数
        NSUInteger numberOfImages = [self _numberOfImages];
        if (numberOfImages == 0) { //无数据则直接隐藏
            [self endScanImageWithAnimated:NO completedBlock:nil];
            return;
        }
        
        _numberOfImages = numberOfImages;
        
        NSUInteger currentDispalyImageIndex = keepDispalyImage && numberOfImages > _currentDispalyImageIndex ? _currentDispalyImageIndex : 0 ;
        _currentDispalyImageIndex = currentDispalyImageIndex;
        
        //重新加载数据和移动位置
        [self.pageView reloadPages:YES];
        [self.pageView setDispalyPageIndex:_currentDispalyImageIndex];
        
        //改变显示的图片
        [_overlayView didChangeDisplayImage];
        
        //更新索引指示器
        [self _updateIndexIndicater];
    }
}

#pragma mark -

- (NSUInteger)numberOfPagesInPageView:(MyPageView *)pageView {
    return self.numberOfImages;
}

- (UICollectionViewCell *)pageView:(MyPageView *)pageView cellForPageAtIndex:(NSUInteger)pageIndex
{
    MyScanImageCell * cell = [pageView dequeueReusableCellWithReuseIdentifier:defaultReuseDef forPageIndex:pageIndex];
    cell.delegate = self;
    
    //更新安全区
    [cell updateWithSafeAreaInsets:[self _safeAreaInsetsBaseOrientation]];
    
    //显示图片
    [cell displayImage:[self _imageDataAtIndex:pageIndex]];
    
    return cell;
}

- (void)pageView:(MyPageView *)pageView didDisplayPageAtIndex:(NSUInteger)pageIndex
{
    if (!self.isScanning) {
        return;
    }
    
    _currentDispalyImageIndex = pageIndex;
    id<MyScanImageViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(scanImageView:didDisplayImageAtIndex:)) {
        [delegate scanImageView:self didDisplayImageAtIndex:_currentDispalyImageIndex];
    }
    
    //通知改变显示的图片
    [_overlayView didChangeDisplayImage];
    
    //更新显示状态
    [self _updateImageDisplayState];
    
    //更新索引指示视图的值
    [self _updateIndexIndicaterValue];
}

#pragma mark -

- (void)endScanImageWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    if (self.isScanning) {
        
        //完成时调用的block
        void (^_completedBlock)(void) = ^ {
            
            //初始化数据
            _dataSource = nil;
            _imageDisplayState = MyScanImageDisplayStateNone;
            _currentDispalyImageIndex = NSNotFound;
            _numberOfImages = 0;
            
            
            //移除背景视图
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
        
            //移除pageView
            [self.pageView removeFromSuperview];
            self.pageView = nil;
            
            
            //移除索引指示视图
            if (self.indexIndicaterLabel) {
                [self.indexIndicaterLabel removeFromSuperview];
                self.indexIndicaterLabel = nil;
            }
            
            //移除overlay视图
            if (self.overlayView) {
                self.overlayView.alpha = 1.f;
                [self.overlayView removeFromSuperview];
            }
            
            //移除window
            self.s_window.hidden = YES;
            self.s_window = nil;
            
            if (completedBlock) {
                completedBlock();
            }
        };
        
        _scanning = NO;
        self.indexIndicaterLabel.alpha = 0.f;
        self.overlayView.alpha = 0.f;
        
        if (animated) {
            
            //将视图定位到当前显示的page，防止移动到一半时调用结束浏览
            [self.pageView setDispalyPageIndex:self.currentDispalyImageIndex];
            
            //获取当前显示的图像数据
            MyScanImageCell * cell = [self.pageView cellForPageAtIndex:self.currentDispalyImageIndex];
            MyScanImageData * imageData = cell.scanImageData;
            
            //图片显示的位置
            CGRect imageDisplayFrame = [self convertRect:cell.imageView.bounds fromView:cell.imageView];
            
            //缩略图位置
            CGRect thumbShowFrame =  imageData.thumbShowFrame;
            if (CGRectEqualToRect(thumbShowFrame, CGRectZero)) { //无缩略图位置，显示简单动画
                
                //动画frame
                UIImageView * imageView = [self _createImageForAnimatedWithSourceImageView:cell.imageView];
                
                //将图片的锚点定位到视图中点防止缩小时偏移
                imageView.frame = imageDisplayFrame;
                CGPoint center = [imageView convertPoint:CenterForRect(self.bounds) fromView:self];
                imageView.layer.anchorPoint = CGPointMake(center.x / CGRectGetWidth(imageDisplayFrame),
                                                          center.y / CGRectGetHeight(imageDisplayFrame));
                imageView.frame = imageDisplayFrame;
                
                
                //动画时不允许交互
                self.userInteractionEnabled = NO;
                self.pageView.hidden = YES;
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.backgroundView.alpha = 0.f;
                    [self _setOrientation:UIInterfaceOrientationPortrait];
                    
                    imageView.transform =  CGAffineTransformMakeScale(0.8f, 0.8f);
                    imageView.alpha = 0.f;
                    
                } completion:^(BOOL finished) {
                    
                    [imageView removeFromSuperview];
                    self.userInteractionEnabled = YES;
                    
                    _completedBlock();
                }];

            }else {
                
                BOOL isLongImage = cell.isDisplayLongImage;
                
                //创建动画用的图片视图并设置位置
                UIImageView * imageView = [self _createImageForAnimatedWithSourceImageView:cell.imageView];
                imageView.frame = imageDisplayFrame;
                
                //缩放后的缩略图大小
                CGSize scaledThumbSize = sizeZoomToTagetSize(thumbShowFrame.size, imageDisplayFrame.size, MyZoomModeAspectFit);
                
                //缩放比例
                CGFloat scale = CGRectGetWidth(thumbShowFrame) / scaledThumbSize.width;
                
                //缩放后的大小不等于显示大小或者原图有角度信息，即需要裁减动画
                if (fabs(scaledThumbSize.width / scaledThumbSize.height - CGRectGetWidth(imageDisplayFrame) / CGRectGetHeight(imageDisplayFrame)) > 0.01f || imageData.thumbShowCornerRadius > 0.f) {
                
                    CALayer * maskLayer = [[CALayer alloc] init];
                    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
                    maskLayer.bounds = CGRectMake(0.f, 0.f, scaledThumbSize.width, scaledThumbSize.height);
                    maskLayer.position = CenterForRect(imageView.bounds);
                    if (imageData.thumbShowCornerRadius > 0.f) {
                        maskLayer.cornerRadius = imageData.thumbShowCornerRadius / scale;
                    }
                    imageView.layer.mask = maskLayer;
                    
                    if (!isLongImage) {
                        
                        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                        animation.duration = 0.35;
                        animation.fromValue = [NSValue valueWithCGRect:imageView.bounds];
                        [maskLayer addAnimation:animation forKey:nil];
                        
                        if (imageData.thumbShowCornerRadius > 0.f) {
                            animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                            animation.duration = 0.35;
                            animation.fromValue = @(0.f);
                            [maskLayer addAnimation:animation forKey:nil];
                        }
                    }
                }
                
                //背景动画
                [UIView animateWithDuration:0.3 animations:^{
                    self.backgroundView.alpha = 0.f;
                }];
                
                
                self.userInteractionEnabled = NO;
                self.pageView.hidden = YES;
                
                if (isLongImage) {
                    imageView.center = CenterForRect(self.bounds);
                }

                [UIView animateWithDuration:0.5
                                      delay:0.0
                     usingSpringWithDamping:1.5f
                      initialSpringVelocity:0.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     [self _setOrientation:UIInterfaceOrientationPortrait];
                                     
                                     //缩放和移动
                                     imageView.transform = CGAffineTransformMakeScale(scale, scale);
                                     imageView.center =  CenterForRect(thumbShowFrame);
                                     
                                     
                                 } completion:^(BOOL finished) {
                                     
                                     [imageView removeFromSuperview];
                                     self.userInteractionEnabled = YES;
                                     
                                     _completedBlock();
                                 }];
            }
            
        }else {
            _completedBlock();
        }
        
        //更新注册设备方向改变通知
        [self _updateRegisterDeviceOrientationDidChangeNotification];
        
        //结束浏览
        id<MyScanImageViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(scanImageViewDidEndScan:)) {
            [delegate scanImageViewDidEndScan:self];
        }
    }
}

#pragma mark -

- (BOOL)_isCurrentDispalyImageCell:(MyScanImageCell *)cell {
    return self.isScanning && [self.pageView indexForPageCell:cell] == self.currentDispalyImageIndex;
}

- (void)scanImageCellDidTapHide:(MyScanImageCell *)cell
{
    if ([self _isCurrentDispalyImageCell:cell]) {
        
        BOOL bRet = YES;
        id<MyScanImageViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(scanImageViewShouldEndScan:)) {
            bRet = [delegate scanImageViewShouldEndScan:self];
        }
        
        if (bRet) {
            [self endScanImageWithAnimated:YES completedBlock:nil];
        }
    }
}

- (void)scanImageCellDidChangeImageDisplayState:(MyScanImageCell *)cell
{
    if ([self _isCurrentDispalyImageCell:cell]) { //如果是当前显示的图片
        [self _changeImageDisplayState:cell.imageDisplayState];
    }
}

- (void)_updateImageDisplayState
{
    MyScanImageCell * cell = [self.pageView cellForPageAtIndex:self.currentDispalyImageIndex];
    [self _changeImageDisplayState:cell.imageDisplayState];
}

- (void)_changeImageDisplayState:(MyScanImageDisplayState)imageDisplayState
{
    if (_imageDisplayState != imageDisplayState) {
        
        MyScanImageDisplayState fromState = _imageDisplayState;
        _imageDisplayState = imageDisplayState;
        
        //通知代理
        id<MyScanImageViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(scanImageView:imageDisplayStateDidChangeFromState:)) {
            [delegate scanImageView:self imageDisplayStateDidChangeFromState:fromState];
        }
    }
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.canLongPerssSaveImageToPhotosAlbum && self.isScanning && (self.imageDisplayState == MyScanImageDisplayStateThumb || self.imageDisplayState == MyScanImageDisplayStateSource);
}

- (void)_longPressGestureRecognizerHandle:(UIGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIActionSheet * actionSheet = [UIActionSheet actionViewWithCallBackBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex != actionSheet.cancelButtonIndex) {
                [self saveImageToPhotosAlbum];
            }
        }
                                                                           title:nil
                                                               cancelButtonTitle:@"取消"
                                                          destructiveButtonTitle:nil
                                                               otherButtonTitles:@"保存到相册", nil];
        [actionSheet showInView:self];
    }
}

- (BOOL)saveImageToPhotosAlbum
{
    if (self.isScanning) {
        
        MyScanImageCell * cell = [self.pageView cellForPageAtIndex:self.currentDispalyImageIndex];
        UIImage * displayingImage = cell.displayingImage;
        if (displayingImage != nil) {
            
            //开始保存到相册
            MBProgressHUD * activityIndicatorView = showHUDWithMyActivityIndicatorView(self.window, nil, @"保存中...");
            UIImageWriteToSavedPhotosAlbum(displayingImage, self, @selector(image:didFinishSavingWithError:contextInfo:), ((__bridge void *)activityIndicatorView));
            
            return YES;
        }
    }
    
    return NO;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MBProgressHUD * activityIndicatorView = (__bridge id)contextInfo;
    activityIndicatorView.completionBlock = ^{
        if (error) {
            showErrorMessage(self, nil, @"保存失败");
        }else{
            showSuccessMessage(self, @"保存成功", nil);
        }
    };
    [activityIndicatorView hide:YES];
}

#pragma mark -

- (void)_updateRegisterDeviceOrientationDidChangeNotification
{
    if (self.isScanning) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_deviceOrientationDidChangeNotification:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIInterfaceOrientation)_currentDeviceOrientation
{
    UIInterfaceOrientation deviceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if ((UIInterfaceOrientationMaskAllButUpsideDown & (1 << deviceOrientation))) {
        return deviceOrientation;
    }else {
        return UIInterfaceOrientationUnknown;
    }
}

- (void)_deviceOrientationDidChangeNotification:(NSNotification *)notification
{
    UIInterfaceOrientation targetOrientation = [self _currentDeviceOrientation];
    if (targetOrientation != UIInterfaceOrientationUnknown && self.orientation != targetOrientation) {
        
        BOOL bRet = YES;
        id<MyScanImageViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(scanImageView:shouldRotateToOrientation:)) {
            bRet = [delegate scanImageView:self shouldRotateToOrientation:targetOrientation];
        }
        
        if (!bRet) {
            return;
        }
        
        //旋转动画的时间,两个横屏模式之间的切换需要两倍时间
        NSTimeInterval animatedDuration = (!UIInterfaceOrientationIsLandscape(self.orientation) || !UIInterfaceOrientationIsLandscape(targetOrientation)) ? 0.4 : 0.8;
  
        [UIView animateWithDuration:animatedDuration
                         animations:^{
                             
                             [self _setOrientation:targetOrientation];
                             [self _updateIndexIndicaterFrame];
                             [self _updateOverlayViewFrame];
                         }
                         completion:nil];
    }
}

- (void)_setOrientation:(UIInterfaceOrientation)orientation
{
    if (_orientation != orientation) {
        _orientation = orientation;
        
        //设置选择变换
        self.transform = rotationAffineTransformForOrientation(orientation);
        
        //设置位置
        CGRect bounds = self.superview.bounds;
        self.bounds = UIInterfaceOrientationIsLandscape(orientation) ? CGRectMake(0, 0,CGRectGetHeight(bounds),CGRectGetWidth( bounds)) : bounds;
        
    }
}

- (UIEdgeInsets)_safeAreaInsetsBaseOrientation
{
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = self.safeAreaInsets;
        if (safeAreaInsets.top <= StatusBarHeight) {
            return UIEdgeInsetsZero;
        }else {
            return [self _safeAreaInsets:safeAreaInsets baseOrientation:self.orientation];
        }
    } else {
        return UIEdgeInsetsZero;
    }
}

- (UIEdgeInsets)_safeAreaInsets:(UIEdgeInsets)safeAreaInsets baseOrientation:(UIInterfaceOrientation)orientation
{
    //旋转安全区
    UIEdgeInsets tempSafeAreaInsets = safeAreaInsets;
    
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        
        tempSafeAreaInsets.left = safeAreaInsets.top;
        tempSafeAreaInsets.bottom = safeAreaInsets.left;
        tempSafeAreaInsets.right = safeAreaInsets.bottom;
        tempSafeAreaInsets.top = safeAreaInsets.right;
        
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        
        tempSafeAreaInsets.right = safeAreaInsets.top;
        tempSafeAreaInsets.bottom = safeAreaInsets.right;
        tempSafeAreaInsets.left = safeAreaInsets.top;
        tempSafeAreaInsets.top = safeAreaInsets.left;
        
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        tempSafeAreaInsets.right = safeAreaInsets.left;
        tempSafeAreaInsets.bottom = safeAreaInsets.top;
        tempSafeAreaInsets.left = safeAreaInsets.right;
        tempSafeAreaInsets.top = safeAreaInsets.bottom;
    }
    
    return tempSafeAreaInsets;
}

@end

//----------------------------------------

@implementation UIView (MyScanImageOverlayView)

- (MyScanImageView *)scanImageView
{
    if ([self isKindOfClass:[MyScanImageView class]]) {
        return (id)self;
    }else {
        return self.superview.scanImageView;
    }
}

- (CGRect)frameThatFitForScanImageOverlayView:(CGRect)bounds safeAreaInsets:(UIEdgeInsets)safeAreaInsets {
    return CGRectZero;
}

- (void)overlayViewFrameInvalidate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MyScanImageOverlayViewFrameDidInvalidateNotification
                                                        object:self];
}

- (void)didChangeDisplayImage {
    //do nothing
}

@end
