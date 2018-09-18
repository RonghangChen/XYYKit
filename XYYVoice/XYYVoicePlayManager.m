//
//  MyVoicePlayManager.m
//  HeiSheHui
//
//  Created by LeslieChen on 15/4/9.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "XYYVoicePlayManager.h"
#import "XYYVoiceUtil.h"
#import "XYYNetConnection.h"
#import <AVFoundation/AVFoundation.h>

//----------------------------------------------------------

NSString * MyPlayVoiceStatusChangeNotification = @"MyPlayVoiceStatusChangeNotification";
NSString * MyVoiceURLUserInfoKey = @"MyVoiceURLUserInfoKey";
NSString * MyPlayVoiceStatusUserInfoKey = @"MyPlayVoiceStatusUserInfoKey";

//----------------------------------------------------------

@interface XYYVoicePlayManager () < AVAudioPlayerDelegate,
                                   MyHTTPRequestDelegate >

@property(nonatomic,strong) AVAudioPlayer * audioPlayer;
//请求的字典
@property(nonatomic,strong,readonly) NSMutableDictionary * requestDics;
//是否需要恢复其它app的播放
@property BOOL needResumeOtherAppsPlay;

@end

//----------------------------------------------------------

@implementation XYYVoicePlayManager

@synthesize voiceCachePool = _voiceCachePool;
@synthesize requestDics = _requestDics;

#pragma mark -

+ (instancetype)shareManager
{
    static XYYVoicePlayManager * shareManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[super allocWithZone:nil] init];
    });
    
    return shareManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        if ([[UIDevice currentDevice] isProximityMonitoringEnabled]) { //设置后还为NO说明不支持距离感应器
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            
            //添加通知
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_deviceProximityStateDidChangeNotification:)
                                                         name:UIDeviceProximityStateDidChangeNotification
                                                       object:nil];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (XYYVoiceCachePool *)voiceCachePool {
    return [XYYVoiceCachePool shareVoiceCachePool];
}

#pragma mark -

- (BOOL)prepareToPlayVoiceWithURL:(NSString *)voiceURL
{
    BOOL bRet = NO;
    
    if (voiceURL) {
        
        //如果没有缓存开始加载
        if (![self.voiceCachePool hadCacheFileForKey:voiceURL]) {
            [self _startLoadingVoice:voiceURL];
            return YES;
        }
    }
    
    return bRet;
}

- (BOOL)isCurrentPlayingVoice:(NSString *)voiceURL {
    return [self.voiceURL isEqual:voiceURL];
}

- (BOOL)playVoiceWithURL:(NSString *)voiceURL
{
    [self stopPlay];
    
    _voiceURL = voiceURL;
    _playStatus = MyPlayVoiceStatusNone;
    
    //开始播放
    return [self _tryStartPlayVoice];
}

- (void)stopPlay
{
    if (self.voiceURL) {
        
        [self cancelLoadingWithURL:self.voiceURL];
        
        [self _endPlay];
        [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusPlayEnd];
        
        _voiceURL = nil;
    }
}

#pragma mark -

- (NSMutableDictionary *)requestDics {
    return _requestDics ?: (_requestDics = [NSMutableDictionary dictionary]);
}

- (BOOL)isLoadingForURL:(NSString *)voiceURL {
    return [self.requestDics objectForKey:voiceURL] != nil;
}

- (void)cancelLoadingWithURL:(NSString *)voiceURL
{
    id value = [self.requestDics objectForKey:voiceURL];
    
    if (value) {
        
        [self.requestDics removeObjectForKey:voiceURL];
        if ([value isKindOfClass:[MyHTTPRequest class]]) {
            [value cancleRequest];
        }
        
        if ([self isCurrentPlayingVoice:voiceURL]) {
            [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusPlayEnd];
        }
    }
}

- (void)_startLoadingVoice:(NSString *)voiceURL
{
    if (![self.requestDics objectForKey:voiceURL]) {
        
        NSURL * tempVoiceURL = [NSURL URLWithString:voiceURL];
        if ([tempVoiceURL isFileURL]) { // 文件
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL success = [self.voiceCachePool cacheVoiceWithFilePath:[tempVoiceURL path] forKey:voiceURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _endloadingVoiceWithURL:voiceURL success:success];
                });
            });
            
            [self.requestDics setObject:voiceURL forKey:voiceURL];
            
        }else{
            
            //开始网络请求
            MyHTTPRequest * httpRequest = [[MyHTTPRequest alloc] initWithURL:voiceURL];
            httpRequest.delegate = self;
            [httpRequest startRequestWithContext:voiceURL];
            
            [self.requestDics setObject:httpRequest forKey:voiceURL];
        }
    }
}

- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
                   response:(NSHTTPURLResponse *)response
  didFailedRequestWithError:(NSError *)error
{
    [self _endloadingVoiceWithURL:[request context] success:NO];
}

- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
                   response:(NSHTTPURLResponse *)response
  didSuccessRequestWithData:(NSData *)data
{
    NSString * voiceURL = [request context];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [self.voiceCachePool cacheVoiceWithData:data forKey:voiceURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _endloadingVoiceWithURL:voiceURL success:success];
        });
    });
}

- (void)_endloadingVoiceWithURL:(NSString *)voiceURL success:(BOOL)success
{
    if ([self isLoadingForURL:voiceURL]) {
        [self.requestDics removeObjectForKey:voiceURL];
        
        //是否是当前播放的音频
        if ([self isCurrentPlayingVoice:voiceURL]) {
            
            if (!success || ![self _tryStartPlayVoice]) {
                [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusPlayEnd];
            }
        }
    }
}

#pragma mark -

- (BOOL)_tryStartPlayVoice
{
    if (self.voiceURL) {
        
        //读取缓存
        NSString * playVoiceFilePath = [self.voiceCachePool cacheFilePathForKey:self.voiceURL];
        
        NSURL * voiceURL = [NSURL URLWithString:self.voiceURL];
        if (!playVoiceFilePath && [voiceURL isFileURL]) {
            playVoiceFilePath = [voiceURL path];
        }
        
        //是文件
        if (playVoiceFilePath) { //尝试播放
            
            NSError * error = nil;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:playVoiceFilePath] error:&error];
            
            if (!error) {
                
                self.audioPlayer.delegate = self;
                self.audioPlayer.meteringEnabled = YES;
                
                //准备播放
                [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusPreparing];
                
                AVAudioPlayer * tempAudioPlayer = self.audioPlayer;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    self.needResumeOtherAppsPlay = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
                    __block BOOL bRet = [tempAudioPlayer prepareToPlay]; //准备播放
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.playStatus == MyPlayVoiceStatusPreparing && self.audioPlayer == tempAudioPlayer) { //没有取消
                            
                            if (bRet) { //准备成功
                                
                                //设置播放策略
                                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                                 withOptions:0
                                                                       error:NULL];
                                //开始播放
                                bRet = [self.audioPlayer play];
                            }
                            
                            if (bRet) { // 播放成功
                                [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusPlaying];
                            }else {
                                [self stopPlay];
                                DefaultDebugLog(@"播放音频失败,path = %@",playVoiceFilePath);
                            }
                        }
                    });
                });
                
                return YES;
                
            }else{
                
                self.audioPlayer = nil;
                
                if (self.playStatus == MyPlayVoiceStatusLoading) {
                    DefaultDebugLog(@"播放音频失败。error = %@",error);
                    return NO;
                }else {
                   DefaultDebugLog(@"直接打开音频或打开缓存音频失败，开始重新加载。error = %@",error);
                }
            }
        }
        
        //开始加载
        [self _startLoadingVoice:self.voiceURL];
        [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusLoading];
        
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (void)_postVoicePlayStatusChangeNotificationWithPlayStatus:(MyPlayVoiceStatus)playStatus
{
    if (_playStatus != playStatus) {
        
        MyAssert(self.voiceURL);
        
        _playStatus = playStatus;
        [[NSNotificationCenter defaultCenter] postNotificationName:MyPlayVoiceStatusChangeNotification
                                                            object:self
                                                          userInfo:@{MyVoiceURLUserInfoKey : self.voiceURL , MyPlayVoiceStatusUserInfoKey : @(playStatus)}];
     
        //传感器,开始或结束播放
        if (_playStatus == MyPlayVoiceStatusPlayEnd) {
            
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            
            if (self.needResumeOtherAppsPlay) { // 恢复其它app的播放
                [[AVAudioSession sharedInstance] setActive:NO error:NULL];
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVAudioSessionInterruptionNotification
                                                          object:nil];
            
        }else if(_playStatus == MyPlayVoiceStatusPlaying) {
            
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            
            //观察
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_audioSessionInterruptionNotification:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:nil];

        }
    }
}


#pragma mark -

//出现错误或打断直接结束播放

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.audioPlayer == player) {
        [self _endPlay];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (self.audioPlayer == player) {
        [self _endPlay];
    }
}

- (void)_audioSessionInterruptionNotification:(NSNotification *)notification
{
    if (self.audioPlayer) {
        [self _endPlay];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVAudioSessionInterruptionNotification
                                                      object:nil];
    }
}

- (void)_endPlay
{
    if (self.audioPlayer) {
        
        self.audioPlayer.delegate = nil;
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        
        [self _postVoicePlayStatusChangeNotificationWithPlayStatus:MyPlayVoiceStatusPlayEnd];
    }
}

#pragma mark -

- (void)_deviceProximityStateDidChangeNotification:(NSNotification *)notification
{
    if ([UIDevice currentDevice].proximityState) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                               error:NULL];
    }else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                         withOptions:0
                                               error:NULL];
        
        if (!self.audioPlayer.isPlaying) { // 没有播放可以关掉感应器
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

#pragma mark -

- (NSTimeInterval)voiceDuration
{
    if (self.audioPlayer) {
        return self.audioPlayer.duration;
    }
    
    return 0.f;
}

- (NSTimeInterval)playDuration
{
    if (self.audioPlayer) {
        return self.audioPlayer.currentTime;
    }
    
    return 0.f;
}

- (float)peakVoiceLevel
{
    if (self.audioPlayer) {
        [self.audioPlayer updateMeters];
        return voiceLevelForDecibels_default([self.audioPlayer peakPowerForChannel:0]);
    }
    
    return 0.f;
}


- (float)averageVoiceLevel
{
    if (self.audioPlayer) {
        [self.audioPlayer updateMeters];
        return voiceLevelForDecibels_default([self.audioPlayer averagePowerForChannel:0]);
    }
    
    return 0.f;
}

@end


