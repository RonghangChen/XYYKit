//
//  MyFromDataHTTPRequest.m
//  Bestone
//
//  Created by LeslieChen on 14-6-13.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyFromDataHTTPRequest.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface _MyUploadData : NSObject

- (id)initWithData:(NSData *)data
               key:(NSString *)key
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType;

- (id)initWithImage:(UIImage *)image
                key:(NSString *)key
          imageName:(NSString *)imageName
            quality:(CGFloat)compressionQuality;


@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) NSString * fileName;
@property(nonatomic,strong,readonly) NSString * contentType;

@property(nonatomic,strong,readonly) NSData  * data;
@property(nonatomic,strong,readonly) UIImage * image;
@property(nonatomic,readonly) CGFloat compressionQuality;


@end

//----------------------------------------------------------

@implementation _MyUploadData

@synthesize data = _data;

- (id)initWithData:(NSData *)data
               key:(NSString *)key
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType
{
    self = [super init];
    
    if (self) {
        _data = data;
        _fileName = fileName;
        _contentType = contentType;
        _key = key;
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image
                key:(NSString *)key
          imageName:(NSString *)imageName
            quality:(CGFloat)compressionQuality
{
    self = [super init];
    
    if (self) {
        
        _fileName = imageName;
        _contentType = @"image/jpeg";
        _image = image;
        _compressionQuality = compressionQuality;
        _key = key;
    }
    
    return self;
}

- (NSData *)data
{
    if (!_data) {
        @synchronized(self) { //写的时候上锁
            _data = UIImageJPEGRepresentation([_image fixOrientationImage], self.compressionQuality);
            _image = nil;
        }
    }
    
    return _data;
}

@end

//----------------------------------------------------------

@interface MyFromDataHTTPRequest ()

@property(nonatomic,strong,readonly) NSMutableArray * uploadDatas;
@property(nonatomic,strong,readonly) NSString * boundary;

@end

//----------------------------------------------------------


@implementation MyFromDataHTTPRequest
{
    //创建上传数据的标记
    NSString * _createUploadDataMark;
}

@synthesize boundary = _boundary;
@synthesize uploadDatas = _uploadDatas;

- (id)initWithURL:(NSString *)url
       uploadData:(NSData *)data
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType
           forKey:(NSString *)key
{
    return [self initWithURL:url
                  pathFormat:nil
               pathArguments:nil
              queryArguments:nil
             headerArguments:nil
                  uploadData:data
                    fileName:fileName
                 contentType:contentType
                      forKey:key];
}


- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
       uploadData:(NSData *)data
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType
           forKey:(NSString *)key
{
    self = [super initWithURL:url
                   pathFormat:pathFormat
                pathArguments:pathArguments
               queryArguments:queryArguments
              headerArguments:headerArguments];
    
    if (self) {
        [self addData:data fileName:fileName contentType:contentType forKey:key];
    }
    
    return self;
}

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
         bodyData:(NSData *)bodyData
             type:(HTTPRequestType)type
{
    self = [super initWithURL:url
                   pathFormat:pathFormat
                pathArguments:pathArguments
               queryArguments:queryArguments
              headerArguments:nil
                     bodyData:nil
                         type:HTTPRequestTypePost];
    
    if (self) {
        
        //设置头参数
        [self setHeaderArguments:headerArguments];
    }
    
    return self;
}

#pragma mark -

- (NSString *)boundary {
    return  _boundary ?: (_boundary = [NSString uniqueIDString]);
}

- (NSMutableArray *)uploadDatas {
    return _uploadDatas ?: (_uploadDatas = [NSMutableArray array]);
}

- (void)addData:(NSData *)data
       fileName:(NSString *)fileName
    contentType:(NSString *)contentType
         forKey:(NSString *)key
{
    
    if (data == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"data不能为nil"
                                     userInfo:nil];
    }
    
    //添加
    _MyUploadData * uploadData = [[_MyUploadData alloc] initWithData:data
                                                                 key:key
                                                            fileName:fileName
                                                         contentType:contentType];
    [self _addUploadData:uploadData];
}


- (void)_addUploadData:(_MyUploadData *)uploadData
{
    if (_createUploadDataMark) {
        NSLog(@"已开始请求，无法添加数据");
    }
    
    [self.uploadDatas addObject:uploadData];
}

- (void)startRequest
{
    //生成这次操作的mark
    NSString * mark = [NSString uniqueIDString];
    _createUploadDataMark = mark;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //异步生成请求的数据
        NSData * bodyData = [self _bodyDataWithUploadDatas:self.uploadDatas];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //没有被取消
            if ([_createUploadDataMark isEqualToString:mark]) {
                _createUploadDataMark = nil;
                
                [super setBodyData:bodyData];
                [super startRequest];
            }
        });
    });
}

- (NSData *)_bodyDataWithUploadDatas:(NSArray *)uploadDatas
{
    NSMutableData * bodyData = [NSMutableData data];
    
    for (_MyUploadData * uploadData in uploadDatas) {
        
        //添加边界
        NSString * tmpStr = [NSString stringWithFormat:@"--%@\r\n",self.boundary];
        [bodyData appendData:DataWithUTF8Code(tmpStr)];
        
        //设置参数key和名称
        tmpStr = @"Content-Disposition: form-data";
        
        if (uploadData.key.length) { //设置名字
            tmpStr = [tmpStr stringByAppendingFormat:@"; name=\"%@\"",uploadData.key];
        }
        
        if (uploadData.fileName.length) { //设置文件名
            tmpStr = [tmpStr stringByAppendingFormat:@"; filename=\"%@\"",uploadData.fileName];
        }
        
        tmpStr = [tmpStr stringByAppendingString:@"\r\n"];
        [bodyData appendData:DataWithUTF8Code(tmpStr)];
        
        //类型
        if (uploadData.contentType.length) {
            tmpStr = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",uploadData.contentType];
            [bodyData appendData:DataWithUTF8Code(tmpStr)];
        }else{
            [bodyData appendData:DataWithUTF8Code(@"\r\n")];
        }
        
        //数据
        [bodyData appendData:uploadData.data];
        [bodyData appendData:DataWithUTF8Code(@"\r\n")];
    }
    
    //结束符
    if (bodyData.length) {
        NSString * endStr = [NSString stringWithFormat:@"--%@--",self.boundary];
        [bodyData appendData:DataWithUTF8Code(endStr)];
    }
    
    return bodyData;
}

- (void)setRequestType:(HTTPRequestType)type {
    //do nothing
}

- (void)setHeaderArguments:(NSDictionary *)headerArguments
{
    //设置头参数
    NSMutableDictionary * tempHeaderArguments = [NSMutableDictionary dictionaryWithDictionary:headerArguments];
    [tempHeaderArguments setObject:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",self.boundary]
                            forKey:@"Content-Type"];
    
    [super setHeaderArguments:tempHeaderArguments];
}

- (void)setBodyData:(NSData *)bodyData {
    // do nothing
}

- (void)setBodyDataWithBodyArguments:(NSDictionary *)bodyArguments bodyContentType:(HTTPRequestBodyContentType)bodyContentType {
    // do noting
}

- (BOOL)isRequesting {
    return _createUploadDataMark || [super isRequesting];
}

- (void)cancleRequest
{
    _createUploadDataMark = nil;
    [super cancleRequest];
}


@end

//----------------------------------------------------------


@implementation MyFromDataHTTPRequest(image)

- (id)initWithURL:(NSString *)url
      uploadImage:(UIImage *)image
        imageName:(NSString *)imageName
           forKey:(NSString *)key
{
    return [self initWithURL:url
                  pathFormat:nil
               pathArguments:nil
              queryArguments:nil
             headerArguments:nil
                 uploadImage:image
                     quality:1.f
                   imageName:imageName
                      forKey:key];
}

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
      uploadImage:(UIImage *)image
          quality:(CGFloat)compressionQuality
        imageName:(NSString *)imageName
           forKey:(NSString *)key
{
    self = [super initWithURL:url
                   pathFormat:pathFormat
                pathArguments:pathArguments
               queryArguments:queryArguments
              headerArguments:headerArguments];
    
    if (self) {
        [self addImage:image
               quality:compressionQuality
             imageName:imageName
                forKey:key];
    }
    
    return self;
}

- (void)addImage:(UIImage *)image
         quality:(CGFloat)compressionQuality
       imageName:(NSString *)imageName
          forKey:(NSString *)key
{
    if (image == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"image不能为nil"
                                     userInfo:nil];
    }
    
    _MyUploadData * uploadData = [[_MyUploadData alloc] initWithImage:image
                                                                  key:key
                                                            imageName:imageName
                                                              quality:compressionQuality];
    [self _addUploadData:uploadData];
}


@end
