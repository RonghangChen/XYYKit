//
//  MyVoicePlayManager.h
//  HeiSheHui
//
//  Created by LeslieChen on 15/4/9.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "XYYVoiceCachePool.h"

//----------------------------------------------------------

UIKIT_EXTERN NSString * MyPlayVoiceStatusChangeNotification;
UIKIT_EXTERN NSString * MyVoiceURLUserInfoKey;
UIKIT_EXTERN NSString * MyPlayVoiceStatusUserInfoKey;

//----------------------------------------------------------

#define VoiceURLWithUserInfo(_info)     _info[MyVoiceURLUserInfoKey]
#define PlayStatusWithUserInfo(_info)   [_info integerValueForKey:MyPlayVoiceStatusUserInfoKey]

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyPlayVoiceStatus) {
    MyPlayVoiceStatusNone,
    MyPlayVoiceStatusLoading,     //正在加载
    MyPlayVoiceStatusPreparing,   //正在准备
    MyPlayVoiceStatusPlaying,     //正在播放
    MyPlayVoiceStatusPlayEnd      //播放结束
};

//----------------------------------------------------------

@interface XYYVoicePlayManager : NSObject

+ (instancetype)shareManager;

//缓存池
@property(nonatomic,strong,readonly) XYYVoiceCachePool * voiceCachePool;

//播放状态
@property(nonatomic,readonly) MyPlayVoiceStatus playStatus;
//当前播放的声音URL
@property(nonatomic,strong,readonly) NSString * voiceURL;


//是否是当前播放的语音
- (BOOL)isCurrentPlayingVoice:(NSString *)voiceURL;


//准备去播放，会开始从网络加载数据如果需要的话，不通知
- (BOOL)prepareToPlayVoiceWithURL:(NSString *)voiceURL;
//播放
- (BOOL)playVoiceWithURL:(NSString *)voiceURL;
//停止播放
- (void)stopPlay;
//是否在加载
- (BOOL)isLoadingForURL:(NSString *)voiceURL;
//取消加载
- (void)cancelLoadingWithURL:(NSString *)voiceURL;

//当前播放的声音的长度
@property(nonatomic,readonly) NSTimeInterval voiceDuration;

//当前播放的声音的长度
@property(nonatomic,readonly) NSTimeInterval playDuration;

//返回播放的分贝大小,大小0.f~1.f
- (float)peakVoiceLevel;
//返回播放的平均分贝大小
- (float)averageVoiceLevel;

@end
