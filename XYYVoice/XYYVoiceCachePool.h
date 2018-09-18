//
//  MyVoiceCachePool.h
//  HeiSheHui
//
//  Created by LeslieChen on 15/4/9.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "XYYCache.h"

//----------------------------------------------------------

@interface XYYVoiceCachePool : MyBasicFileCachePool

+ (instancetype)shareVoiceCachePool;

//缓存
- (BOOL)cacheVoiceWithData:(NSData *)data forKey:(NSString *)key;
- (BOOL)cacheVoiceWithFilePath:(NSString *)path forKey:(NSString *)key;


////返回声音的类型
//+ (MyVoiceType)voiceTypeForData:(NSData *)data;
//
////返回语音转换的临时文件夹
//+ (NSString *)voiceConverterTempFileFloder;

@end
