//
//  UIImageView+URL.m
//
//
//  Created by LeslieChen on 14-1-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "UIImageView+URL.h"
#import "MBProgressHUD.h"
#import "UIImage+URL.h"
#import  <objc/runtime.h>

//----------------------------------------------------------

@interface MyImageLoadConfiguration()

//可以重新加载图像
- (BOOL)canAutoReloadImage;

@end

//----------------------------------------------------------


@implementation MyImageLoadConfiguration
{
    //重新加载的次数
    NSUInteger _authReloadTimes;
}

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(ImageViewLoadImageSuccessBlock)success
               failure:(ImageViewLoadImageFailureBlock)failure
{
    
    self = [super init];
    
    if (self) {
        _url              = [url copy];
        _placeholderImage = placeholderImage;
        _progressViewMode = progressViewMode;
        _loadFailPolicy   = loadFailPolicy;
        _downLoadPolicy   = policy;
        _downLoadManager  = manager;
        
        //赋值给成员变量时不需要显示copy
        _successBlock     = success;
        _failureBlock     = failure;
    }
    
    return self;
}

- (BOOL)canAutoReloadImage {
    return  (++ _authReloadTimes <= 3);
}

@end

//----------------------------------------------------------

@interface _ImageLoadingIndicateView : MyLoadingIndicateView

@end

//----------------------------------------------------------

@implementation _ImageLoadingIndicateView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat sizeStandards = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    if (sizeStandards >= 150.f) {
        
        self.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 40.f, 40.f);
        self.activityIndicatorView.lineWidth = 1.5f;
        self.topMargin = 10.f;
        self.titleLabelFont = [UIFont boldSystemFontOfSize:16.f];
        
    }else if(sizeStandards >= 50.f){
        
        self.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 30.f, 30.f);
        self.activityIndicatorView.lineWidth = 1.f;
        self.topMargin = 5.f;
        self.titleLabelFont = [UIFont boldSystemFontOfSize:8.f];
        
    }else{
        
        self.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 20.f, 20.f);
        self.activityIndicatorView.lineWidth = 1.f;
        self.topMargin = 2.f;
        self.titleLabelFont = [UIFont boldSystemFontOfSize:5.f];
    }
}


@end

//----------------------------------------------------------

//图片加载配置的key
static char ImageLoadConfigurationKey;

//----------------------------------------------------------

@interface UIImageView(_URL) <MyLoadingIndicateViewDelegate>

//图片加载配置
@property(nonatomic,strong) MyImageLoadConfiguration * imageLoadConfiguration;

//图片下载管理器
@property(nonatomic,strong,readonly) MyImageDownLoadManager *imageDownLoadManager;

//加载指示视图
@property(nonatomic,strong,readonly) MyLoadingIndicateView * loadingIndicateView;

@end

//----------------------------------------------------------

@implementation UIImageView (URL)

#pragma mark -

- (void)setImageLoadConfiguration:(MyImageLoadConfiguration *)imageLoadConfiguration
{
    MyImageLoadConfiguration * _imageLoadConfiguration = self.imageLoadConfiguration;
    if (_imageLoadConfiguration) {
        
        //获取关联的加载视图
         MyLoadingIndicateView * loadingIndicateView = objc_getAssociatedObject(self, (__bridge const void *)(_imageLoadConfiguration));
        
        if (loadingIndicateView) {
            
            //移除关联的加载视图
            [loadingIndicateView removeFromSuperview];
            objc_setAssociatedObject(self, (__bridge const void *)(_imageLoadConfiguration), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    //设置
    objc_setAssociatedObject(self, &ImageLoadConfigurationKey, imageLoadConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (MyImageLoadConfiguration *)imageLoadConfiguration {
    return objc_getAssociatedObject(self, &ImageLoadConfigurationKey);
}

- (MyImageDownLoadManager *)imageDownLoadManager {
    return self.imageLoadConfiguration.downLoadManager ?: [MyImageDownLoadManager shareImageDownLoadManager];
}

#pragma mark -

- (MyLoadingIndicateView *)loadingIndicateView
{
    MyImageLoadConfiguration * _imageLoadConfiguration = self.imageLoadConfiguration;
    if (_imageLoadConfiguration) {
        
        //获取关联的加载视图
        MyLoadingIndicateView * loadingIndicateView = objc_getAssociatedObject(self, (__bridge const void *)(_imageLoadConfiguration));
        
        //初始化
        if (!loadingIndicateView) {
            
            loadingIndicateView = [[_ImageLoadingIndicateView alloc] initWithFrame:self.bounds];
            loadingIndicateView.marginScale = UIEdgeInsetsMake(0.15f, 0.15f, 0.15f, 0.15f);
            loadingIndicateView.delegate = self;
            loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [self addSubview:loadingIndicateView];
            
            //添加关联
            objc_setAssociatedObject(self, (__bridge const void *)(_imageLoadConfiguration), loadingIndicateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        return loadingIndicateView;
    }
    
    return nil;
}


- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    [loadingIndicateView hiddenView];
    [self _startDownloadImage];
}

- (void)loadingIndicateViewDidShow:(MyLoadingIndicateView *)loadingIndicateView
{
    if ((loadingIndicateView.contextTag == NoNetworkContextTag &&
        !(self.imageLoadConfiguration.loadFailPolicy & MyImageLoadFailPolicyShowNoNetIndicate)) ||
        loadingIndicateView.contextTag == LoadingContextTag) {
        loadingIndicateView.userInteractionEnabled = NO;
    }else {
        loadingIndicateView.userInteractionEnabled = YES;
    }
}


#pragma mark -

//init
//----------------------------------------------------------

- (id)initWithImageURL:(NSString *)url
{
    return [self initWithImageURL:url
                 placeholderImage:nil
                 progressViewMode:MyImageLoadProgressViewModeNone
                   loadFailPolicy:MyImageLoadFailPolicyDefault
                   downLoadPolicy:MyImageDownLoadPolicyDefault
             imageDownLoadManager:nil
                          success:nil
                          failure:nil];
}

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    return [self initWithImageURL:url
                 placeholderImage:placeholderImage
                 progressViewMode:progressViewMode
                   loadFailPolicy:loadFailPolicy
                   downLoadPolicy:policy
             imageDownLoadManager:nil
                          success:nil
                          failure:nil];
}

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy
               success:(ImageViewLoadImageSuccessBlock)success
               failure:(ImageViewLoadImageFailureBlock)failure
{
    return [self initWithImageURL:url
                 placeholderImage:placeholderImage
                 progressViewMode:progressViewMode
                   loadFailPolicy:loadFailPolicy
                   downLoadPolicy:policy
             imageDownLoadManager:nil
                          success:success
                          failure:failure];
}


- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy) policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(ImageViewLoadImageSuccessBlock)success
               failure:(ImageViewLoadImageFailureBlock)failure
{
    self = [self initWithImage:placeholderImage highlightedImage:nil];
    
    if (self) {
        
        //设置
        [self setImageWithURL:url
             placeholderImage:placeholderImage
             progressViewMode:progressViewMode
               loadFailPolicy:loadFailPolicy
               downLoadPolicy:policy
         imageDownLoadManager:manager
                      success:success
                      failure:failure];
    }
    
    return self;
}

- (id)initWithConfiguration:(MyImageLoadConfiguration *)configuration
{
    self = [self initWithImage:configuration.placeholderImage highlightedImage:nil];
    
    if (self) {
        [self setImageWithConfiguration:configuration];
    }
    
    return self;
    
}


//setImage
//----------------------------------------------------------

- (void)setImageWithURL:(NSString *)url
{
    [self setImageWithURL:url
         placeholderImage:nil
         progressViewMode:MyImageLoadProgressViewModeNone
           loadFailPolicy:MyImageLoadFailPolicyDefault
           downLoadPolicy:MyImageDownLoadPolicyDefault
     imageDownLoadManager:nil
                  success:nil
                  failure:nil];
}

- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    [self setImageWithURL:url
         placeholderImage:placeholderImage
         progressViewMode:progressViewMode
           loadFailPolicy:loadFailPolicy
           downLoadPolicy:policy
     imageDownLoadManager:nil
                  success:nil
                  failure:nil];
}

- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(MyImageDownLoadPolicy)policy
                success:(ImageViewLoadImageSuccessBlock)success
                failure:(ImageViewLoadImageFailureBlock)failure
{
    [self setImageWithURL:url
         placeholderImage:placeholderImage
         progressViewMode:progressViewMode
           loadFailPolicy:loadFailPolicy
           downLoadPolicy:policy
     imageDownLoadManager:nil
                  success:success
                  failure:failure];
}

- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(MyImageDownLoadPolicy)policy
   imageDownLoadManager:(MyImageDownLoadManager *)manager
                success:(ImageViewLoadImageSuccessBlock)success
                failure:(ImageViewLoadImageFailureBlock)failure
{
    
    MyImageLoadConfiguration * configuration = [[MyImageLoadConfiguration alloc] initWithImageURL:url
                                                        placeholderImage:placeholderImage
                                                        progressViewMode:progressViewMode
                                                          loadFailPolicy:loadFailPolicy
                                                          downLoadPolicy:policy
                                                    imageDownLoadManager:manager
                                                                 success:success
                                                                 failure:failure];
    
    [self setImageWithConfiguration:configuration];
    
}

- (void)setImageWithConfiguration:(MyImageLoadConfiguration *)configuration
{
    //取消加载图片
    [self cancleLoadURLImage:NO];
    
     //当前显示的图片是即将要加载的图片则忽略
    if ((UseLocalCache(configuration.downLoadPolicy) && [self.image.imageURL isEqualToString:configuration.url])) {
        
        //发送成功通知
        ImageViewLoadImageSuccessBlock successBlock = configuration.successBlock;
        if (successBlock != nil) {
            successBlock(self, configuration.url, (MyImageDownLoadResultTypeCacheLoad | MyImageDownLoadResultTypeOuterCache));
        }
        
        return;
    }
    
    //设置配置
    [self setImageLoadConfiguration:configuration];
    
    //开始下载图片
    [self _startDownloadImage];
}

- (void)cancleLoadURLImage:(BOOL)cancleNetRequest
{
    [[self imageDownLoadManager] cancleDownLoadImage:self forceToCancle:cancleNetRequest];
    [self setImageLoadConfiguration:nil];
}

- (NSString *)loadingImageURL {
    return self.imageLoadConfiguration.url;
}

#pragma mark -

- (void)_startDownloadImage
{
    MyImageLoadConfiguration * configuration = self.imageLoadConfiguration;
    
    //设置placeholder
    self.image = configuration.placeholderImage;
    
    //设置加载视图
    if (configuration.progressViewMode != MyImageLoadProgressViewModeNone) {
        
        //显示加载指示视图
        self.loadingIndicateView.activityIndicatorView.style = configuration.progressViewMode == MyImageLoadProgressViewModeDeterminate ? MyActivityIndicatorViewStyleDeterminate : MyActivityIndicatorViewStyleIndeterminate;
        [self.loadingIndicateView showLoadingStatusWithTitle:nil detailText:nil];
    }
    
    //开始下载图片
    [[self imageDownLoadManager] startDownLoadImage:self
                                                URL:configuration.url
                                     downLoadPolicy:configuration.downLoadPolicy];
}

#pragma mark -


#define IsCurrentDownLoadCallBack(_manager,_url) \
({  \
    MyImageLoadConfiguration * configuration = self.imageLoadConfiguration;   \
    ((manager == [self imageDownLoadManager]) && ((url == configuration.url) || [configuration.url isEqualToString:url])); \
})


- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
                    imageURL:(NSString *)url
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed
{
    if (!IsCurrentDownLoadCallBack(manager, url)) { //不是当前的图片下载回调，则取消回调任务
        [manager cancleDownLoadImage:self URL:url forceToCancle:NO];
        return;
    }
    
    if (self.imageLoadConfiguration.progressViewMode != MyImageLoadProgressViewModeNone) {
        
        MyActivityIndicatorView  * progressView = self.loadingIndicateView.activityIndicatorView;
        
        if (progressView && progressView.style == MyActivityIndicatorViewStyleDeterminate) {
            
            if (expectedDataLength != NSURLResponseUnknownLength) { //设置进度
                [progressView setProgress:(float)receiveDataLength/expectedDataLength];
            }else{
                [progressView setStyle:MyActivityIndicatorViewStyleIndeterminate];
                [progressView startAnimating];
            }
        }
    }
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
        downloadFailedForURL:(NSString *)url
                       error:(NSError *)error
{
    //核对是否为当前下载的回调
    if (IsCurrentDownLoadCallBack(manager, url)) {
        
        MyImageLoadConfiguration * configuration = self.imageLoadConfiguration;

        //网络不可用错误且策略允许
        if (IS_SPECIFIC_ERROR(error, ImageDownLoadErrorDomain, ImageDownLoadErrorCodeNetUnavailable) &&
            (configuration.loadFailPolicy & MyImageLoadFailPolicyAutoReloadWhenNoNet)) {
            
            //显示无网络指示
            if (configuration.loadFailPolicy & MyImageLoadFailPolicyShowNoNetIndicate) {
                
                self.image = nil;
                [self.loadingIndicateView showNoNetworkStatusWithImage:ImageWithName(@"error_no_network.png")
                                                                 title:@"检查网络设置"
                                                            detailText:nil
                                                 observerNetworkChange:YES];
                
            }else{
                
                [self.loadingIndicateView showNoNetworkStatusWithImage:nil
                                                                 title:nil
                                                            detailText:nil
                                                 observerNetworkChange:YES];
            }
            
        }else {
            
            BOOL needSendMessage = YES;
            
            ImageViewLoadImageFailureBlock failure = configuration.failureBlock;
            
            //不是URL无效错误
            if (!IS_DOMAIN_ERROR(error,ImageDownLoadErrorDomain) ||
                (error.code != ImageDownLoadErrorCodeURLInvalid &&
                 error.code != ImageDownLoadErrorCodeFileURLInvalid)) {
                    
                //手动重新加载
                if(configuration.loadFailPolicy & MyImageLoadFailPolicyManualReloadWhenFail) {
                    
                    self.userInteractionEnabled = YES;
                    self.image = nil;
                    
                    //显示点击重新加载指示视图
                    [self.loadingIndicateView showLoadingErrorStatusWithImage:ImageWithName(@"error_tap_reload.png")
                                                                            title:@"点击重新加载"
                                                                       detailText:nil];
                    
                }else if ((configuration.loadFailPolicy & MyImageLoadFailPolicyAutoReloadWhenFail)
                          && [configuration canAutoReloadImage] ) { //自动重新加载
                    [self _startDownloadImage];
                    
                    needSendMessage = NO;
                    
                }else {
                    [self setImageLoadConfiguration:nil];
                }
                    
            }else {
                [self setImageLoadConfiguration:nil];
            }
            
            if (needSendMessage) { //发送代理方法
                if (failure) failure(self,url,error);
            }
        }
    }
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
       downloadSucceedForURL:(NSString *)url
                       image:(UIImage *)image
                  resultType:(MyImageDownLoadResultType)resultType
{
    if (IsCurrentDownLoadCallBack(manager, url)) {
        
        self.image = image;
        
        //关联URL
        [image associateWithURL:url];
        
        //回调
        ImageViewLoadImageSuccessBlock success = [self imageLoadConfiguration].successBlock;
        if (success) success(self,url,resultType);
        
        
       [self setImageLoadConfiguration:nil];
    }
}

//----------------------------------------------------------

- (void)defaultShowImageWithURL:(NSString *)url
               placeholderImage:(UIImage *)placeholderImage
               progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
                 loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
                 downLoadPolicy:(MyImageDownLoadPolicy)policy
                        success:(ImageViewLoadImageSuccessBlock)success
                        failure:(ImageViewLoadImageFailureBlock)failure
{
    [self defaultShowImageWithURL:url
                 placeholderImage:placeholderImage
                 progressViewMode:progressViewMode
                   loadFailPolicy:loadFailPolicy
                   downLoadPolicy:policy
           aniamtedWhenShowIfNeed:YES
                          success:success
                          failure:failure];
}

- (void)defaultShowImageWithURL:(NSString *)url
               placeholderImage:(UIImage *)placeholderImage
               progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
                 loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
                 downLoadPolicy:(MyImageDownLoadPolicy)policy
         aniamtedWhenShowIfNeed:(BOOL)aniamtedWhenShowIfNeed
                        success:(ImageViewLoadImageSuccessBlock)success
                        failure:(ImageViewLoadImageFailureBlock)failure
{
    //记录开始时间戳
    NSDate * startDate = aniamtedWhenShowIfNeed ? [NSDate date] : nil;
    
    [self setImageWithURL:url
         placeholderImage:placeholderImage
         progressViewMode:progressViewMode
           loadFailPolicy:loadFailPolicy
           downLoadPolicy:policy
                  success:^(UIImageView * imageView, NSString * url, MyImageDownLoadResultType resultType) {
                      
                      if (aniamtedWhenShowIfNeed) {
                          
                         //网络加载一定需要过渡
                          BOOL needTransition =  (resultType & MyImageDownLoadResultTypeNetLoad);
                          
                          if (!needTransition) {
                              
                              //异步加载
                              if (resultType & MyImageDownLoadResultTypeAsyncLoad) {
                                  
                                  //计算加载用的间隔
                                  NSTimeInterval timeInterval = fabs([[NSDate date] timeIntervalSinceDate: startDate]);
                                  //时间大于人眼分辨的最短时间和小于一个时间，防止闪屏，需要过渡动画
                                  if (timeInterval >= 0.04f && timeInterval < 1.f) {
                                      needTransition = YES;
                                  }
                              }
                          }
                      
                          //过渡动画
                          if (needTransition) {
                              CATransition * animation = [CATransition animation];
                              [animation setDuration:1.f];
                              [imageView.layer addAnimation:animation forKey:nil];
                          }
                      }
                      
                      if (success) {
                          success(imageView, url, resultType);
                      }
                      
                  } failure:failure];
}


@end
