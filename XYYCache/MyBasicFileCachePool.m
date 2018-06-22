
//
//  MyBasicFileCachePool.m
//  
//
//  Created by LeslieChen on 15/4/13.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicFileCachePool.h"

//----------------------------------------------------------

NSString * const MyFileCacheRootFileFloderName = @"__MyFileCache__";

//----------------------------------------------------------

@implementation MyBasicFileCachePool

#pragma mark -

+ (NSString *)defaultCacheFileFloderName {
    return nil;
}

+ (NSString *)cacheRootFileFloderName {
    return nil;
}

#pragma mark -

- (id)init {
    return [self initWithPathType:MyPathTypeCaches andCacheFileFloderName:nil];
}

- (id)initWithPathType:(MyPathType)pathType {
    return [self initWithPathType:pathType andCacheFileFloderName:nil];
}

- (id)initWithPathType:(MyPathType)pathType andCacheFileFloderName:(NSString *)cacheFileFloderName
{
    if ([self isMemberOfClass:[MyBasicFileCachePool class]]) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"MyBasicFileCachePool为抽象类不允许初始化"
                                     userInfo:nil];
    }
    
    self = [super init];
    
    if (self) {
        _pathType = pathType;
        _cacheFileFloderName = [(cacheFileFloderName.length ? [cacheFileFloderName copy] : [[self class] defaultCacheFileFloderName]) copy];
    }
    
    return self;
}

#pragma mark -

+ (NSString *)cacheFileFloderPathForType:(MyPathType)pathType withCacheFileFloderName:(NSString *)cacheFileFloderName
{
    return [[MyPathManager pathManagerWithType:pathType andFileFolder:[MyFileCacheRootFileFloderName stringByAppendingPathComponent:[self cacheRootFileFloderName]]] pathForDirectory:cacheFileFloderName];
}

- (NSString *)cacheFileFloderPath
{
    return [[self class] cacheFileFloderPathForType:self.pathType withCacheFileFloderName:self.cacheFileFloderName];
}

+ (NSString *)cacheFileNameForKey:(NSString *)key {
    return key ? [key md5String] : nil;
}

- (NSString *)createCacheFilePathForKey:(NSString *)key
{
    NSString * fileName = [[self class] cacheFileNameForKey:key];
    return fileName.length ? [self.cacheFileFloderPath stringByAppendingPathComponent:fileName] : nil;
}

#pragma mark - 

//读写锁
+ (pthread_rwlock_t *)cacheFileLock
{
    static NSMutableDictionary * locks = NULL;
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    
    NSString * key = NSStringFromClass([self class]);

    //上锁
    pthread_mutex_lock(&lock);
    
    if (locks == nil) {
        locks = [NSMutableDictionary dictionary];
    }
    
    NSValue * value = [locks objectForKey:key];
    if (value == nil) { //由于读写锁一直存在无需释放，所以不用释放内存
        
        //初始化锁
        pthread_rwlock_t * tmpLock = malloc(sizeof(pthread_rwlock_t));
        pthread_rwlock_init(tmpLock, NULL);
        
        //存储锁
        value = [NSValue valueWithPointer:tmpLock];
        [locks setObject:value forKey:key];
    }
    
    pthread_mutex_unlock(&lock);
    
    return [value pointerValue];
}

- (NSString *)cacheData:(NSData *)data
{
    NSString * key = [NSString uniqueIDString];
    [self cacheData:data forKey:key async:NO blockQueue:nil completedBlock:nil];
    return key;
}

- (void)cacheData:(NSData *)data forKey:(NSString *)key async:(BOOL)async {
    [self cacheData:data forKey:key async:async blockQueue:nil completedBlock:nil];
}

- (void)cacheData:(NSData *)data forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void (^)(BOOL))completedBlock
{
    if (data == nil || key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"data和key不能为nil"
                                        userInfo:nil];
    }
    
    //生成回调block的队列
    if (completedBlock && async && blockQueue == nil) {
        blockQueue = [NSOperationQueue currentQueue];
    }
    
    pthread_rwlock_t * lock = [[self class] cacheFileLock];

    if (async) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //写上锁
            pthread_rwlock_wrlock(lock);
            BOOL success = [data writeToFile:[self createCacheFilePathForKey:key] atomically:YES];
            pthread_rwlock_unlock(lock);
            
            
            //异步回调
            if (completedBlock) {
                [blockQueue addOperationWithBlock:^{
                    completedBlock(success);
                }];
            }
        });
        
    }else {
        
        //写上锁
        pthread_rwlock_wrlock(lock);
        BOOL success = [data writeToFile:[self createCacheFilePathForKey:key] atomically:YES];
        pthread_rwlock_unlock(lock);
        
        //同步回调
        if (completedBlock) {
            completedBlock(success);
        }
    }
}

- (NSString *)cacheDataWithFilePath:(NSString *)path
{
    NSString * key = [NSString uniqueIDString];
    [self cacheDataWithFilePath:path forKey:key async:NO blockQueue:nil completedBlock:nil];
    return key;
}

- (void)cacheDataWithFilePath:(NSString *)path forKey:(NSString *)key async:(BOOL)async {
    [self cacheDataWithFilePath:path forKey:key async:async blockQueue:nil completedBlock:nil];
}

- (void)cacheDataWithFilePath:(NSString *)path
                       forKey:(NSString *)key
                        async:(BOOL)async
                   blockQueue:(NSOperationQueue *)blockQueue
               completedBlock:(void (^)(BOOL))completedBlock
{
    if (path.length == 0 || key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"path和key不能为nil"
                                        userInfo:nil];
    }
    
    //生成回调block的队列
    if (completedBlock && async && blockQueue == nil) {
        blockQueue = [NSOperationQueue currentQueue];
    }
    
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    if (async) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //写上锁
            pthread_rwlock_wrlock(lock);
            
            NSError * error = nil;
            [[NSFileManager defaultManager] copyItemAtPath:path
                                                    toPath:[self createCacheFilePathForKey:key]
                                                     error:&error];
            pthread_rwlock_unlock(lock);
            
            if (error) {
                NSLog(@"缓存文件失败 error = %@",error);
            }
            
            if (completedBlock) { //异步回调
                [blockQueue addOperationWithBlock:^{
                    completedBlock(error != nil);
                }];
            }
        });
        
    }else{
        
        //写上锁
        pthread_rwlock_wrlock(lock);
        
        NSError * error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:path
                                                toPath:[self createCacheFilePathForKey:key]
                                                 error:&error];
        pthread_rwlock_unlock(lock);
        
        if (completedBlock) { //同步回调
            completedBlock(error != nil);
        }
    }
}

- (NSString *)cacheImageToFile:(UIImage *)image
{
    NSString * imagekey = [NSString uniqueIDString];
    [self cacheImageToFile:image key:imagekey async:NO blockQueue:nil completedBlock:nil];
    return imagekey;
}

- (void)cacheImageToFile:(UIImage *)image forKey:(NSString *)key async:(BOOL)async {
    [self cacheImageToFile:image key:key async:async blockQueue:nil completedBlock:nil];
}

- (void)cacheImageToFile:(UIImage *)image
                     key:(NSString *)key
                   async:(BOOL)async
              blockQueue:(NSOperationQueue *)blockQueue
          completedBlock:(void(^)(NSString * path))completedBlock
{
    if (image == nil || key.length == 0) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"image或key不能为nil"
                                        userInfo:nil];
    }

    //生成回调block的队列
    if (completedBlock && async && blockQueue == nil) {
        blockQueue = [NSOperationQueue currentQueue];
    }
    
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    if (async) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //写上锁
            pthread_rwlock_wrlock(lock);
            
            //生成路径并写入
            NSString * path = [self createCacheFilePathForKey:key];
            BOOL success = [[image representationData:0.9f] writeToFile:path atomically:YES];
            
            pthread_rwlock_unlock(lock);
            
            if (completedBlock) { //异步回调
                [blockQueue addOperationWithBlock:^{
                    if (success) {
                        completedBlock(path);
                    }else {
                        completedBlock(nil);
                    }
                }];
            }
        });
        
    }else {
        
        //写上锁
        pthread_rwlock_wrlock(lock);
        
        //生成路径并写入
        NSString * path = [self createCacheFilePathForKey:key];
        BOOL success = [[image representationData:0.9f] writeToFile:path atomically:YES];
        
        pthread_rwlock_unlock(lock);
        
        if (completedBlock) { //同步回调
            if (success) {
                completedBlock(path);
            }else {
                completedBlock(nil);
            }
        }
    }
}

- (NSString *)cacheFilePathForKey:(NSString *)key
{
    if(key) {
        
        pthread_rwlock_t * lock = [[self class] cacheFileLock];
        
        //读上锁
        pthread_rwlock_rdlock(lock);
        
        NSString * filePath = [self createCacheFilePathForKey:key];
        if (!fileExistAtPath(filePath)) {
            filePath = nil;
        }
        
        pthread_rwlock_unlock(lock);
        
        return filePath;
    }
    
    return nil;
}

- (NSURL *)cacheFileURLForKey:(NSString *)key
{
    NSString * path = [self cacheFilePathForKey:key];
    
    if (path.length) {
        return [NSURL fileURLWithPath:path];
    }else {
        return nil;
    }
}

- (NSData *)cacheFileDataForKey:(NSString *)key
{
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    //读上锁
    pthread_rwlock_rdlock(lock);
    
    NSString * filePath = [self createCacheFilePathForKey:key];
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    
    pthread_rwlock_unlock(lock);
    
    
    return data;
}

- (BOOL)hadCacheFileForKey:(NSString *)key {
    return [self cacheFilePathForKey:key] != nil;
}

- (void)removeCacheFileForKey:(NSString *)key async:(BOOL)async {
    [self removeCacheFileForPath:[self cacheFilePathForKey:key] async:async];
}

- (void)removeCacheFileForPath:(NSString *)path async:(BOOL)async
{
    if (path.length) {
        
        pthread_rwlock_t * lock = [[self class] cacheFileLock];
        
        if (async) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //写上锁
                pthread_rwlock_wrlock(lock);
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                pthread_rwlock_unlock(lock);
                
            });
        }else {
            
            //写上锁
            pthread_rwlock_wrlock(lock);
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            pthread_rwlock_unlock(lock);
        }
    }
}

#pragma mark -

- (void)cacheFilesSizeWithCallBackBlock:(void(^)(long long))callBackBlock
{
    [[self class] cacheFilesSizeWithPathType:self.pathType
                         cacheFileFloderName:self.cacheFileFloderName
                               callBackBlock:callBackBlock];
}

- (long long)cacheFilesSize
{
    return [[self class] cacheFilesSizeWithPathType:self.pathType
                                cacheFileFloderName:self.cacheFileFloderName];
}

- (void)clearCacheFilesWithCompletedBlock:(void (^)(void))completedBlock
{
    [[self class] clearCacheFilesWithPathType:self.pathType
                          cacheFileFloderName:self.cacheFileFloderName
                               completedBlock:completedBlock];
}

- (void)clearCacheFiles
{
    [[self class] clearCacheFilesWithPathType:self.pathType
                          cacheFileFloderName:self.cacheFileFloderName];
}

#pragma mark -

+ (void)cacheFilesSizeWithPathType:(MyPathType)pathType
               cacheFileFloderName:(NSString *)cacheFileFloderName
                     callBackBlock:(void (^)(long long))callBackBlock
{
    if (callBackBlock) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            long long size = [self cacheFilesSizeWithPathType:pathType cacheFileFloderName:cacheFileFloderName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                callBackBlock(size);
            });
        });
    }
}

+ (long long)cacheFilesSizeWithPathType:(MyPathType)pathType cacheFileFloderName:(NSString *)cacheFileFloderName
{
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    //读上锁
    pthread_rwlock_rdlock(lock);
    long long size = folderSizeAtPath([self cacheFileFloderPathForType:pathType withCacheFileFloderName:cacheFileFloderName]);
    pthread_rwlock_unlock(lock);
    
    return size;
}

+ (void)allCacheFilesSizeWithCallBackBlock:(void (^)(long long))callBackBlock
{
    if (callBackBlock) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            long long size = [self allCacheFilesSize];
            dispatch_async(dispatch_get_main_queue(), ^{
                callBackBlock(size);
            });
        });
    }
}

+ (long long)allCacheFilesSize
{
    __block long long size = 0;
    
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    //读上锁
    pthread_rwlock_rdlock(lock);
    
    [self _emumAllExistsRootCacheFileFloderDoSomeThing:^(NSString *path, BOOL *stop) {
        size += folderSizeAtPath(path);
    }];
    
    pthread_rwlock_unlock(lock);
    
    return size;
}

+ (void)_emumAllExistsRootCacheFileFloderDoSomeThing:(void(^)(NSString * path, BOOL * stop))block
{
    for (MyPathType pathType = 0; pathType < MyPathTypeCount; pathType ++) {
        
        NSString * path = [[MyPathManager pathForType:pathType] stringByAppendingPathComponent:[MyFileCacheRootFileFloderName stringByAppendingPathComponent:[self cacheRootFileFloderName]]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            BOOL stop = NO;
            
            block(path,&stop);
            
            if (stop) {
                break;
            }
        }
    }
}

+ (void)clearCacheFilesWithPathType:(MyPathType)pathType
                cacheFileFloderName:(NSString *)cacheFileFloderName
                     completedBlock:(void (^)(void))completedBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearCacheFilesWithPathType:pathType cacheFileFloderName:cacheFileFloderName];
        
        if (completedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock();
            });
        }
    });
}

+ (void)clearCacheFilesWithPathType:(MyPathType)pathType
                cacheFileFloderName:(NSString *)cacheFileFloderName
{
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    //写上锁
    pthread_rwlock_wrlock(lock);
    
    removeItemAtPath([self cacheFileFloderPathForType:pathType withCacheFileFloderName:cacheFileFloderName], NO);
    
    pthread_rwlock_unlock(lock);
}

+ (void)clearAllCacheFilesWithCompletedBlock:(void (^)(void))completedBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearAllCacheFiles];
        
        if (completedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock();
            });
        }
    });
}

+ (void)clearAllCacheFiles
{
    pthread_rwlock_t * lock = [[self class] cacheFileLock];
    
    //写上锁
    pthread_rwlock_wrlock(lock);
    
    [self _emumAllExistsRootCacheFileFloderDoSomeThing:^(NSString *path, BOOL *stop) {
        removeItemAtPath(path, NO);
    }];
    
    pthread_rwlock_unlock(lock);
    
   
}


@end
