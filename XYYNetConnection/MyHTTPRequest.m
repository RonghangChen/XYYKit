//
//  MyHTTPRequest.m
//  Bestone
//
//  Created by LeslieChen on 14-6-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyHTTPRequest.h"
#import "URLConnectionManager.h"
#import "XYYFoundation.h"
#import "NSString+Net.h"

//----------------------------------------------------------

#define HttpRequestDebugLog(_format,...)  DebugLog(MyHTTPRequestDomain,_format, ##__VA_ARGS__)

//----------------------------------------------------------

@interface MyHTTPRequest () <URLConnectionManagerDelegate>

@end

//----------------------------------------------------------

@implementation MyHTTPRequest
{
    NSString        * _requestURL;
    NSDictionary    * _headerArguments;
    NSData          * _bodyData;
    
    HTTPRequestType   _type;
}

@synthesize completedCallbackBlock = _completedCallbackBlock;
@synthesize delegate     = _delegate;
@synthesize requesting   = _requesting;
@synthesize urlRequest   = _urlRequest;
@synthesize context      = _context;

#pragma mark -

- (id)init
{
    @throw [[NSException alloc] initWithName:NSGenericException
                                      reason:@"MyHTTPRequest不支持无参数初始化"
                                    userInfo:nil];
}

- (id)initWithURL:(NSString *)url
{
    return [self initWithURL:url
                  pathFormat:nil
               pathArguments:nil
              queryArguments:nil
             headerArguments:nil
                    bodyData:nil
                        type:HTTPRequestTypeGet];
}

- (id)initWithURL:(NSString *)url                       //url
       pathFormat:(NSString *)pathFormat                //路径格式(%@)
    pathArguments:(NSDictionary *)pathArguments              //路径参数
   queryArguments:(NSDictionary *)queryArguments        //查询参数
  headerArguments:(NSDictionary *)headerArguments
{
    return [self initWithURL:url
                  pathFormat:pathFormat
               pathArguments:pathArguments
              queryArguments:queryArguments
             headerArguments:headerArguments
                    bodyData:nil
                        type:HTTPRequestTypeGet];
}

- (id)initWithURL:(NSString *)url                       //url
       pathFormat:(NSString *)pathFormat                //路径格式(%@)
    pathArguments:(NSDictionary *)pathArguments              //路径参数
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments
{

    return [self initWithURL:url
                  pathFormat:pathFormat
               pathArguments:pathArguments
             headerArguments:headerArguments
               bodyArguments:bodyArguments
             bodyContentType:HTTPRequestBodyContentTypeForm];
}

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments
  bodyContentType:(HTTPRequestBodyContentType)bodyContentType
{
    return [self initWithURL:url
                  pathFormat:pathFormat
               pathArguments:pathArguments
              queryArguments:nil
             headerArguments:headerArguments
               bodyArguments:bodyArguments
             bodyContentType:bodyContentType
                        type:HTTPRequestTypePost];
}

- (id)initWithURL:(NSString *)url                       //url
       pathFormat:(NSString *)pathFormat                //路径格式(%@)
    pathArguments:(NSDictionary *)pathArguments              //路径参数
  headerArguments:(NSDictionary *)headerArguments
         bodyData:(NSData *)bodyData
{
    return [self initWithURL:url
                  pathFormat:pathFormat
               pathArguments:pathArguments
              queryArguments:nil
             headerArguments:headerArguments
                    bodyData:bodyData
                        type:HTTPRequestTypePost];
}

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments
             type:(HTTPRequestType)type
{
    return [self initWithURL:url
                  pathFormat:pathFormat
               pathArguments:pathArguments
              queryArguments:queryArguments
             headerArguments:headerArguments
               bodyArguments:bodyArguments
             bodyContentType:HTTPRequestBodyContentTypeForm
                        type:type];
    
}

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments
  bodyContentType:(HTTPRequestBodyContentType)bodyContentType
             type:(HTTPRequestType)type
{
    if (bodyArguments.count) {
        
        //设置HTTP头参数
        NSMutableDictionary * tempHeaderArguments = [NSMutableDictionary dictionaryWithDictionary:headerArguments];
        
        if (bodyContentType == HTTPRequestBodyContentTypeForm) {
            [tempHeaderArguments setObject: @"application/x-www-form-urlencoded" forKey:@"Content-Type"];
        }else if (bodyContentType == HTTPRequestBodyContentTypeJson) {
            [tempHeaderArguments setObject:@"application/json" forKey:@"Content-Type"];
        }
        
        headerArguments = tempHeaderArguments;
    }
    
    return [self initWithURL:url
                  pathFormat:pathFormat
               pathArguments:pathArguments
              queryArguments:queryArguments
             headerArguments:headerArguments
                    bodyData:[MyHTTPRequest _dataWithBodyArguments:bodyArguments bodyContentType:bodyContentType]
                        type:type];
}

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
         bodyData:(NSData *)bodyData
             type:(HTTPRequestType)type
{
    if (self = [super init]) {
        
        if (!IS_HTTP_URL(url)) {
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                              reason:@"请求的URL必须为HTTP请求"
                                            userInfo:nil];
        }
        
        //扩展路径
        pathFormat = [pathFormat stringByAddPathArguments:pathArguments];
        if (pathFormat.length) { //移除头尾的/符
            url = [url stringByAppendingFormat:@"/%@",[pathFormat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]]];
        }
        
        //添加查询参数
        url = [url stringByAddQueryArguments:queryArguments];
        
        _requestURL      = url;
        _headerArguments = headerArguments;
        _bodyData        = bodyData;
        _type            = type;
        
    }
    
    return self;
}

+ (NSData *)_dataWithBodyArguments:(NSDictionary *)bodyArguments bodyContentType:(HTTPRequestBodyContentType)bodyContentType
{
    NSMutableData * bodyData = nil;
    if (bodyArguments.count) {
        
        if (bodyContentType == HTTPRequestBodyContentTypeForm) {
            
            bodyData = [NSMutableData data];
            
            BOOL isStart = YES;
            for (NSString * key in bodyArguments.allKeys) {
                
                
#define   addConnectChar()                              \
{                                                       \
    if (!isStart) {                                     \
        [bodyData appendData:DataWithUTF8Code(@"&")];   \
    }else{                                              \
        isStart = NO;                                   \
    }                                                   \
}
                id value = bodyArguments[key];
                
                if ([value isKindOfClass:[NSData class]]) {
                    
                    //添加连接符
                    addConnectChar();
                    
                    NSString * tmpStr = [NSString stringWithFormat:@"%@=",[key description]];
                    [bodyData appendData:DataWithUTF8Code(tmpStr)];
                    [bodyData appendData:(NSData *)value];
                    
                }else {
                    
                    //添加连接符
                    addConnectChar();
                    
                    NSString * tmpStr = [NSString stringWithFormat:@"%@=%@",[key description],value];
                    [bodyData appendData:DataWithUTF8Code(tmpStr)];
                }
            }
            
        }else if (bodyContentType == HTTPRequestBodyContentTypeJson) {
            
            NSError * error = nil;
            bodyData = (id)[NSJSONSerialization dataWithJSONObject:bodyArguments
                                                           options:0
                                                             error:&error];
            
#if DEBUG
            if (error) {
                NSLog(@"body参数有误，无法转换成json数据,error = %@",error);
            }else {
                NSLog(@"转换的body参数json数据为 %@",
                      [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
            }
#endif

        }
    }
    
    return bodyData;
}

- (NSURLRequest *)urlRequest
{
    if (!_urlRequest) {
        
        NSMutableURLRequest * tmpURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_requestURL]];
        
        //设置方法
        switch (_type) {
            case HTTPRequestTypeGet:
                [tmpURLRequest setHTTPMethod:@"GET"];
                break;
            
            case HTTPRequestTypePost:
                [tmpURLRequest setHTTPMethod:@"POST"];
                break;
                
            case HTTPRequestTypePut:
                [tmpURLRequest setHTTPMethod:@"PUT"];
                break;
                
            case HTTPRequestTypeDelete:
                [tmpURLRequest setHTTPMethod:@"DELETE"];
                break;
                
            default:
                break;
        }
        
        
        //设置头参数
        for (id key in _headerArguments.allKeys) {
            [tmpURLRequest addValue:[_headerArguments stringValueForKey:key] forHTTPHeaderField:[key isKindOfClass:[NSString class]] ? key : [key description]];
        }
        
        //设置body
        if (_bodyData) {
            [tmpURLRequest setHTTPBody:_bodyData];
        }
        
        _urlRequest = tmpURLRequest;
    }
    
    return _urlRequest;
}


- (void)_setRequesting:(BOOL)requesting
{
    if (_requesting != requesting) {
        _requesting = requesting;
        
        //设置网络活动指示的显示
        showNetworkActivityIndicator(requesting);
    }
}

- (void)startRequest {
    [self startRequestWithContext:nil];
}

- (void)startRequestWithContext:(id)context
{
    //取消可能的请求
    [self cancleRequest];
    
    _context = context;
    
    HttpRequestDebugLog(@"开始HTTP请求 URL = %@",self.urlRequest.URL);
    
    //开始请求
    [self _setRequesting:YES];
    [[URLConnectionManager defaultManager] startConnection:self request:self.urlRequest];
}

- (NSData *)startSynchronousRequestWithReturningResponse:(NSHTTPURLResponse **)response error:(NSError **)error
{
    //取消可能的请求
    [self cancleRequest];
    
    //开始同步请求
    return [[URLConnectionManager defaultManager] startSynchronousRequest:self.urlRequest
                                                        returningResponse:response
                                                                    error:error];
}

- (void)cancleRequest
{
    if (_requesting) {
        
        //取消连接
        [self _setRequesting:NO];
        [[URLConnectionManager defaultManager] cancleConnection:self];
        
        _context = nil;
    }
}

- (void)    urlConnectionManager:(URLConnectionManager *)manager
                            task:(NSURLSessionTask *)task
       didSendHTTPBodyDataLength:(long long)sendDataLenght
              expectedDataLength:(long long)expectedDataLength
                   sendDataSpeed:(NSUInteger)speed
{
    id<MyHTTPRequestDelegate> delegate = _delegate;
    ifRespondsSelector(delegate, @selector(httpRequest:didSendHTTPBodyDataLength:expectedDataLength:sendDataSpeed:)) {
        
        [delegate       httpRequest:self
          didSendHTTPBodyDataLength:sendDataLenght
                 expectedDataLength:expectedDataLength
                      sendDataSpeed:speed];
    }
    
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                        task:(NSURLSessionTask *)task
          didReceiveResponse:(NSURLResponse *)response
{
    MyAssert([response isKindOfClass:[NSHTTPURLResponse class]]);
    HttpRequestDebugLog(@"response = %@",response);
    
    id<MyHTTPRequestDelegate> delegate = _delegate;
    ifRespondsSelector(delegate, @selector(httpRequest:didReceiveResponse:)){
        [delegate httpRequest:self didReceiveResponse:(id)response];
    }
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                        task:(NSURLSessionTask *)task
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed
{
    id<MyHTTPRequestDelegate> delegate = _delegate;
    ifRespondsSelector(delegate, @selector(httpRequest:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)) {
        
        [delegate   httpRequest:self
           didReceiveDataLength:receiveDataLength
             expectedDataLength:expectedDataLength
               receiveDataSpeed:speed];
    }
}


- (void)urlConnectionManager:(URLConnectionManager *)manager
                        task:(NSURLSessionTask *)task
                    response:(NSURLResponse *)response
        didFinishLoadingData:(NSData *)data
{
    HttpRequestDebugLog(@"receiveData = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [self _setRequesting:NO];
    
    //代理回调
    id<MyHTTPRequestDelegate> delegate = _delegate;
    ifRespondsSelector(delegate, @selector(httpRequest:response:didSuccessRequestWithData:)){
        [delegate httpRequest:self response:(id)response didSuccessRequestWithData:data];
    }
    
    //block回调
    if (self.completedCallbackBlock) {
        self.completedCallbackBlock((id)response,data,nil);
    }
    
    _context = nil;
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                        task:(NSURLSessionTask *)task
                    response:(NSURLResponse *)response
            didFailWithError:(NSError *)error
{
    
    HttpRequestDebugLog(@"error = %@",error);
    
    [self _setRequesting:NO];
    
    //代理回调
    id<MyHTTPRequestDelegate> delegate = _delegate;
    ifRespondsSelector(delegate, @selector(httpRequest:response:didFailedRequestWithError:)){
        [delegate httpRequest:self response:(id)response didFailedRequestWithError:error];
    }
    
    //block会带哦
    if (self.completedCallbackBlock) {
        self.completedCallbackBlock((id)response,nil,error);
    }
    
    _context = nil;
}

@end

//----------------------------------------------------------

@implementation MyHTTPRequest(Mutable)

- (void)_updateRequest
{
    if (_urlRequest) {
        [self cancleRequest];
        _urlRequest = nil;
    }
}

- (HTTPRequestType)requestType {
    return _type;
}

- (void)setRequestType:(HTTPRequestType)type
{
    if (_type != type) {
        _type = type;
        [self _updateRequest];
    }
}

- (NSDictionary *)headerArguments {
    return _headerArguments;
}

- (void)setHeaderArguments:(NSDictionary *)headerArguments
{
    _headerArguments = headerArguments;
    [self _updateRequest];
}

- (NSData *)bodyData {
    return _bodyData;
}
- (void)setBodyData:(NSData *)bodyData
{
    _bodyData = bodyData;
    [self _updateRequest];
}

- (void)setBodyDataWithBodyArguments:(NSDictionary *)bodyArguments bodyContentType:(HTTPRequestBodyContentType)bodyContentType
{
    [self setBodyData:[MyHTTPRequest _dataWithBodyArguments:bodyArguments bodyContentType:bodyContentType]];
}


@end
