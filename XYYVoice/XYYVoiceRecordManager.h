//
//  MyVoiceRecordManager.h
//  HeiSheHui
//
//  Created by LeslieChen on 15/4/21.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------
//
#define MyVoiceRecordManagerDomain @"MyVoiceRecordManagerDomain"

#define MyPreparToRecordErrorCode  1001  //准备播放错误
#define MyUserDenyRecordErrorCode  1002  //用户拒绝错误
#define MyInitRecordErrorCode      1003  //初始化失败错误


//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyRecordVoiceStatus) {
    MyRecordVoiceStatusNone,        //无状态
    MyRecordVoiceStatusPreparing,   //正在准备
    MyRecordVoiceStatusRecording,   //录制中
    MyRecordVoiceStatusPaused,      //暂停
    MyRecordVoiceStatusEnd          //录制结束
};

//----------------------------------------------------------

@class XYYVoiceRecordManager;

@protocol XYYVoiceRecordManagerDelegate <NSObject>

@optional

//开始准备录制
- (void)voiceRecordManagerStartPreparRecord:(XYYVoiceRecordManager *)voiceRecordManager;
//开始录制,准备完成
- (void)voiceRecordManagerDidStartRecord:(XYYVoiceRecordManager *)voiceRecordManager;

//录制结束，finished指示是否完成设定的长度
- (void)voiceRecordManager:(XYYVoiceRecordManager *)voiceRecordManager didEndRecordWithFinished:(BOOL)finished;

//录制失败
- (void)voiceRecordManager:(XYYVoiceRecordManager *)voiceRecordManager
       recordFailWithError:(NSError *)error;

@end

//----------------------------------------------------------

@interface XYYVoiceRecordManager : NSObject


//开始录制,voiceFilePath为文件路径，duration为录音最大时长，小于等于0则为无限长
- (BOOL)startRecordVoiceWithVoiceFilePath:(NSString *)voiceFilePath forDuration:(NSTimeInterval)duration;

//声音文件的路径
@property(nonatomic,strong,readonly) NSString * voiceFilePath;
//录制状态
@property(nonatomic,readonly) MyRecordVoiceStatus recordVoiceStatus;

//暂停录制
- (void)pauseRecord;
//恢复录制
- (void)resumeRecord;
//停止录音
- (void)stopRecord;

//录制的语音时长
@property(nonatomic,readonly) NSTimeInterval voiceDuration;


//返回声音的分贝大小,大小0.f~1.f之间
- (float)peakVoiceLevel;
//返回声音的平均分贝大小,大小0.f~1.f之间
- (float)averageVoiceLevel;


@property(nonatomic,weak) id<XYYVoiceRecordManagerDelegate> delegate;

@end
