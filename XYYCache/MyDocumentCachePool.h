//
//  MyDocumentCachePool.h
//  
//
//  Created by LeslieChen on 15/4/15.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyBasicFileCachePool.h"

@interface MyDocumentCachePool : MyBasicFileCachePool

//共享的文档缓存池
+ (MyDocumentCachePool *)sharePool;
//共享的临时文件缓冲池
+ (MyDocumentCachePool *)shareTempCachePool;

//缓存对象（通过持续化方法）
- (void)cacheKeyedArchiverDataWithRootObject:(id<NSCoding>)object
                                      forKey:(NSString *)key
                                       async:(BOOL)async;

//读取缓存的对象
- (id)cacheKeyedUnArchiverRootObjectForKey:(NSString *)key;
- (id)cacheKeyedUnArchiverRootObjectForKey:(NSString *)key expectType:(Class)expectType;

@end
