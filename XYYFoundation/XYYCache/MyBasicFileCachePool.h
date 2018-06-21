//
//  MyBasicFileCachePool.h
//  
//
//  Created by LeslieChen on 15/4/13.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyPathManager.h"
#import <pthread.h>

//----------------------------------------------------------

//所有的缓存根目录名称
UIKIT_EXTERN NSString * const MyFileCacheRootFileFloderName;

//----------------------------------------------------------

@interface MyBasicFileCachePool : NSObject

//根文件夹名称，由子类实现
+ (NSString *)cacheRootFileFloderName;
//默认的缓存文件夹名字，由子类实现
+ (NSString *)defaultCacheFileFloderName;

/**
 * 通过文件缓存的文件夹名初始化
 * @param pathType pathType为路径类型,默认为MyPathTypeCaches
 * @param cacheFileFloderName cacheFileFloderName文件缓存的文件夹名，该参数为nil则使用默认的defaultCacheFileFloderName
 */
- (id)initWithPathType:(MyPathType)pathType;
- (id)initWithPathType:(MyPathType)pathType andCacheFileFloderName:(NSString *)cacheFileFloderName;


//路径的类型，默认为MyPathTypeCaches
@property(nonatomic,readonly) MyPathType pathType;
@property(nonatomic,copy,readonly) NSString * cacheFileFloderName;

//获取特定类型的缓存文件夹路径,cacheFileFloderName不能为nil
+ (NSString *)cacheFileFloderPathForType:(MyPathType)pathType withCacheFileFloderName:(NSString *)cacheFileFloderName;

//缓存文件夹路径
@property(nonatomic,strong,readonly) NSString * cacheFileFloderPath;

//创建缓存文件路径缓存文件路径
- (NSString *)createCacheFilePathForKey:(NSString *)key;
//由key获取缓存文件名字，默认使用MD5Hash算法得到
+ (NSString *)cacheFileNameForKey:(NSString *)key;

//缓存数据,async代表是否异步
- (NSString *)cacheData:(NSData *)data;
- (void)cacheData:(NSData *)data forKey:(NSString *)key async:(BOOL)async;
- (void)cacheData:(NSData *)data forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void(^)(BOOL success))completedBlock;

//缓存文件
- (NSString *)cacheDataWithFilePath:(NSString *)path;
- (void)cacheDataWithFilePath:(NSString *)path forKey:(NSString *)key async:(BOOL)async;
- (void)cacheDataWithFilePath:(NSString *)path forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void(^)(BOOL success))completedBlock;

/**
 * 缓存图片到文件
 * @param image image为需要缓存的图片,不能为nil，否则将抛出异常
 * @param key key为需要缓存图片的key,不能为nil，否则将抛出异常
 * @param async async指示是否异步缓存，当图片很大时，缓存图片到文件需要一段时间，会造成当前线程卡死，使用异步可解决该问题，默认为同步
 * @param blockQueue blockQueue为block回调的队列对于同步操作改值无效，如果是异步且该值为nil则会使用当前队列回调
 * @param completedBlock completedBlock为回调block，包含图片路径
 */
- (NSString *)cacheImageToFile:(UIImage *)image;
- (void)cacheImageToFile:(UIImage *)image forKey:(NSString *)key async:(BOOL)async;
- (void)cacheImageToFile:(UIImage *)image
                     key:(NSString *)key
                   async:(BOOL)async
              blockQueue:(NSOperationQueue *)blockQueue
          completedBlock:(void(^)(NSString * path))completedBlock;


//返回缓存的文件路径,不存在则返回nil
- (NSString *)cacheFilePathForKey:(NSString *)key;
//返回缓存的文件url,不存在则返回nil
- (NSURL *)cacheFileURLForKey:(NSString *)key;
//返回缓存的文件数据,不存在则返回nil
- (NSData *)cacheFileDataForKey:(NSString *)key;

//是否有缓存文件
- (BOOL)hadCacheFileForKey:(NSString *)key;

//移除缓存文件
- (void)removeCacheFileForKey:(NSString *)key async:(BOOL)async;
- (void)removeCacheFileForPath:(NSString *)path async:(BOOL)async;


/**
 * 获取当前缓存池的文件缓存的大小,单位为byte
 * @param callBackBlock callBackBlock为统计完成后回调的block
 */
- (void)cacheFilesSizeWithCallBackBlock:(void(^)(long long))callBackBlock;
- (long long)cacheFilesSize;

/**
 * 清空当前缓存池的文件缓存
 * @param completedBlock completedBlock为删除完毕后调用的block
 */
- (void)clearCacheFilesWithCompletedBlock:(void(^)(void))completedBlock;
- (void)clearCacheFiles;

/**
 * 获取特定的文件缓存的大小
 * @param pathType pathType为路径类型
 * @param cacheFileFloderName cacheFileFloderName缓存文件夹名称，为nil则为所有
 * @param callBackBlock callBackBlock为统计完成后回调的block
 */
+ (void)cacheFilesSizeWithPathType:(MyPathType)pathType
               cacheFileFloderName:(NSString *)cacheFileFloderName
                     callBackBlock:(void(^)(long long))callBackBlock;
+ (long long)cacheFilesSizeWithPathType:(MyPathType)pathType
                    cacheFileFloderName:(NSString *)cacheFileFloderName;

/**
 * 获取所有缓存文件大小
 * @param callBackBlock callBackBlock为统计完成后回调的block
 */
+ (void)allCacheFilesSizeWithCallBackBlock:(void(^)(long long))callBackBlock;
+ (long long)allCacheFilesSize;


/**
 * 删除特定的缓存文件
 * @param pathType pathType为路径类型
 * @param completeBlock completeBlock为删除完毕后调用的block
 */
+ (void)clearCacheFilesWithPathType:(MyPathType)pathType
                cacheFileFloderName:(NSString *)cacheFileFloderName
                     completedBlock:(void(^)(void))completedBlock;
+ (void)clearCacheFilesWithPathType:(MyPathType)pathType
                cacheFileFloderName:(NSString *)cacheFileFloderName;


/**
 * 删除所有缓存文件
 * @param completeBlock completeBlock为删除完毕后调用的block
 */
+ (void)clearAllCacheFilesWithCompletedBlock:(void (^)(void))completedBlock;
+ (void)clearAllCacheFiles;

@end
