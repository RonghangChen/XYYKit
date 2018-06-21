//
//  ImageDownLoadManager.m
//
//
//  Created by LeslieChen on 14-1-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageDownLoadManager.h"
#import "XYYNetConnection.h"

//----------------------------------------------------------

@interface _ImageDownLoadTask : NSObject

- (id)initWithImageURL:(NSString *)URL
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(MyImageDownLoadPolicy)policy;


@property(nonatomic,copy,readonly) NSString *imageURL;
@property(nonatomic,strong,readonly) MyHTTPRequest * httpRequest;
@property(nonatomic,strong,readonly) NSMutableSet<MyWeakDelegate<id<MyImageDownLoadDelegate>> *> *delegateSet;

//缓存策略
@property(nonatomic,readonly) MyImageDownLoadPolicy policy;

//添加回调代理
- (void)addCallbackDelegate:(id<MyImageDownLoadDelegate>)delegate downLoadPolicy:(MyImageDownLoadPolicy)policy;

//合并下载任务
- (void)unionTask:(_ImageDownLoadTask *)task;

//移除无效的代理（被释放）
- (void)removeInvaidDelegate;

@end

//----------------------------------------------------------

@interface _MyImageLoadCacheTask : NSObject

- (id)initWithDelegate:(id<MyImageDownLoadDelegate>)delegate imageURL:(NSString *)imageURL;

@property(nonatomic,strong,readonly) MyWeakDelegate<id<MyImageDownLoadDelegate>> * delegate;
@property(nonatomic,copy,readonly) NSString * imageURL;

@end

//----------------------------------------------------------

@class _ImageDownLoadTaskWaitingPool;
@protocol _ImageDownLoadWaitingPoolDelegate

//等待池已经移除下载任务，由于数目太多
- (void)imageDownLoadWaitingPool:(_ImageDownLoadTaskWaitingPool *)waitingPool
                   didRemoveTask:(_ImageDownLoadTask *)imageDownLoadTask;

@end

//----------------------------------------------------------

//图片下载等待池
@interface _ImageDownLoadTaskWaitingPool : NSObject

- (id)initWithWaitingCount:(NSUInteger)waitingCount;

- (void)addTaskWithURL:(NSString *)url
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(MyImageDownLoadPolicy)policy;

- (_ImageDownLoadTask *)nextImageDownLoadTask;

//移除
- (void)removeTaskWithURL:(NSString *)url
                 delegate:(id<MyImageDownLoadDelegate>)delegate
              forceCancle:(BOOL)forceCancle;
//清空
- (void)clearWaitingPool;


@property(nonatomic,weak) id<_ImageDownLoadWaitingPoolDelegate> delegate;

@end


//----------------------------------------------------------

@interface _MyImageDownLoadDelegateForBlock : NSObject <MyImageDownLoadDelegate>

+ (instancetype)createDelegateForImageDownLoadManager:(MyImageDownLoadManager *)manager
                                         succeedBlock:(MyImageDownLoadSucceedBlock)succeedBlock
                                          failedBlock:(MyImageDownLoadFailedBlock)failedBlock;

- (id)initWithSucceedBlock:(MyImageDownLoadSucceedBlock)succeedBlock
               failedBlock:(MyImageDownLoadFailedBlock)failedBlock;

@property(nonatomic,copy,readonly) MyImageDownLoadSucceedBlock succeedBlock;
@property(nonatomic,copy,readonly) MyImageDownLoadFailedBlock failedBlock;

@end

//----------------------------------------------------------

@interface MyImageDownLoadManager () <MyHTTPRequestDelegate,_ImageDownLoadWaitingPoolDelegate>


@property(nonatomic,strong,readonly) NSMutableSet * blockDelegateSet;

@end


//----------------------------------------------------------

@implementation MyImageDownLoadManager
{
    //同时下载的最大容量
    NSUInteger           _concurrentCount;
    
    //URL到数据的映射表
    NSMutableDictionary *_URLToTaskMap;
    //代理到数据的映射表
    NSMutableDictionary *_delegateToTasksMap;
    //URL连接管理到数据的映射表
    NSMutableDictionary *_httpRequestToTaskMap;
    
    //等待池
    _ImageDownLoadTaskWaitingPool   * _waitingPool;
    
    //正在加载缓存的任务列表
    NSMutableDictionary * _delegateToLoadCacheTasksMap;
}

@synthesize imageCachePool = _imageCachePool;
@synthesize blockDelegateSet = _blockDelegateSet;

#pragma mark -

+ (instancetype)shareImageDownLoadManager
{
    static MyImageDownLoadManager * _shareImageDownLoadManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareImageDownLoadManager = [[MyImageDownLoadManager alloc] init];
    });
    
    return _shareImageDownLoadManager;
}

- (id)init
{
    NSUInteger concurrentCount;
    MyScreenSizeType screenSizeType = mainScreenType();
    if (screenSizeType <= MyScreenSizeTypeSmall) {
        concurrentCount = 15;
    }else if (screenSizeType <= MyScreenSizeTypeMiddle) {
        concurrentCount = 20;
    }else {
        concurrentCount = 25;
    }
    
    return [self initWithImageCachePool:nil concurrentCount:concurrentCount waitingCount:3 * concurrentCount];
}

- (id)initWithConcurrentCount:(NSUInteger)concurrentCount waitingCount:(NSUInteger)waitingCount {
    return [self initWithImageCachePool:nil concurrentCount:concurrentCount waitingCount:waitingCount];
}

- (id)initWithImageCachePool:(MyImageCachePool *)imageCachePool
             concurrentCount:(NSUInteger)concurrentCount
                waitingCount:(NSUInteger)waitingCount
{
    if (self = [super init]) {
        
        _URLToTaskMap          = [NSMutableDictionary dictionaryWithCapacity:concurrentCount];
        _delegateToTasksMap    = [NSMutableDictionary dictionaryWithCapacity:concurrentCount];
        _httpRequestToTaskMap  = [NSMutableDictionary dictionaryWithCapacity:concurrentCount];
        _concurrentCount       = (concurrentCount == 0) ? 15 : concurrentCount;
        _imageCachePool        = imageCachePool;
        
        _waitingPool = [[_ImageDownLoadTaskWaitingPool alloc] initWithWaitingCount:waitingCount];
        _waitingPool.delegate = self;
        
        _delegateToLoadCacheTasksMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    [self cancleAllDownLoadImage];
}

#pragma mark -

//发送下载成功消息
#define SendDownLoadSucceedMsg(_delegate,_image,_url,_resultType)                                                \
do {                                                                                                             \
ifRespondsSelector(_delegate, @selector(imageDownLoadManager:downloadSucceedForURL:image:resultType:))       \
[_delegate imageDownLoadManager:self downloadSucceedForURL:_url image:_image resultType:_resultType];    \
}while(0)

//发送下载失败消息
#define SendDownLoadFailedMsg(_delegate,_url,_error)                                             \
do {                                                                                             \
ifRespondsSelector(_delegate, @selector(imageDownLoadManager:downloadFailedForURL:error:))   \
[_delegate imageDownLoadManager:self downloadFailedForURL:_url error:_error];            \
} while (0)


#pragma mark -

//下载图片错误的创建
#define DownLoadImageErrorCreate(_code,_description,_userinfo)  \
ERROR_CREATE(ImageDownLoadErrorDomain,_code, _description,_userinfo)

//URL无效
#define DownLoadImageURLInvalidError(_url)  \
DownLoadImageErrorCreate(ImageDownLoadErrorCodeURLInvalid,([NSString stringWithFormat:@"图片文件URL无效，URL = %@",_url]),nil)

//文件URL无效
#define DownLoadImageFileURLInvalidError(_url)  \
DownLoadImageErrorCreate(ImageDownLoadErrorCodeFileURLInvalid,([NSString stringWithFormat:@"图片文件URL无效，URL = %@",_url]),nil)

//网络不可用
#define DownLoadImageNetUnavailableError()  \
DownLoadImageErrorCreate(ImageDownLoadErrorCodeNetUnavailable,@"网络似乎断开了连接。",nil)

//返回结果无效
#define DownLoadImageResultDataInvalidError(_url,_resultType)  \
DownLoadImageErrorCreate(ImageDownLoadErrorCodeResultDataInvalid,([NSString stringWithFormat:@"返回的数据无效，URL = %@",_url]),([NSDictionary dictionaryWithObject:@(_resultType) forKey:ImageDownLoadErrorResultTypeUserInfoKey]))

#define DownLoadImageErrorWattingQuenuOverflowError()   \
DownLoadImageErrorCreate(ImageDownLoadErrorCodeResultWattingQuenuOverflow,@"由于图片下载任务过多，下载请求被取消。",nil)

#pragma mark -

- (MyImageCachePool *)imageCachePool
{
    if (!_imageCachePool) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _imageCachePool = [MyImageCachePool shareImageCachePool];
        });
    }
    return _imageCachePool;
}

#pragma mark -

- (NSError *)_checkImageURL:(NSString *)url
{
    BOOL isInvaild = NO;
    
    NSURL * URL = [NSURL URLWithString:url];
    if (URL == nil) { //URL创建不成功无效
        isInvaild = YES;
    }else if(![url hasPrefix:@"http"]) { //不以http开头且非文件url无效
        isInvaild = ![URL isFileURL];
    }
    
    //URL无效返回错误
    return isInvaild ? DownLoadImageURLInvalidError(url) : nil;
}

- (MyImageDownLoadResultType)_loadCacheAndFileImageWithURL:(NSString *)url
                                            downLoadPolicy:(MyImageDownLoadPolicy)policy
                                               resultImage:(UIImage **)pResultImage
                                                     error:(NSError **)pError
{
    NSError * error = nil;
    UIImage *resultImage = nil;
    MyImageDownLoadResultType resultType = MyImageDownLoadResultTypeNone;
    MyImageCacheType imageCacheType = MyImageCacheTypeNone;
    
    if (UseLocalCache(policy)) { //从缓存获取
        resultImage = [self.imageCachePool imageWithKey:url policy:MyCacheImagePolicyDefault type:&imageCacheType];
    }
    
    if (resultImage) { //从缓存加载成功
        
        //生成结果类型
        resultType = MyImageDownLoadResultTypeCacheLoad;
        switch (imageCacheType) {
            case MyImageCacheTypeInsideCache:
                resultType |= MyImageDownLoadResultTypeInsideCache;
                break;
                
            case MyImageCacheTypeFileCache:
                resultType |= MyImageDownLoadResultTypeFileCache;
                break;
                
            case MyImageCacheTypeOuterCache:
                resultType |= MyImageDownLoadResultTypeOuterCache;
                break;
                
            default:
                break;
        }
        
    }else {
        
        //判断是否为文件URL
        NSURL * requestURL = [NSURL URLWithString:url];
        if ([requestURL isFileURL]) {
            
            //判断文件是否存在
            if(fileExistAtPath(requestURL.path)) {
                
                //加载文件数据
                NSData * fileData = [NSData dataWithContentsOfFile:requestURL.path];
                if (fileData) {
                    //尝试从从文件数据生成图片
                    resultImage = [UIImage imageWithData:fileData];
                }else {
                    //文件读取失败，可能是应用包内的图片，尝试采用名称方式读取,此中图片已有系统缓存不需要自己缓存
                    resultImage = [UIImage imageNamed:[requestURL.pathComponents lastObject]];
                }
                
                //文件并非图片数据
                if (resultImage == nil) {
                    error = DownLoadImageResultDataInvalidError(url,MyImageDownLoadResultTypeFileLoad);
                }else {
                    resultType = MyImageDownLoadResultTypeFileLoad;
                    
                    //从文件加载且需要缓存则缓存到内存
                    if (fileData && CacheImage(policy)) {
                        [self.imageCachePool cacheImage:resultImage
                                                    key:url
                                                 policy:MyCacheImagePolicyUseOuterCache
                                                  async:YES];
                    }
                }
                
            }else { //文件不存在
                error = DownLoadImageFileURLInvalidError(url);
            }
        }
    }
    
    
    if (pError) *pError = error;
    if (pResultImage) *pResultImage = resultImage;
    
    
    return resultType;
}

#define AddTask(_task,_map,_key)\
{\
NSMutableSet * taskSets = [_map objectForKey:_key];\
if (taskSets == nil) {\
taskSets = [NSMutableSet set];\
[_map setObject:taskSets forKey:_key];\
}\
[taskSets addObject:_task];\
}\

- (void)startDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                       URL:(NSString *)url
            downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    //核对图片URL
    NSError * __block error = [self _checkImageURL:url];
    if (error != nil) { //url无效
        SendDownLoadFailedMsg(delegate,url,error);
        return;
    }
    
    //判断加载方式
    BOOL asyncLoad = NO;
    if (AutoLoadCache(policy)) { //自动模式，如果无内存缓存则使用异步加载
        asyncLoad = ![self.imageCachePool hadCacheImageForKey:url policy:MyCacheImagePolicyUseOuterCache type:NULL];
    }else if (AsyncLoadCache(policy)) {
        asyncLoad = YES;
    }
    
    
    UIImage * __block resultImage = nil;
    MyImageDownLoadResultType __block resultType = MyImageDownLoadResultTypeNone;
    
    //完成的blcok
    void (^completedBlock)(void) = ^ {
        
        if (resultImage) { //加载成功
            SendDownLoadSucceedMsg(delegate, resultImage, url, resultType);
        }else if(error){  //加载错误
            SendDownLoadFailedMsg(delegate, url, error);
        }else { //开始从网络加载
            [self _addImageDownLoadTaskWithURL:url delegate:delegate downLoadPolicy:policy];
        }
    };
    
    
    if (asyncLoad) {
        
        //记录任务，防止回调时已被取消
        _MyImageLoadCacheTask * loadCacheTask = [[_MyImageLoadCacheTask alloc] initWithDelegate:delegate imageURL:url];
        AddTask(loadCacheTask, _delegateToLoadCacheTasksMap, loadCacheTask.delegate.delegateKey);
        
        //异步加载缓存数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            resultType = [self _loadCacheAndFileImageWithURL:url
                                              downLoadPolicy:policy
                                                 resultImage:&resultImage
                                                       error:&error];
            //异步加载
            resultType |= MyImageDownLoadResultTypeAsyncLoad;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //判断是否被取消
                NSMutableSet * tasksSet = [_delegateToLoadCacheTasksMap objectForKey:loadCacheTask.delegate.delegateKey];
                if ([tasksSet containsObject:loadCacheTask] ) {
                    
                    //移除记录
                    [tasksSet removeObject:loadCacheTask];
                    if (tasksSet.count == 0) {
                        [_delegateToLoadCacheTasksMap removeObjectForKey:loadCacheTask.delegate.delegateKey];
                    }
                    
                    //结果回调
                    completedBlock();
                }
                
            });
        });
        
    }else {
        
        resultType = [self _loadCacheAndFileImageWithURL:url
                                          downLoadPolicy:policy
                                             resultImage:&resultImage
                                                   error:&error];
        completedBlock();
    }
}

- (NSMutableSet *)blockDelegateSet
{
    if (!_blockDelegateSet) {
        _blockDelegateSet = [[NSMutableSet alloc] init];
    }
    
    return _blockDelegateSet;
}

- (id<MyImageDownLoadDelegate>)startDownLoadImageWithURL:(NSString *)url
                                          downLoadPolicy:(MyImageDownLoadPolicy)policy
                                            succeedBlock:(MyImageDownLoadSucceedBlock)succeedBlock
                                             failedBlock:(MyImageDownLoadFailedBlock)failedBlock
{
    //生成代理
    _MyImageDownLoadDelegateForBlock * delegate = [_MyImageDownLoadDelegateForBlock createDelegateForImageDownLoadManager:self succeedBlock:succeedBlock failedBlock:failedBlock];
    
    //开始下载
    [self startDownLoadImage:delegate URL:url downLoadPolicy:policy];
    
    return delegate;
}


- (void)_addImageDownLoadTaskWithURL:(NSString *)url
                            delegate:(id<MyImageDownLoadDelegate>)delegate
                      downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    
    //查找是否有url的下载任务
    _ImageDownLoadTask *imageDownLoadTask = [_URLToTaskMap objectForKey:url];
    if (imageDownLoadTask) {
        
        //存在url下载任务，直接开始下载任务(开始时会进行合并)
        _ImageDownLoadTask * task = [[_ImageDownLoadTask alloc] initWithImageURL:url delegate:delegate downLoadPolicy:policy];
        [self _startImageDownLoadTask:task];
        
    }else{
        
        //加入等待池
        [_waitingPool addTaskWithURL:url delegate:delegate downLoadPolicy:policy];
        //开始下一个等待任务
        [self _startNextImageDownLoadTaskFromWaitingPool];
    }
}

- (void)_startNextImageDownLoadTaskFromWaitingPool
{
    if (_URLToTaskMap.count < _concurrentCount) {
        [self _startImageDownLoadTask:[_waitingPool nextImageDownLoadTask]];
    }
}

- (void)_startImageDownLoadTask:(_ImageDownLoadTask *)imageDownLoadTask
{
    if (!imageDownLoadTask) {
        return;
    }
    
    _ImageDownLoadTask * tmpImageDownLoadTask = [_URLToTaskMap objectForKey:imageDownLoadTask.imageURL];
    
    BOOL isNew = NO;
    if (!tmpImageDownLoadTask) {
        
        isNew = YES;
        tmpImageDownLoadTask = imageDownLoadTask;
        
        //新的下载任务
        [_URLToTaskMap setObject:tmpImageDownLoadTask forKey:tmpImageDownLoadTask.imageURL];
        [_httpRequestToTaskMap setObject:tmpImageDownLoadTask forKey:NSNumberWithPointer(tmpImageDownLoadTask.httpRequest)];
        
    }else{
        
        //合并下载任务
        [tmpImageDownLoadTask unionTask:imageDownLoadTask];
    }
    
    //添加任务与代理的关联
    for (MyWeakDelegate * delegate in imageDownLoadTask.delegateSet) {
        AddTask(tmpImageDownLoadTask, _delegateToTasksMap, delegate.delegateKey);
    }
    
    if (isNew) {
        
        if (NetworkAvailable()) { //网路可用则开始请求
            [tmpImageDownLoadTask.httpRequest setDelegate:self];
            [tmpImageDownLoadTask.httpRequest startRequest];
        }else { //否则直接发送错误消息
            [self httpRequest:tmpImageDownLoadTask.httpRequest response:nil didFailedRequestWithError:DownLoadImageNetUnavailableError()];
        }
    }
}

#pragma mark -

- (void)imageDownLoadWaitingPool:(_ImageDownLoadTaskWaitingPool *)waitingPool
                   didRemoveTask:(_ImageDownLoadTask *)imageDownLoadTask
{
    for (MyWeakDelegate * weakDelegate in imageDownLoadTask.delegateSet.allObjects) {
        id<MyImageDownLoadDelegate> delegate = weakDelegate.delegate;
        SendDownLoadFailedMsg(delegate, imageDownLoadTask.imageURL, DownLoadImageErrorWattingQuenuOverflowError());
    }
}

#pragma mark - 取消任务

//移除下载数据
#define RemoveDownLoadTask(downLoadTask)                                                        \
do{                                                                                             \
[_httpRequestToTaskMap removeObjectForKey:NSNumberWithPointer(downLoadTask.httpRequest)];   \
[_URLToTaskMap removeObjectForKey:downLoadTask.imageURL];                                   \
}while(0)

- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate forceToCancle:(BOOL)force {
    [self cancleDownLoadImage:delegate URL:nil forceToCancle:force];
}

- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                        URL:(NSString *)url
              forceToCancle:(BOOL)force
{
    id<NSCopying> delegateKey = [MyWeakDelegate keyForDelegate:delegate];
    
    NSMutableSet * tasksSet  = [_delegateToTasksMap objectForKey:delegateKey];
    if (tasksSet != nil) {
        
        _ImageDownLoadTask * _needRemoveTask = nil;
        for (_ImageDownLoadTask  * downLoadTask in tasksSet) {
            
            if (url == nil || [downLoadTask.imageURL isEqualToString:url]) {
                
                //移除代理回调
                BOOL needRemoveTask = NO;
                if (delegate == nil && downLoadTask.delegateSet.count == 0) {
                    needRemoveTask = YES;
                }else {
                    MyWeakDelegate * weakDelegate = [[MyWeakDelegate alloc] initWithDelegateForSearch:delegate];
                    [downLoadTask.delegateSet removeObject:weakDelegate];
                    needRemoveTask = (downLoadTask.delegateSet.count == 0);
                }
                
                //取消任务并移除
                if (needRemoveTask && force) {
                    [downLoadTask.httpRequest cancleRequest];
                    RemoveDownLoadTask(downLoadTask);
                }
                
                if (url != nil) {
                    _needRemoveTask = downLoadTask;
                    break;
                }
            }
        }
        
        //移除任务
        if (_needRemoveTask) {
            [tasksSet removeObject:_needRemoveTask];
        }
        
        //任务数为0则移除代理与任务的关联
        if (url == nil || tasksSet.count == 0) {
            [_delegateToTasksMap removeObjectForKey:delegateKey];
        }
    }
    
    //从等待池移除
    [_waitingPool removeTaskWithURL:url delegate:delegate forceCancle:force];
    
    //移除加载缓存的任务
    tasksSet  = [_delegateToLoadCacheTasksMap objectForKey:delegateKey];
    if (tasksSet != nil) {
        
        _MyImageLoadCacheTask * needRemoveTask = nil;
        for (_MyImageLoadCacheTask  * loadCacheTask in tasksSet) {
            
            //如果url为nil或者相等则需要移除
            if (url == nil || [loadCacheTask.imageURL isEqualToString:url]) {
                
                if (url != nil) {
                    needRemoveTask = loadCacheTask;
                    break;
                }
            }
        }
        
        //移除任务
        if (needRemoveTask) {
            [tasksSet removeObject:needRemoveTask];
        }
        
        //任务数为0则移除任务与代理的关联
        if (url == nil || tasksSet.count == 0) {
            [_delegateToLoadCacheTasksMap removeObjectForKey:delegateKey];
        }
    }
    
    //移除代理
    if ([delegate isKindOfClass:[_MyImageDownLoadDelegateForBlock class]]) {
        [self.blockDelegateSet removeObject:delegate];
    }
}

- (void)cancleAllDownLoadImage
{
    //取消任务
    for (_ImageDownLoadTask *downLoadTask in _URLToTaskMap.allValues) {
        [downLoadTask.httpRequest cancleRequest];
    }
    
    //清除数据
    [_delegateToTasksMap removeAllObjects];
    [_URLToTaskMap removeAllObjects];
    [_httpRequestToTaskMap removeAllObjects];
    [_waitingPool clearWaitingPool];
    [_delegateToTasksMap removeAllObjects];
    [self.blockDelegateSet removeAllObjects];
}

#pragma mark - 下载图片代理回调

- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
       didReceiveDataLength:(long long)receiveDataLength
         expectedDataLength:(long long)expectedDataLength
           receiveDataSpeed:(NSUInteger)speed
{
    //图片下载过程回调
    _ImageDownLoadTask  *downLoadTask = [_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)];
    
    if(downLoadTask){
        
        for (MyWeakDelegate * weakDelegate in downLoadTask.delegateSet.allObjects) {
            
            id<MyImageDownLoadDelegate> delegate = weakDelegate.delegate;
            ifRespondsSelector(delegate, @selector(imageDownLoadManager:imageURL:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)){
                [delegate imageDownLoadManager:self
                                      imageURL:downLoadTask.imageURL
                          didReceiveDataLength:receiveDataLength
                            expectedDataLength:expectedDataLength
                              receiveDataSpeed:speed];
            }
        }
    }
}

- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
                   response:(NSHTTPURLResponse *)response
  didSuccessRequestWithData:(NSData *)data
{
    _ImageDownLoadTask  *downLoadTask = [_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)];
    
    if (downLoadTask) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //后台通过数据生成图片，避免图片过大，生成时造成UI卡顿
            UIImage *resultImage = [UIImage decodeImageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //判断该任务是否未被取消,有可能在后台生成图片时，任务已被取消
                if (downLoadTask == [_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)]) {
                    
                    //返回数据错误（resultImage == nil）,则发送数据不合法错误，否则发送成功消息
                    [self _imageDownloadTask:downLoadTask
                          completedWithImage:resultImage
                                       error:resultImage ? nil : DownLoadImageResultDataInvalidError(downLoadTask.imageURL,MyImageDownLoadResultTypeNetLoad)];
                    
                }
            });
        });
    }
}

- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
                   response:(NSHTTPURLResponse *)response
  didFailedRequestWithError:(NSError *)error
{
    //图片下载失败
    [self _imageDownloadTask:[_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)]
          completedWithImage:nil
                       error:error];
}

- (void)_imageDownloadTask:(_ImageDownLoadTask *)task completedWithImage:(UIImage *)image error:(NSError *)error
{
    if (task) {
        
        //缓存图片
        if (image != nil && CacheImage(task.policy)) {
            [self.imageCachePool cacheImage:image key:task.imageURL policy:MyCacheImagePolicyDefault async:YES];
        }
        
        for (MyWeakDelegate * weakDelegate in task.delegateSet.allObjects) {
            
            //移除代理与task的关联
            NSMutableSet * tasksSet  = [_delegateToTasksMap objectForKey:weakDelegate.delegateKey];
            [tasksSet removeObject:task];
            if (tasksSet.count == 0) {
                [_delegateToTasksMap removeObjectForKey:weakDelegate.delegateKey];
            }
            
            //回调消息
            id<MyImageDownLoadDelegate> delegate = weakDelegate.delegate;
            if (error != nil) { //发送错误消息
                SendDownLoadFailedMsg(delegate, task.imageURL, error);
            }else { //发送成功消息
                SendDownLoadSucceedMsg(delegate, image, task.imageURL,MyImageDownLoadResultTypeNetLoad | MyImageDownLoadResultTypeAsyncLoad);
            }
        }
        
        //移除任务
        RemoveDownLoadTask(task);
        
        //从等待队列开始下一个任务
        [self _startNextImageDownLoadTaskFromWaitingPool];
    }
}

@end


//----------------------------------------------------------

@implementation _ImageDownLoadTask

@synthesize delegateSet = _delegateSet;

- (id)initWithImageURL:(NSString *)URL
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    if (self = [super init]) {
        
        _imageURL = [URL copy];
        _httpRequest = [[MyHTTPRequest alloc] initWithURL:URL];
        _policy = policy;
        
        //加入代理
        if (delegate != nil) {
            [self.delegateSet addObject:[[MyWeakDelegate alloc] initWithDelegate:delegate]];
        }
    }
    
    return self;
}

- (NSMutableSet<MyWeakDelegate<id<MyImageDownLoadDelegate>> *> *)delegateSet
{
    if (!_delegateSet) {
        _delegateSet = [NSMutableSet set];
    }
    
    return _delegateSet;
}

- (void)addCallbackDelegate:(id<MyImageDownLoadDelegate>)delegate downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    //合并策略
    _policy |= policy;
    
    //添加回调代理
    if (delegate) {
        [self.delegateSet addObject:[[MyWeakDelegate alloc] initWithDelegate:delegate]];
    }
}

//合并下载任务
- (void)unionTask:(_ImageDownLoadTask *)task
{
    MyAssert([self.imageURL isEqualToString:task.imageURL]);
    
    //合并策略
    _policy |= task.policy;
    
    //加入代理
    for (MyWeakDelegate * delegate in task.delegateSet) {
        if (delegate.delegate != nil) {
            [self.delegateSet addObject:delegate];
        }
    }
}

- (void)removeInvaidDelegate
{
    if (self.delegateSet.count == 0) {
        return;
    }
    
    NSMutableSet * invaidDelegates = [NSMutableSet setWithCapacity:self.delegateSet.count];
    for (MyWeakDelegate * delegate in self.delegateSet) {
        if (delegate.delegate == nil) {
            [invaidDelegates addObject:delegate];
        }
    }
    
    //减去set
    [self.delegateSet minusSet:invaidDelegates];
}

@end

//----------------------------------------------------------

@implementation _MyImageLoadCacheTask

- (id)initWithDelegate:(id<MyImageDownLoadDelegate>)delegate imageURL:(NSString *)imageURL
{
    self = [super init];
    if (self) {
        _delegate = [[MyWeakDelegate alloc] initWithDelegate:delegate];
        _imageURL = [imageURL copy];
    }
    
    return self;
}

@end

//----------------------------------------------------------

@implementation _ImageDownLoadTaskWaitingPool
{
    //URL到数据的映射表
    NSMutableDictionary *_URLToTaskMap;
    
    //正在等待的任务数组
    NSMutableArray      *_waitingTaskArray;
    
    //最大等待数目
    NSUInteger           _waitingCount;
}

- (id)init {
    return [self initWithWaitingCount:45];
}

- (id)initWithWaitingCount:(NSUInteger)waitingCount
{
    self = [super init];
    
    if (self) {
        
        _waitingCount = waitingCount;
        
        _URLToTaskMap = [NSMutableDictionary dictionaryWithCapacity:waitingCount];
        _waitingTaskArray = [NSMutableArray arrayWithCapacity:waitingCount];
    }
    
    return self;
}


- (void)addTaskWithURL:(NSString *)url
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(MyImageDownLoadPolicy)policy
{
    //查找是否存在
    _ImageDownLoadTask * imageDownLoadTask = [_URLToTaskMap objectForKey:url];
    
    if (imageDownLoadTask) {
        
        //存在则移除后重新加入，提高优先级
        [_waitingTaskArray removeObjectIdenticalTo:imageDownLoadTask];
        
        //添加回调代理
        [imageDownLoadTask addCallbackDelegate:delegate downLoadPolicy:policy];
        
    }else{
        
        //不存在初始化任务
        imageDownLoadTask = [[_ImageDownLoadTask alloc] initWithImageURL:url
                                                                delegate:delegate
                                                          downLoadPolicy:policy];
        [_URLToTaskMap setObject:imageDownLoadTask forKey:url];
    }
    
    //加入等待队列
    [_waitingTaskArray addObject:imageDownLoadTask];
    
    //尝试移除
    [self _tryRemoveTask];
}

- (void)_tryRemoveTask
{
    //等待队列数大于最大等待数
    while (_waitingTaskArray.count >= _waitingCount) {
        
        //优先寻找代理数为0的任务
        NSInteger index = 0;
        for (_ImageDownLoadTask * task in _waitingTaskArray) {
            
            //移除无效的代理
            [task removeInvaidDelegate];
            
            if (task.delegateSet.count == 0) break;
            ++ index;
        }
        
        //没有找到则从第一个开始
        if (index == _waitingTaskArray.count) {
            index = _waitingTaskArray.count ? 0.f : -1.f;
        }
        
        if (index >= 0) {
            
            //删除数据
            _ImageDownLoadTask * task = _waitingTaskArray[index];
            [_waitingTaskArray removeObjectAtIndex:index];
            [_URLToTaskMap removeObjectForKey:task.imageURL];
            
            //通知代理
            [self.delegate imageDownLoadWaitingPool:self didRemoveTask:task];
        }
    }
}

- (_ImageDownLoadTask *)nextImageDownLoadTask
{
    if (_waitingTaskArray.count) { //存在数据则返回最后一个
        
        _ImageDownLoadTask * imageDownLoadTask = _waitingTaskArray.lastObject;
        [_waitingTaskArray removeLastObject];
        [_URLToTaskMap removeObjectForKey:imageDownLoadTask.imageURL];
        
        return imageDownLoadTask;
    }
    
    return nil;
}

- (void)removeTaskWithURL:(NSString *)url
                 delegate:(id<MyImageDownLoadDelegate>)delegate
              forceCancle:(BOOL)forceCancle
{
    _ImageDownLoadTask * imageDownLoadTask = [_URLToTaskMap objectForKey:url];
    if (imageDownLoadTask) {
        
        BOOL needRemoveTask = NO;
        
        if (delegate == nil && imageDownLoadTask.delegateSet.count == 0) { //不存在元素
            needRemoveTask = YES;
        } else { //移除回调代理
            MyWeakDelegate * weakDelegate = [[MyWeakDelegate alloc] initWithDelegateForSearch:delegate];
            [imageDownLoadTask.delegateSet removeObject:weakDelegate];
            needRemoveTask = (imageDownLoadTask.delegateSet == 0);
        }
        
        //移除任务
        if (needRemoveTask && forceCancle) {
            
            [_waitingTaskArray removeObjectIdenticalTo:imageDownLoadTask];
            [_URLToTaskMap removeObjectForKey:url];
        }
    }
}

- (void)clearWaitingPool
{
    [_waitingTaskArray removeAllObjects];
    [_URLToTaskMap removeAllObjects];
}

@end


//----------------------------------------------------------

@implementation _MyImageDownLoadDelegateForBlock

+ (instancetype)createDelegateForImageDownLoadManager:(MyImageDownLoadManager *)manager
                                         succeedBlock:(MyImageDownLoadSucceedBlock)succeedBlock
                                          failedBlock:(MyImageDownLoadFailedBlock)failedBlock
{
    _MyImageDownLoadDelegateForBlock * delegate = [[self alloc] initWithSucceedBlock:succeedBlock failedBlock:failedBlock];
    [[manager blockDelegateSet] addObject:delegate];
    
    return delegate;
}

- (id)initWithSucceedBlock:(MyImageDownLoadSucceedBlock)succeedBlock
               failedBlock:(MyImageDownLoadFailedBlock)failedBlock
{
    self = [super init];
    
    if (self) {
        _succeedBlock = succeedBlock;
        _failedBlock = failedBlock;
    }
    
    return self;
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
       downloadSucceedForURL:(NSString *)url
                       image:(UIImage *)image
                  resultType:(MyImageDownLoadResultType)resultType
{
    [[manager blockDelegateSet] removeObject:self];
    
    if (self.succeedBlock) {
        self.succeedBlock(url,image,resultType);
    }
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
        downloadFailedForURL:(NSString *)url
                       error:(NSError *)error
{
    [[manager blockDelegateSet] removeObject:self];
    
    if (self.failedBlock) {
        self.failedBlock(url,error);
    }
}

@end


