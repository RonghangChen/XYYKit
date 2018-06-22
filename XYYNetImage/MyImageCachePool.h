//
//  ImageCachePool.h
//
//
//  Created by LeslieChen on 14-1-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "XYYFoundation.h"
#import "XYYCache.h"

//----------------------------------------------------------

//#warning 目前外部缓存是禁止的，还有待完善和修改

//缓存图片策略
typedef NS_OPTIONS(NSUInteger, MyCacheImagePolicy) {
    MyCacheImagePolicyNone = 0,
    MyCacheImagePolicyUseFileCache  = 1 << 0, //使用文件缓存或缓存到文件
    MyCacheImagePolicyUseOuterCache = 1 << 1, //使用外部缓存或记录外部缓存
    MyCacheImagePolicyDefault = MyCacheImagePolicyUseFileCache |
                                MyCacheImagePolicyUseOuterCache //默认策略
};

//使用外部缓存
#define CacheImageUseOuterCachePolicy(_policy) (_policy & MyCacheImagePolicyUseOuterCache)
//使用文件缓存
#define CacheImageUseFileCachePolicy(_policy) (_policy & MyCacheImagePolicyUseFileCache)

//图片缓存的类型
typedef NS_ENUM(NSInteger, MyImageCacheType) {
    MyImageCacheTypeNone,
    MyImageCacheTypeInsideCache,  //内部内存缓存
    MyImageCacheTypeFileCache,    //文件缓存
    MyImageCacheTypeOuterCache    //外部缓存
};


//----------------------------------------------------------

@class MyImageCachePool;

//----------------------------------------------------------

@protocol MyImageCachePoolDelegate

@optional

/**
 * 缓存池将要从内存移除标识为key图片
 */
- (void)imageCachePool:(MyImageCachePool *)pool willRemoveImage:(UIImage *)image andKey:(NSString *)key;

@end

//----------------------------------------------------------

/**
 * 图片缓存池,缓存图片有三种类型，分别是内部内存缓存，文件缓存和外部缓存。
 * 1.内部内存缓存：内部通过NSCache以键值对的方式缓存一定图片，改缓存大小有一定限制，当缓存的图片超过大小限制会按一定策略清除部分数据。同时也监听了系统
 *   内存警告通知，当收到该通知时会清空所有缓存图片
 * 2.文件缓存：当图片缓存到内存后，如果策略允许，图片也会缓存到文件，文件缓存不会自动清空，需手动清理
 * 3.外部缓存：外部缓存即外部对图片引用的缓存，以键值对的方式弱引用的方式缓存图片，如果外部对图片仍有引用（弱引用还未失效）即可使用该图片，使用该缓存策
 *   略可防止一个图片多次加载
 * 缓存图片的具体过程：首先将图片缓存入内部缓存，如果策略允许，会将图片缓存到文件（同步或异步方式）和以弱引用的方式缓存图片
 * 缓存图片获取的具体过程：如果策略允许，首先会查找内部缓存，然后查找外部缓存，最后查找文件缓存
 * 缓存和获取缓存是线程安全的
 */
@interface MyImageCachePool : MyBasicFileCachePool <NSCacheDelegate>


+ (instancetype)shareImageCachePool;

/**
 * 缓存图片
 * @param image image为需要缓存的图片,不能为nil，否则将抛出异常
 * @param key key为缓存图片的key,唯一标识一个图片,不能为nil，否则将抛出异常。
 *            如果有相同key的图片存在，则会替换该图片，并删除文件缓存
 * @param policy policy为缓存策略，默认为MyCacheImagePolicyDefault，具体见MyCacheImagePolicy定义
 * @param async async指示是否异步缓存，当图片很大时，缓存图片到文件需要一段时间，会造成当前线程卡死，使用异步可解决该问题，默认为异步
 */
- (void)cacheImage:(UIImage *)image key:(NSString *)key;
- (void)cacheImage:(UIImage *)image key:(NSString *)key policy:(MyCacheImagePolicy)policy async:(BOOL)async;



/**
 * 缓存图片通过图片文件，为了提高效率不会判断文件是否为图片，缓存的图片不会读取到内存中
 * @param imageFilePath imageFilePath为需要缓存图片的文件路径,不能为nil，否则将抛出异常
 * @param key key为缓存图片的key,唯一标识一个图片,不能为nil，否则将抛出异常。
 *            如果有相同key的图片存在，则会替换该图片，并删除文件缓存
 * @param async async指示是否异步缓存，当图片很大时，缓存图片到文件需要一段时间，会造成当前线程卡死，使用异步可解决该问题
 */
- (void)cacheImageWithFilePath:(NSString *)imageFilePath key:(NSString *)key async:(BOOL)async;

/**
 * 移除缓存图片
 * @param key key为缓存图片的key，key为nil将不做任何事
 * @param removeFile removeFile指示是否删除文件缓存
 * @param async async指示是否异步删除,默认为异步
 */
- (void)removeCacheImageForKey:(NSString *)key removeFile:(BOOL)removeFile async:(BOOL)async;

/**
 * 获取缓存的缓存图片
 * @param key key为缓存图片的key
 * @param type type为缓存图片的类型
 * @param policy policy为获取缓存策略，默认为MyCacheImagePolicyDefault，具体见MyCacheImagePolicy定义
 * @return 返回标记为key的缓存图片，不存在则返回nil
 */
- (UIImage *)imageWithKey:(NSString *)key;
- (UIImage *)imageWithKey:(NSString *)key policy:(MyCacheImagePolicy)policy type:(MyImageCacheType *)type;


/**
 * 返回是否有缓存
 * @param key key为缓存图片的key
 * @param type type为缓存图片的类型
 * @param policy policy为获取缓存策略，默认为MyCacheImagePolicyDefault，具体见MyCacheImagePolicy定义
 * @return 返回是否有缓存
 */
- (BOOL)hadCacheImageForKey:(NSString *)key;
- (BOOL)hadCacheImageForKey:(NSString *)key policy:(MyCacheImagePolicy)policy type:(MyImageCacheType *)type;


/**
 * 内存缓存最大允许的容量，单位是M，最小应大于1M，当autoChangeCapacity为YES时设置改值将被忽略，默认为30M
 */
@property(nonatomic) NSUInteger maxCapacity;

/**
 * 是否根据可获取内存状况自动改变容量，默认为YES,
 */
@property(nonatomic) BOOL autoChangeCapacity;


///**
// * 外部缓存的最大数量，默认为50,最小为1
// */
//@property(nonatomic) NSUInteger maxOuterCacheCount;
//

/**
 * 清空内部缓存图片
 */
- (void)clearInsideCacheImages;

///**
// * 清空外部缓存图片
// */
//- (void)clearOuterCacheImages;

/**
 * 清空所有图片，内存和文件
  * @param completeBlock completeBlock为删除完毕后调用的block
 */
- (void)clearAllCacheImages:(void(^)(void))callBackBlock;


/**
 * 代理
 */
@property(nonatomic,weak) id<MyImageCachePoolDelegate> delegate;

@end
