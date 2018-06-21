//
//  UIImageView+URL.h
//
//
//  Created by LeslieChen on 14-1-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyImageDownLoadManager.h"

//----------------------------------------------------------

/** 图片加载过程视图的模式 */
typedef NS_ENUM(NSInteger,MyImageLoadProgressViewMode){
    /** 无加载过程视图 */
    MyImageLoadProgressViewModeNone,
    /** 无限加载过程视图 */
    MyImageLoadProgressViewModeIndeterminate,
    /** 进度加载过程视图 */
    MyImageLoadProgressViewModeDeterminate
};


typedef NS_OPTIONS(NSUInteger,MyImageLoadFailPolicy){
    MyImageLoadFailPolicyNone                   = 0,
    MyImageLoadFailPolicyAutoReloadWhenNoNet    = 1 << 0, //自动重新加载当网络连接恢复
    MyImageLoadFailPolicyShowNoNetIndicate      = 1 << 1, //显示无网络连接指示
    MyImageLoadFailPolicyManualReloadWhenFail   = 1 << 2, //手动重新加载当加载失败,优先级大于MyImageLoadFailPolicyAutoReloadWhenFail
    MyImageLoadFailPolicyAutoReloadWhenFail     = 1 << 3, //自动重新加载当加载失败
    
    
    //默认加载策略
    MyImageLoadFailPolicyDefault      =  MyImageLoadFailPolicyAutoReloadWhenNoNet |
                                         MyImageLoadFailPolicyShowNoNetIndicate   |
                                         MyImageLoadFailPolicyManualReloadWhenFail,
    
    MyImageLoadFailPolicyAutoReload   =  MyImageLoadFailPolicyAutoReloadWhenNoNet |
                                         MyImageLoadFailPolicyAutoReloadWhenFail,
    
    MyImageLoadFailPolicyManualReload =  MyImageLoadFailPolicyAutoReloadWhenNoNet |
                                         MyImageLoadFailPolicyManualReloadWhenFail
};

//----------------------------------------------------------

/**
 * 图片加载成功后回调的block
 * @param imageView imageView为加载图片的UIImageView实例,其image属性已设置为加载后的图片
 * @param url url为图片url
 * @param resultType resultType为结果类型，具体取值请见MyImageDownLoadResultType的定义
 */
typedef void(^ImageViewLoadImageSuccessBlock)(UIImageView * imageView,
                                              NSString * url,
                                              MyImageDownLoadResultType resultType);

/**
 * 图片加载失败后回调的block
 * @param imageView imageView为加载图片的UIImageView实例,其image属性为placeholder图片
 * @param url url为图片url
 * @param error error为错误原因
 */
typedef void(^ImageViewLoadImageFailureBlock)(UIImageView * imageView,
                                              NSString * url,
                                              NSError * error);

//----------------------------------------------------------


/**
 * 该分类为UIImageView为图片加载配置
 */
@interface MyImageLoadConfiguration : NSObject

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(ImageViewLoadImageSuccessBlock)success
               failure:(ImageViewLoadImageFailureBlock)failure;

@property(nonatomic,copy,readonly) NSString   * url;
@property(nonatomic,strong,readonly) UIImage    * placeholderImage;

@property(nonatomic,readonly)        MyImageLoadProgressViewMode progressViewMode;
@property(nonatomic,readonly)        MyImageLoadFailPolicy       loadFailPolicy;

@property(nonatomic,readonly)        MyImageDownLoadPolicy     downLoadPolicy;
@property(nonatomic,strong,readonly) MyImageDownLoadManager  * downLoadManager;


@property(nonatomic,copy,readonly)   ImageViewLoadImageSuccessBlock successBlock;
@property(nonatomic,copy,readonly)   ImageViewLoadImageFailureBlock failureBlock;

@end

//----------------------------------------------------------

/**
 * 该分类为UIImageView提供直接通过图片URL设置图片的方法
 */
@interface UIImageView (URL) <MyImageDownLoadDelegate>


/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url;

/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy;

/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy
               success:(ImageViewLoadImageSuccessBlock)success
               failure:(ImageViewLoadImageFailureBlock)failure;


/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(MyImageDownLoadPolicy)policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(ImageViewLoadImageSuccessBlock)success
               failure:(ImageViewLoadImageFailureBlock)failure;

/**
 * 通过图片加载配置初始化
 */
- (id)initWithConfiguration:(MyImageLoadConfiguration *)configuration;


/**
 * 通过图片URL设置image
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 */
- (void)setImageWithURL:(NSString *)url;

/**
 * 通过图片URL设置image
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 */
- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(MyImageDownLoadPolicy)policy;


/**
 * 通过图片URL设置image
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 */
- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(MyImageDownLoadPolicy)policy
                success:(ImageViewLoadImageSuccessBlock)success
                failure:(ImageViewLoadImageFailureBlock)failure;

/**
 * 通过图片URL设置image，采用缓存机制，所有参数会生成MyImageLoadConfiguration然后调用setImageWithConfiguration：
 * @param url url为图片url，可以是网络url和本地文件url
 * @param placeholderImage placeholderImage为图片加载前显示的图片
 * @param success success为加载成功后调用的block
 * @param failure failure为加载失败后调用的block
 * @param policy  policy为下载策略，默认为MyImageDownLoadPolicyDefault
 * @param manager manager为使用的图片下载管理器,使用自定义的图片管理器来实现更多缓存上的操作，传入nil使用共享的下载管理器
 * @param progressViewMode progressViewMode指示加载视图模式
 */
- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(MyImageDownLoadPolicy)policy
   imageDownLoadManager:(MyImageDownLoadManager *)manager
                success:(ImageViewLoadImageSuccessBlock)success
                failure:(ImageViewLoadImageFailureBlock)failure;

/**
 * 通过图片加载配置设置image
 */
- (void)setImageWithConfiguration:(MyImageLoadConfiguration *)configuration;

/**
 * 取消加载图片
 */
- (void)cancleLoadURLImage:(BOOL)cancleNetRequest;


/**
 * 返回正在加载的图片URL
 * @return 如果没有正在加载则返回nil
 */
- (NSString *)loadingImageURL;

//----------------------------------------------------------
//----------------------------------------------------------

//默认的显示图片方法
- (void)defaultShowImageWithURL:(NSString *)url
               placeholderImage:(UIImage *)placeholderImage
               progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
                 loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
                 downLoadPolicy:(MyImageDownLoadPolicy)policy
                        success:(ImageViewLoadImageSuccessBlock)success
                        failure:(ImageViewLoadImageFailureBlock)failure;

- (void)defaultShowImageWithURL:(NSString *)url
               placeholderImage:(UIImage *)placeholderImage
               progressViewMode:(MyImageLoadProgressViewMode)progressViewMode
                 loadFailPolicy:(MyImageLoadFailPolicy)loadFailPolicy
                 downLoadPolicy:(MyImageDownLoadPolicy)policy
         aniamtedWhenShowIfNeed:(BOOL)aniamtedWhenShowIfNeed
                        success:(ImageViewLoadImageSuccessBlock)success
                        failure:(ImageViewLoadImageFailureBlock)failure;


@end
