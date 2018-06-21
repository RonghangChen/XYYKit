//
//  ImageDownLoadManager.h
//
//
//  Created by LeslieChen on 14-1-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageCachePool.h"

//----------------------------------------------------------

//错误域
#define ImageDownLoadErrorDomain  @"ImageDownLoadErrorDomin"

//url无效
#define ImageDownLoadErrorCodeURLInvalid                 990
//文件URL无效,无相应的文件
#define ImageDownLoadErrorCodeFileURLInvalid             991
//网络不可用
#define ImageDownLoadErrorCodeNetUnavailable             992
//等待队列溢出
#define ImageDownLoadErrorCodeResultWattingQuenuOverflow 993
//结果数据无效，不能生成图片
#define ImageDownLoadErrorCodeResultDataInvalid          994


//错误userinfo，文件类型数据
#define ImageDownLoadErrorResultTypeUserInfoKey  @"ImageDownLoadErrorResultTypeUserInfoKey"

#define ImageDownLoadResultDataTypeForError(_error) \
    [[_error.userInfo objectForKey:ImageDownLoadErrorResultTypeUserInfoKey] integerValue]


//----------------------------------------------------------

//图片下载的策略
typedef  NS_OPTIONS(NSUInteger, MyImageDownLoadPolicy) {
    MyImageDownLoadPolicyNone           = 0,          //无策略
    MyImageDownLoadPolicyUseCache       = 1 << 0,     //使用缓存
    MyImageDownLoadPolicyCacheImage     = 1 << 1,     //图片下载结束后缓存图片
    MyImageDownLoadPolicyAsyncLoadCache = 1 << 2,     //异步加载缓存
    MyImageDownLoadPolicyAutoLoadCache  = 1 << 3,     //自动加载缓存策略，如果缓存在内存直接同步加载，否则异步加载，优先级高于异步加载
    
    //默认策略
    MyImageDownLoadPolicyDefault        = (MyImageDownLoadPolicyCacheImage |
                                           MyImageDownLoadPolicyUseCache |
                                           MyImageDownLoadPolicyAutoLoadCache),
    
};

//----------------------------------------------------------

#define UseLocalCache(_policy)     ((BOOL)((_policy) & MyImageDownLoadPolicyUseCache))
#define CacheImage(_policy)        ((BOOL)((_policy) & MyImageDownLoadPolicyCacheImage))
#define AsyncLoadCache(_policy)    ((BOOL)((_policy) & MyImageDownLoadPolicyAsyncLoadCache))
#define AutoLoadCache(_policy)     ((BOOL)((_policy) & MyImageDownLoadPolicyAutoLoadCache))

//----------------------------------------------------------

//图片下载的结果类型
typedef NS_OPTIONS(NSUInteger, MyImageDownLoadResultType) {
    MyImageDownLoadResultTypeNone        = 0,
    MyImageDownLoadResultTypeCacheLoad   = 1 << 0,  //缓存加载
    MyImageDownLoadResultTypeInsideCache = 1 << 1,  //是内部缓存
    MyImageDownLoadResultTypeOuterCache  = 1 << 2,  //是外部缓存
    MyImageDownLoadResultTypeFileCache   = 1 << 3,  //是文件缓存
    MyImageDownLoadResultTypeFileLoad    = 1 << 4,  //文件加载
    MyImageDownLoadResultTypeNetLoad     = 1 << 5,  //网络加载
    MyImageDownLoadResultTypeAsyncLoad   = 1 << 6   //异步加载
};


//----------------------------------------------------------

@class MyImageDownLoadManager;

//----------------------------------------------------------

@protocol MyImageDownLoadDelegate <NSObject>

@optional

/**
 * 下载图片过程回调的代理方法，可以通过其监听图片下载进度
 * @param manager manager为下载管理器
 * @param url url为图片URL
 * @param receiveDataLength receiveDataLength为收到的图片数据大小
 * @param expectedDataLength expectedDataLength为预期的图片数据大小
 * @param speed speed为当前下载速度
 */
- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
                    imageURL:(NSString *)url
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed;

/**
 * 下载图片成功回调的代理方法
 * @param manager manager为下载管理器
 * @param url url为图片URL
 * @param image image为下载后的图片
 * @param resultType resultType为结果类型，具体取值请见MyImageDownLoadResultType的定义
 */
- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
       downloadSucceedForURL:(NSString *)url
                       image:(UIImage *)image
                  resultType:(MyImageDownLoadResultType)resultType;


/**
 * 下载图片失败回调的代理方法
 * @param manager manager为下载管理器
 * @param url url为图片URL
 * @param error error为错误原因
 */
- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
        downloadFailedForURL:(NSString *)url
                       error:(NSError *)error;

@end

//----------------------------------------------------------

//图片下载结果回调的block

/**
 * 下载图片成功回调的block
 * @param url url为图片URL
 * @param image image为下载后的图片
 * @param resultType resultType为结果类型，具体取值请见MyImageDownLoadResultType的定义
 */
typedef void(^MyImageDownLoadSucceedBlock)(NSString * url, UIImage * image, MyImageDownLoadResultType resultType);

/**
 * 下载图片失败回调的block
 * @param url url为图片URL
 * @param error error为错误原因
 */
typedef void(^MyImageDownLoadFailedBlock)(NSString * url, NSError * error);

//----------------------------------------------------------

/**
 * 该类为图片下载管理器，使用它可以用来加载图片数据
 */
@interface MyImageDownLoadManager : NSObject


/**
 * 共享的管理器，非单例模式
 */
+ (instancetype)shareImageDownLoadManager;

/**
 * 通过ImageCachePool和并行下载数目初始化
 * @param imageCachePool  imageCachePool为图片缓存池，为nil则使用共享缓存池
 * @param concurrentCount concurrentCount为最大的并行下载数目，默认值会根据设备而不同,等于0会自动设置为15
 * @param waitingCount   waitingCount为等待下载任务最大数目，如果等待队列超过此数目则会取消下载任务并发送下载错误消
 *                         息，默认值会根据设备而不同
 */
- (id)initWithConcurrentCount:(NSUInteger)concurrentCount waitingCount:(NSUInteger)waitingCount;
- (id)initWithImageCachePool:(MyImageCachePool *)imageCachePool
             concurrentCount:(NSUInteger)concurrentCount
                waitingCount:(NSUInteger)waitingCount;


/**
 * 当前使用的图片缓存池
 */
@property(nonatomic,strong,readonly) MyImageCachePool *imageCachePool;

/**
 * 开始下载图片
 * @param delegate delegate为下载图片的代理,弱引用
 * @param url      url为图片URL，为nil则直接发送下载错误消息
 * @param policy   policy为下载策略
 */
- (void)startDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                       URL:(NSString *)url
            downLoadPolicy:(MyImageDownLoadPolicy)policy;

/**
 * 开始下载图片,blcok方式回调，该方法自动生成代理并开始下载图片，返回生成的代理
 * @param url          url为图片URL，为nil则直接发送下载错误消息
 * @param policy       policy为下载策略
 * @param succeedBlock succeedBlock为下载成功回调的block
 * @param failedBlock  failedBlock为下载失败回调的block
 * @return 返回为创建下载任务而创建的代理，该代理被下载管理器引用直到下载任务结束，可使用返回的代理取消相应的下载任务
 */
- (id<MyImageDownLoadDelegate>)startDownLoadImageWithURL:(NSString *)url
                                          downLoadPolicy:(MyImageDownLoadPolicy)policy
                                            succeedBlock:(MyImageDownLoadSucceedBlock)succeedBlock
                                             failedBlock:(MyImageDownLoadFailedBlock)failedBlock;

/**
 * 取消下载图片任务
 * @param delegate delegate为下载图片的代理,弱引用
 * @param url      url为图片URL，为nil则取消所有
 * @param force    force代表是否取消网络下载任务，为YES取消网络任务，为NO只是代理接收不到消息，还会下载图片
 */
- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate forceToCancle:(BOOL)force;
- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                        URL:(NSString *)url
              forceToCancle:(BOOL)force;


/**
 * 取消所有的图片下载任务
 */
- (void)cancleAllDownLoadImage;

@end

