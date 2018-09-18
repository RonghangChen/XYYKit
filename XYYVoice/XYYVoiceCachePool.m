//
//  MyVoiceCachePool.m
//  HeiSheHui
//
//  Created by LeslieChen on 15/4/9.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "XYYVoiceCachePool.h"
#import "XYYFoundation.h"
#import "VoiceConverter.h"
#include "amrFileCodec.h"

//----------------------------------------------------------

@implementation XYYVoiceCachePool

+ (instancetype)shareVoiceCachePool
{
    static XYYVoiceCachePool * shareVoiceCachePool = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareVoiceCachePool = [[self alloc] init];
    });
    
    return shareVoiceCachePool;
}


+ (NSString *)cacheRootFileFloderName {
    return @"VoiceCache";
}

+ (NSString *)defaultCacheFileFloderName {
    return @"DefaultVoiceCache";
}

#pragma mark -

- (void)cacheData:(NSData *)data forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void (^)(BOOL))completedBlock {
    // do nothing
}

- (void)cacheDataWithFilePath:(NSString *)path forKey:(NSString *)key async:(BOOL)async blockQueue:(NSOperationQueue *)blockQueue completedBlock:(void (^)(BOOL))completedBlock {
    // do nothing
}


- (BOOL)cacheVoiceWithFilePath:(NSString *)path forKey:(NSString *)key
{
    if (path.length == 0 || key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"path和key不能为nil"
                                        userInfo:nil];
    }
    
    NSData * voiceData = [NSData dataWithContentsOfFile:path];
    
    if (voiceData) {
        return [self cacheVoiceWithData:voiceData forKey:key];
    }else {
        NSLog(@"路径为%@的文件不存在或不可读取",path);
        return NO;
    }
}

- (BOOL)cacheVoiceWithData:(NSData *)data forKey:(NSString *)key
{
    if (data == nil || key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"data和key不能为nil"
                                        userInfo:nil];
    }
    
    BOOL bRet = NO;
    
    if ([[self class] _needConvertForData:data]) { //转换格式
        
        NSString * tempFileFloder = [[self class] _voiceConverterTempFileFloder];
        
        NSString * sourceVoicePath = [tempFileFloder stringByAppendingPathComponent:[NSString uniqueIDString]];
        NSString * targetVoicePath = [tempFileFloder stringByAppendingPathComponent:[NSString uniqueIDString]];
        
        //写入文件
        if ([data writeToFile:sourceVoicePath atomically:YES]) {
            
            //格式转换
            bRet = [VoiceConverter amrToWav:sourceVoicePath wavSavePath:targetVoicePath];

            
            if (bRet) { //写入缓存
                [super cacheDataWithFilePath:targetVoicePath forKey:key async:NO blockQueue:nil completedBlock:nil];
            }else {
                NSLog(@"语音格式转换失败");
            }
            
            //删除临时文件
            [[NSFileManager defaultManager] removeItemAtPath:sourceVoicePath error:NULL];
            [[NSFileManager defaultManager] removeItemAtPath:targetVoicePath error:NULL];
            
        }else{
            NSLog(@"临时文件写入失败");
        }
        
    }else {
        
        //写入缓存
        [super cacheData:data forKey:key async:NO blockQueue:nil completedBlock:nil];
        bRet = YES;
        
    }
    
    return bRet;
}

+ (BOOL)_needConvertForData:(NSData *)data
{
    const int AMR_MAGIC_NUMBER_LENGHT = strlen(AMR_MAGIC_NUMBER);
    if (data.length > MAX(sizeof(RIFFHEADER), AMR_MAGIC_NUMBER_LENGHT)) {
        
        //判断是否为arm
        char buffer[AMR_MAGIC_NUMBER_LENGHT];
        [data getBytes:buffer length:AMR_MAGIC_NUMBER_LENGHT];
        if (!strncmp(buffer, AMR_MAGIC_NUMBER, AMR_MAGIC_NUMBER_LENGHT)) {
            return YES;
        }
        
//        else {
//            //读取wav的头
//            RIFFHEADER riff;
//            [data getBytes:&riff length:sizeof(RIFFHEADER)];
//            if (!strncmp(riff.chRiffFormat, "WAVE", sizeof(riff.chRiffFormat))) {
//                type = MyVoiceTypeWAV;
//            }
//        }
    }
    
    return NO;
}

+ (NSString *)_voiceConverterTempFileFloder {
    return [[self class] cacheFileFloderPathForType:MyPathTypeTemp withCacheFileFloderName:@"VoiceConverterTempFile"];
}


@end
