//
//  MySocialShareBaseMessage.h
//  
//
//  Created by LeslieChen on 15/5/6.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyShareMessageType) {
    MyShareMessageTypeNone,   //无消息
    MyShareMessageTypeText,   //文本消息
    MyShareMessageTypeImage,  //图片消息
    MyShareMessageTypeVideo,  //视频消息
    MyShareMessageTypeMusic,  //音频消息
    MyShareMessageTypeWebpage //网页消息
};

//----------------------------------------------------------

@interface MySocialShareBaseMessage : NSObject

- (id)initWithMessageType:(MyShareMessageType)messageType;

@property(nonatomic,readonly) MyShareMessageType messageType;
//默认为YES
@property(nonatomic) BOOL shouldOpenAppInstallPageIfNotAvailable;

//上下文
@property(nonatomic) id context;

@end

//----------------------------------------------------------

@interface MySocialShareTextMessage : MySocialShareBaseMessage

- (id)initWithText:(NSString *)text;
//
@property(nonatomic,strong) NSString * text;

@end

//----------------------------------------------------------

@interface MySocialShareBaseMediaMessage : MySocialShareBaseMessage

- (id)initWithMessageType:(MyShareMessageType)messageType
                    title:(NSString *)title
              description:(NSString *)description
                thumbData:(NSData *)thumbData;

/** 标题
 */
@property (nonatomic,strong) NSString *title;

/** 描述内容
 */
@property (nonatomic,strong) NSString *description;

/** 缩略图数据
 */
@property (nonatomic,strong) NSData   *thumbData;

@end

//----------------------------------------------------------

@interface MySocialShareImageMessage : MySocialShareBaseMediaMessage

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
          imageData:(NSData *)imageData;

/**
 * 图片数据内容
 */
@property (nonatomic,strong) NSData  * imageData;

@end

//----------------------------------------------------------

@interface MySocialShareVideoMessage : MySocialShareBaseMediaMessage

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           videoUrl:(NSString *)videoUrl;

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           videoUrl:(NSString *)videoUrl
     videoStreamUrl:(NSString *)videoStreamUrl;

/**视频网页的url，不能为nil
*/
@property (nonatomic, strong) NSString *videoUrl;

//微信和QQ不支持视频数据流

/**视频数据流url
 */
@property (nonatomic, strong) NSString *videoStreamUrl;

@end

//----------------------------------------------------------

@interface MySocialShareMusicMessage : MySocialShareBaseMediaMessage

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           musicUrl:(NSString *)musicUrl;

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           musicUrl:(NSString *)musicUrl
     musicStreamUrl:(NSString *)musicStreamUrl;

/**
 音乐网页url地址
 */
@property (nonatomic,strong) NSString *musicUrl;

//QQ不支持音乐数据流

/**
 音乐数据流url
 */
@property (nonatomic,strong) NSString *musicStreamUrl;

@end

//----------------------------------------------------------

@interface MySocialShareWebpageMessage : MySocialShareBaseMediaMessage

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
         webpageUrl:(NSString *)webpageUrl;

/** 网页的url地址 , 不能为nil
 */
@property (nonatomic,strong) NSString *webpageUrl;

@end

//----------------------------------------------------------

@interface UIImage (SocialShare)

//生效分享用的封面数据
- (NSData *)shareThumbData;
//生成分享用的图片数据
- (NSData *)shareImageData;

@end




