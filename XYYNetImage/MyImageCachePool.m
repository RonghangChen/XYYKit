//
//  ImageCachePool.m
//
//
//  Created by LeslieChen on 14-1-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageCachePool.h"

//----------------------------------------------------------

@interface _MyCacheImageData : NSObject

+ (_MyCacheImageData *)dataWithImage:(UIImage *)image key:(NSString *)key;
- (id)initWithImage:(UIImage *)image key:(NSString *)key;

@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) UIImage  * image;

@end

//----------------------------------------------------------

@implementation _MyCacheImageData

+ (_MyCacheImageData *)dataWithImage:(UIImage *)image key:(NSString *)key {
    return [[_MyCacheImageData alloc] initWithImage:image key:key];
}

- (id)initWithImage:(UIImage *)image key:(NSString *)key
{
    MyAssert(image && key);
    
    if (self = [super init]) {
        _key = key;
        _image = image;
    }
    return self;
}

@end

////----------------------------------------------------------
//
//@interface _MyOuterCacheImageData : NSObject
//
//- (id)initWithImage:(UIImage *)image;
//
//@property(nonatomic,weak,readonly) UIImage * image;
//
//@end
//
////----------------------------------------------------------
//
//@implementation _MyOuterCacheImageData
//
//- (id)initWithImage:(UIImage *)image
//{
//    self = [super init];
//    
//    if (self) {
//        _image = image;
//    }
//    
//    return self;
//}
//
//@end

//----------------------------------------------------------

@interface MyImageCachePool ()

//内部缓存
@property(nonatomic,readonly,strong) NSCache  * cache;

////外部缓存
//@property(nonatomic,readonly,strong) NSCache  * outerCache;

@end

//----------------------------------------------------------

@implementation MyImageCachePool

@synthesize cache = _cache;
//@synthesize outerCache = _outerCache;

+ (instancetype)shareImageCachePool
{
    static MyImageCachePool * shareImageCachePool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareImageCachePool = [[self alloc] init];
    });
    
    return shareImageCachePool;
}

#pragma mark - life circle

+ (NSString *)cacheRootFileFloderName {
    return @"imageCache";
}

+ (NSString *)defaultCacheFileFloderName {
    return @"defaultImageCache";
}

- (id)initWithPathType:(MyPathType)pathType andCacheFileFloderName:(NSString *)cacheFileFloderName
{
    self = [super initWithPathType:pathType andCacheFileFloderName:cacheFileFloderName];
    if (self) {
        
        _cache = [[NSCache alloc] init];
        _cache.delegate = self;
        
        self.autoChangeCapacity = YES;
        
        //观察通知
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self
                          selector:@selector(_didReceiveMemoryWarningNotification:)
                              name:UIApplicationDidReceiveMemoryWarningNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(_applicationDidEnterBackgroundNotification:)
                              name:UIApplicationDidEnterBackgroundNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(_applicationWillEnterForegroundNotification:)
                              name:UIApplicationWillEnterForegroundNotification
                            object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    _cache.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_didReceiveMemoryWarningNotification:(NSNotification *)notification
{
    //内存不足清理缓存
    [self clearInsideCacheImages];
}

- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    //应用进入后台清理缓存，防止占用太多被回收
    [self.cache removeAllObjects];
}

- (void)_applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    //异步更新缓存区容量
    if (self.autoChangeCapacity) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _updateMaxCapacity];
        });
    }
}

#pragma mark -

//- (NSCache *)cache
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _cache = [[NSCache alloc] init];
//        _cache.delegate = self;
//        [_cache setTotalCostLimit:self.maxCapacity * 1024];
//    });
//
//    if (!_cache) {
//
//        //互斥锁防止初始化_cache时对对象的访问
//        @synchronized(self) {
//            _cache = [[NSCache alloc] init];
//            _cache.delegate = self;
//            [_cache setTotalCostLimit:self.maxCapacity * 1024];
//        }
//    }
//
//    return _cache;
//}

//- (NSCache *)outerCache
//{
//    if (!_outerCache) {
//        
//        //互斥锁防止初始化_cache时对对象的访问
//        @synchronized(self) {
//            _outerCache = [[NSCache alloc] init];
//            [_outerCache setCountLimit:self.maxOuterCacheCount];
//        }
//    }
//    
//    return _outerCache;
//}

- (void)setMaxCapacity:(NSUInteger)maxCapacity
{
    if (!self.autoChangeCapacity) {
        [self _setMaxCapacity:maxCapacity];
    }
}

- (void)_setMaxCapacity:(NSUInteger)maxCapacity
{
    maxCapacity = MAX(1, maxCapacity);
    
    if (_maxCapacity != maxCapacity) {
        _maxCapacity = maxCapacity;
        
        [_cache setTotalCostLimit:_maxCapacity * 1024];
        
        DebugLog(ImageCachePool, @"当前缓存区最大容量为%iMB",(int)maxCapacity);
    }
}

- (void)setAutoChangeCapacity:(BOOL)autoChangeCapacity
{
    if (autoChangeCapacity != _autoChangeCapacity) {
        _autoChangeCapacity = autoChangeCapacity;
        
        if (self.autoChangeCapacity) {
            [self _updateMaxCapacity];
        }else {
            self.maxCapacity = 30;
        }
    }
}

- (void)_updateMaxCapacity
{
    if (self.autoChangeCapacity) {
        
        //获取可用内存大小
        double availableMemorySize = memorySizeForType(MyMemoryTypeAvailable);
        
        //容量未知则设置为默认值
        if (availableMemorySize == MyMemorySizeUnknown) {
            [self _setMaxCapacity:30];
        }else { //容量不超过可用内存的2/5
            [self _setMaxCapacity:floor(availableMemorySize * 0.4)];
        }
    }
}

//- (void)setMaxOuterCacheCount:(NSUInteger)maxOuterCacheCount
//{
//    maxOuterCacheCount = MAX(1, maxOuterCacheCount);
//    
//    if (_maxOuterCacheCount != maxOuterCacheCount) {
//        _maxOuterCacheCount = maxOuterCacheCount;
//        
//        [_outerCache setCountLimit:_maxOuterCacheCount];
//    }
//}

#pragma mark - cache image handle

//屏蔽
- (void)cacheData:(NSData *)data forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void (^)(BOOL))completedBlock {
    // do nothing
}

- (void)cacheDataWithFilePath:(NSString *)path forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void (^)(BOOL))completedBlock {
    // do nothing
}

- (void)cacheImage:(UIImage *)image key:(NSString *)key {
    [self cacheImage:image key:key policy:MyCacheImagePolicyDefault async:YES];
}

- (void)cacheImage:(UIImage *)image key:(NSString *)key policy:(MyCacheImagePolicy)policy async:(BOOL)async
{
    if (image == nil || key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"image和key不能为nil"
                                        userInfo:nil];
    }
    
    //缓存
    [self _cacheImage:image key:key policy:policy];
    
//    //删除外部缓存
//    if (!CacheImageUseOuterCachePolicy(policy)) {
//        [self.outerCache removeObjectForKey:key];
//    }
    
    //缓存图片到文件
    if (CacheImageUseFileCachePolicy(policy)) {
        
        if (async) {
            
            //异步生成图片数据并缓存
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData * imageData = [image representationData:0.9f];
                if (imageData != nil) {
                    [super cacheData:imageData forKey:key async:NO blockQueue:nil completedBlock:nil];
                }
            });
            
        }else {
            
            NSData * imageData = [image representationData:0.9f];
            if (imageData != nil) {
                [super cacheData:imageData forKey:key async:NO blockQueue:nil completedBlock:nil];
            }
        }
        
    }else {
        [self removeCacheFileForKey:key async:async];
    }
}

- (void)cacheImageWithFilePath:(NSString *)imageFilePath key:(NSString *)key async:(BOOL)async
{
    if (imageFilePath == nil || key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"imageFilePath和key不能为nil"
                                        userInfo:nil];
    }
    
    if (fileExistAtPath(imageFilePath)) {
        
        //移除内存缓存
        [self.cache removeObjectForKey:key];
        
        //缓存数据
        [super cacheDataWithFilePath:imageFilePath forKey:key async:async blockQueue:nil completedBlock:nil];
        
    }else {
        NSLog(@"文件不存在，缓存失败");
    }
}

- (void)removeCacheImageForKey:(NSString *)key removeFile:(BOOL)removeFile async:(BOOL)async
{
    if (key) {
        
        //从内存删除
        [self.cache removeObjectForKey:key];
//        [self.outerCache removeObjectForKey:key];
        
        if (removeFile) { //删除文件缓存
            [self removeCacheFileForKey:key async:async];
        }
    }
}

- (UIImage *)imageWithKey:(NSString *)key {
    return [self imageWithKey:key policy:MyCacheImagePolicyDefault type:NULL];
}

- (UIImage *)imageWithKey:(NSString *)key policy:(MyCacheImagePolicy)policy type:(MyImageCacheType *)type
{
    UIImage * resultImage = nil;
    MyImageCacheType resultType = MyImageCacheTypeNone;
    
    if (key) {
        
        //首先查找内部缓存
        if ((resultImage = [(_MyCacheImageData *)[self.cache objectForKey:key] image])) {
            resultType = MyImageCacheTypeInsideCache;
        }
        
//        else if(CacheImageUseOuterCachePolicy(policy)) {
//            
//            if ((resultImage = [self _outerCacheImageForKey:key])) { //查找外部缓存
//                resultType = MyImageCacheTypeOuterCache;
//            }
//        }
        
        if (!resultImage && CacheImageUseFileCachePolicy(policy)) {
            
            //尝试使用文件缓存
            NSData * cacheData = [self cacheFileDataForKey:key];
            if (cacheData) {
                
                resultImage = [UIImage decodeImageWithData:cacheData];
                
                //文件是图片则缓存到内存，否则删除错误数据文件
                if (resultImage) {
                    resultType = MyImageCacheTypeFileCache;
                    [self _cacheImage:resultImage key:key policy:policy];
                }else {
                    [self removeCacheFileForKey:key async:YES];
                }
            }
        }
    }
    
    if (type) {
        *type = resultType;
    }
    
    return resultImage;
}

//#pragma mark -
//
//- (UIImage *)_outerCacheImageForKey:(NSString *)key
//{
//    _MyOuterCacheImageData * imageData = [self.outerCache objectForKey:key];
//    
//    UIImage * image = imageData.image;
//    if (imageData && !image) { //图片已被释放则移除
//        [self.outerCache removeObjectForKey:key];
//    }
//    
//    return image;
//}


- (void)_cacheImage:(UIImage *)image key:(NSString *)key policy:(MyCacheImagePolicy)policy
{
    //储存图片的花费为其所占用的内存大小，即占多少kb(>>13 == /(8 * 1024))    
    [self.cache setObject:[_MyCacheImageData dataWithImage:image key:key]
                   forKey:key
                     cost:MAX(1, [image imageMemorySize] >> 13)];
    
//    //外部缓存
//    if (CacheImageUseOuterCachePolicy(policy)) {
//        [self.outerCache setObject:[[_MyOuterCacheImageData alloc] initWithImage:image] forKey:key];
//    }
}


#pragma mark -

- (BOOL)hadCacheImageForKey:(NSString *)key {
    return [self hadCacheImageForKey:key policy:MyCacheImagePolicyDefault type:NULL];
}

- (BOOL)hadCacheImageForKey:(NSString *)key policy:(MyCacheImagePolicy)policy type:(MyImageCacheType *)type
{
    MyImageCacheType resultType = MyImageCacheTypeNone;
    
    if (key) {
        
        //内部缓存
        if ([self.cache objectForKey:key]) {
            resultType = MyImageCacheTypeInsideCache;
        }
        
//        else if (CacheImageUseOuterCachePolicy(policy) && [self _outerCacheImageForKey:key]) { //外部缓存
//            resultType = MyImageCacheTypeOuterCache;
//        }
        
        //文件缓存
        if (resultType == MyImageCacheTypeNone &&
            CacheImageUseFileCachePolicy(policy) &&
            [self hadCacheFileForKey:key]) {
            resultType = MyImageCacheTypeFileCache;
        }
    }
    
    if (type) {
        *type = resultType;
    }
    
    return resultType != MyImageCacheTypeNone;
}


#pragma mark -

- (void)clearInsideCacheImages
{
    [self.cache removeAllObjects];
    
    //异步更新缓存区容量
    if (self.autoChangeCapacity) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _updateMaxCapacity];
        });
    }
}

//- (void)clearOuterCacheImages {
//    [self.outerCache removeAllObjects];
//}

- (void)clearAllCacheImages:(void(^)(void))completeBlock
{
    [self clearInsideCacheImages];
//    [self clearOuterCacheImages];
    [self clearCacheFilesWithCompletedBlock:completeBlock];
}

#pragma mark -

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    id<MyImageCachePoolDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(imageCachePool:willRemoveImage:andKey:)){
        //主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            _MyCacheImageData *data = obj;
            [delegate imageCachePool:self willRemoveImage:data.image andKey:data.key];
        });
    }
}

#pragma mark -

//+ (NSString *)cacheFileNameForKey:(NSString *)key {
//    return [[super cacheFileNameForKey:key] stringByAppendingPathExtension:@"jpg"];
//}

//+ (dispatch_queue_t)cacheFileHandleQueue
//{
//    static dispatch_queue_t shareImageFileCacheQueue = nil;
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        shareImageFileCacheQueue = dispatch_queue_create("ImageCachePool.shareImageFileCacheQueue",DISPATCH_QUEUE_CONCURRENT);
//    });
//
//    return shareImageFileCacheQueue;
//}



@end
