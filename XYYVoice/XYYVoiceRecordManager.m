//
//  MyVoiceRecordManager.m
//  HeiSheHui
//
//  Created by LeslieChen on 15/4/21.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "XYYVoiceRecordManager.h"
#import "XYYFoundation.h"
#import "XYYVoiceUtil.h"
#import <AVFoundation/AVFoundation.h>

//----------------------------------------------------------

@interface XYYVoiceRecordManager () <AVAudioRecorderDelegate>

@property(nonatomic,strong) AVAudioRecorder * audioRecorder;

@end

//----------------------------------------------------------

@implementation XYYVoiceRecordManager

@synthesize voiceDuration = _voiceDuration;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)startRecordVoiceWithVoiceFilePath:(NSString *)voiceFilePath forDuration:(NSTimeInterval)duration
{
    //停止录制
    [self stopRecord];
    
    _voiceFilePath = nil;
    _voiceDuration = 0.0;
    [self _setRecoderStatus:MyRecordVoiceStatusNone];
    
    NSURL * filePathURL = [NSURL fileURLWithPath:voiceFilePath isDirectory:NO];
    if ([filePathURL isFileURL]) {
        
        //检测是否允许使用麦克风
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            
            void(^block)(void) = ^{

                if (granted) {
                    [self _startRecordVoiceWithVoiceFilePath:voiceFilePath forDuration:duration];
                }else {
                    [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:@"应用无权访问您的麦克风,请到\"设置-隐私\"中设置"];
                    [self _postRecordFailMsgWithErrorCode:MyUserDenyRecordErrorCode localizedDescription:@"应用无权访问您的麦克风"];
                }
            };
            
            if ([NSThread isMainThread]) {
                block();
            }else {
                dispatch_async(dispatch_get_main_queue(),block);
            }
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)_startRecordVoiceWithVoiceFilePath:(NSString *)voiceFilePath forDuration:(NSTimeInterval)duration
{
    
    NSMutableDictionary * settings = [NSMutableDictionary dictionaryWithCapacity:5];
    //格式
    [settings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //采样率
    [settings setObject:@(8000.f) forKey:AVSampleRateKey];
    //声道
    [settings setObject:@(1) forKey:AVNumberOfChannelsKey];
    //采样位数
    [settings setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //质量
    [settings setObject:@(AVAudioQualityMedium) forKey:AVEncoderAudioQualityKey];
    
    NSError * error = nil;
    //初始化录音
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:voiceFilePath]
                                                     settings:settings
                                                        error:&error];
    if (!error) {
        
        _voiceFilePath = voiceFilePath;
        self.audioRecorder.delegate = self;
        self.audioRecorder.meteringEnabled = YES;

        //开始准备录音
        [self _setRecoderStatus:MyRecordVoiceStatusPreparing];
        id<XYYVoiceRecordManagerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(voiceRecordManagerStartPreparRecord:)) {
            [delegate voiceRecordManagerStartPreparRecord:self];
        }
        
        //记录当前的录音对象
        AVAudioRecorder * tempAudioRecorder = self.audioRecorder;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //准备录音
            __block BOOL bRet = [tempAudioRecorder prepareToRecord];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.audioRecorder == tempAudioRecorder &&
                    self.recordVoiceStatus == MyRecordVoiceStatusPreparing) { //没有被取消,也没有重新开始
                    
                    if (bRet) {
                        
                        //设置录音策略
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                                         withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                                               error:NULL];
                        //开始录音
                        bRet = duration <= 0 ? [self.audioRecorder record] : [self.audioRecorder recordForDuration:duration];
                    }
                    
                    if (bRet) { //录音成功
                        
                        [self _setRecoderStatus:MyRecordVoiceStatusRecording];
                        id<XYYVoiceRecordManagerDelegate> delegate = self.delegate;
                        ifRespondsSelector(delegate, @selector(voiceRecordManagerDidStartRecord:)) {
                            [delegate voiceRecordManagerDidStartRecord:self];
                        }
                        
                    }else {
                        [self stopRecord];
                        [self _postRecordFailMsgWithErrorCode:MyPreparToRecordErrorCode
                                         localizedDescription:@"准备录音失败"];
                    }
                }
            });
        });
        
    }else {
        
        DefaultDebugLog(@"初始化录音失败 error = %@",error);
        
        self.audioRecorder = nil;
        [self _postRecordFailMsgWithErrorCode:MyInitRecordErrorCode
                         localizedDescription:@"初始化录音失败"];
    }
}

- (void)pauseRecord
{
    if (self.recordVoiceStatus == MyRecordVoiceStatusRecording) {
        [self.audioRecorder pause];
        [self _setRecoderStatus:MyRecordVoiceStatusPaused];
    }
}

- (void)resumeRecord
{
    if (self.recordVoiceStatus == MyRecordVoiceStatusPaused) {
        [self.audioRecorder record];
        [self _setRecoderStatus:MyRecordVoiceStatusRecording];
    }
}

- (void)stopRecord
{
    if (self.audioRecorder) {
        
        _voiceDuration = self.audioRecorder.currentTime;
        self.audioRecorder.delegate = nil;
        [self.audioRecorder stop];
        self.audioRecorder = nil;
        
        [self _setRecoderStatus:MyRecordVoiceStatusEnd];
    }
}

- (NSTimeInterval)voiceDuration {
    return self.audioRecorder ? self.audioRecorder.currentTime : _voiceDuration;
}

#pragma mark -

- (void)_setRecoderStatus:(MyRecordVoiceStatus)status
{
    if (_recordVoiceStatus != status) {
        _recordVoiceStatus = status;
        
        if (status == MyRecordVoiceStatusEnd) {
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVAudioSessionInterruptionNotification
                                                          object:nil];
            
        }else if (status == MyRecordVoiceStatusRecording) {
        
            //移除后添加
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVAudioSessionInterruptionNotification
                                                          object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_audioSessionInterruptionNotification:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:nil];
            
        }
    }
}

- (void)_postRecordFailMsgWithErrorCode:(NSInteger)errorCode
                   localizedDescription:(NSString *)localizedDescription
{
    NSError * error = [NSError errorWithDomain:MyVoiceRecordManagerDomain
                                          code:errorCode
                                      userInfo:localizedDescription ? @{NSLocalizedDescriptionKey : localizedDescription} : nil];
    
    [self _postRecordFailMsgWithError:error];
}

- (void)_postRecordFailMsgWithError:(NSError *)error
{
    id<XYYVoiceRecordManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(voiceRecordManager:recordFailWithError:)) {
        [delegate voiceRecordManager:self recordFailWithError:error];
    }
}

- (void)_postEndRecordMsgWithFinished:(BOOL)finished
{
    id<XYYVoiceRecordManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(voiceRecordManager:didEndRecordWithFinished:)) {
        [delegate voiceRecordManager:self didEndRecordWithFinished:finished];
    }
}

#pragma mark -

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self stopRecord];
    [self _postEndRecordMsgWithFinished:flag];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [self stopRecord];
    [self _postRecordFailMsgWithError:error];
}

- (void)_audioSessionInterruptionNotification:(NSNotification *)notification
{
    if (self.audioRecorder) {
        
        [self stopRecord];
        [self _postEndRecordMsgWithFinished:NO];
        
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVAudioSessionInterruptionNotification
                                                      object:nil];
    }

}

#pragma mark -

- (float)peakVoiceLevel
{
    if (self.audioRecorder) {
        [self.audioRecorder updateMeters];
        return voiceLevelForDecibels_default([self.audioRecorder peakPowerForChannel:0]);
    }
    
    return 0.f;
}


- (float)averageVoiceLevel
{
    if (self.audioRecorder) {
        [self.audioRecorder updateMeters];
        return voiceLevelForDecibels_default([self.audioRecorder averagePowerForChannel:0]);
    }
    
    return 0.f;
}


@end
