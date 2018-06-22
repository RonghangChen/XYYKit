//
//  MySocialShareBaseMessage.m
//  
//
//  Created by LeslieChen on 15/5/6.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySocialShareBaseMessage.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@implementation MySocialShareBaseMessage

- (id)init {
    return [self initWithMessageType:MyShareMessageTypeNone];
}

- (id)initWithMessageType:(MyShareMessageType)messageType
{
    self = [super init];
    
    if (self) {
        _messageType = messageType;
        self.shouldOpenAppInstallPageIfNotAvailable = YES;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@implementation MySocialShareTextMessage

- (id)initWithMessageType:(MyShareMessageType)messageType
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"MySocialShareTextMessage只支持initWithText:初始化"
                                 userInfo:nil];
}

- (id)initWithText:(NSString *)text
{
    self = [super initWithMessageType:MyShareMessageTypeText];
    
    if (self) {
        _text = text;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@implementation MySocialShareBaseMediaMessage

@synthesize description = _description;

- (id)initWithMessageType:(MyShareMessageType)messageType
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"不支持initWithMessageType:初始化"
                                 userInfo:nil];
}

- (id)initWithMessageType:(MyShareMessageType)messageType
                    title:(NSString *)title
              description:(NSString *)description
                thumbData:(NSData *)thumbData
{
    self = [super initWithMessageType:messageType];
    
    if (self) {
        _title = title;
        _description = description;
        
        //缩略图不能大于32K
        if (thumbData.length >= 32 * 1024) {
            _thumbData = nil;
            NSLog(@"分享缩略图尺寸大于32K，将不显示");
        }else {
            _thumbData = thumbData;
        }
    }
    
    return self;
}


@end

//----------------------------------------------------------

@implementation MySocialShareImageMessage

- (id)initWithMessageType:(MyShareMessageType)messageType
                    title:(NSString *)title
              description:(NSString *)description
                thumbData:(NSData *)thumbData
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"MySocialShareImageMessage不支持该方法初始化"
                                 userInfo:nil];
}

//- (id)initWithDescription:(NSString *)description imageData:(NSData *)imageData {
//    return [self initWithTitle:nil description:description thumbData:nil imageData:imageData];
//}

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
          imageData:(NSData *)imageData
{
    MyAssert(imageData != nil);
    
    self = [super initWithMessageType:MyShareMessageTypeImage
                                title:title
                          description:description
                            thumbData:thumbData];
    
    if (self) {
        _imageData = imageData;
    }
    
    return self;
}

//- (id)initWithTitle:(NSString *)title
//        description:(NSString *)description
//          thumbData:(NSData *)thumbData
//          imageUrl:(NSString *)imageUrl
//{
//    assert(imageUrl != nil);
//    
//    self = [super initWithMessageType:MyShareMessageTypeImage
//                                title:title
//                          description:description
//                            thumbData:thumbData];
//    
//    if (self) {
//        _imageUrl = imageUrl;
//    }
//    
//    return self;
//}

@end

//----------------------------------------------------------

@implementation MySocialShareVideoMessage

- (id)initWithMessageType:(MyShareMessageType)messageType
                    title:(NSString *)title
              description:(NSString *)description
                thumbData:(NSData *)thumbData
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"MyShareVideoMessage不支持该方法初始化"
                                 userInfo:nil];
}

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           videoUrl:(NSString *)videoUrl
{
    return [self initWithTitle:title
                   description:description
                     thumbData:thumbData
                      videoUrl:videoUrl
                videoStreamUrl:nil];
}


- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           videoUrl:(NSString *)videoUrl
     videoStreamUrl:(NSString *)videoStreamUrl
{
    MyAssert(videoUrl != nil);
    
    self = [super initWithMessageType:MyShareMessageTypeVideo
                                title:title
                          description:description
                            thumbData:thumbData];
    
    if (self) {
        _videoUrl = videoUrl;
        _videoStreamUrl = videoStreamUrl;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@implementation MySocialShareMusicMessage

- (id)initWithMessageType:(MyShareMessageType)messageType
                    title:(NSString *)title
              description:(NSString *)description
                thumbData:(NSData *)thumbData
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"MyShareMusicMessage不支持该方法初始化"
                                 userInfo:nil];
}

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           musicUrl:(NSString *)musicUrl
{
    return [self initWithTitle:title
                   description:description
                     thumbData:thumbData
                      musicUrl:musicUrl
                musicStreamUrl:nil];
}


- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
           musicUrl:(NSString *)musicUrl
     musicStreamUrl:(NSString *)musicStreamUrl
{
    MyAssert(musicUrl != nil);
    
    self = [super initWithMessageType:MyShareMessageTypeMusic
                                title:title
                          description:description
                            thumbData:thumbData];
    
    if (self) {
        _musicUrl = musicUrl;
        _musicStreamUrl = musicStreamUrl;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@implementation MySocialShareWebpageMessage

- (id)initWithMessageType:(MyShareMessageType)messageType
                    title:(NSString *)title
              description:(NSString *)description
                thumbData:(NSData *)thumbData
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"MyShareMusicMessage不支持该方法初始化"
                                 userInfo:nil];
}

- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
          thumbData:(NSData *)thumbData
         webpageUrl:(NSString *)webpageUrl
{
    MyAssert(webpageUrl != nil);
    
    self = [super initWithMessageType:MyShareMessageTypeWebpage
                                title:title
                          description:description
                            thumbData:thumbData];
    
    if (self) {
        _webpageUrl = webpageUrl;
    }
    
    return self;
}


@end


@implementation UIImage (SocialShare)

//生效分享用的封面数据
- (NSData *)shareThumbData { //小于32K
    return [[self thumbnailWithSize:75.f] representationWithMaxSize:32000];
}

//生成分享用的图片数据
- (NSData *)shareImageData {//小于10M
    return [self representationWithMaxSize:10000000];
}


@end

