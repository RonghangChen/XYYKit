//
//  NetConnectManager.m
//
//
//  Created by LeslieChen on 14-1-4.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "URLConnectionManager.h"
#import "XYYFoundation.h"
#import <pthread.h>

//----------------------------------------------------------

@interface _URLConnectionDelegateForBlock : NSObject <URLConnectionManagerDelegate>

+ (void)removeAllDelegate;
+ (void)removeDelegate:(_URLConnectionDelegateForBlock *)delegate;

+ (instancetype)createDelegateWithCompletionHander:(MyURLConnectionCompletionBlcok)completionHander;
- (id)initWithCompletionHander:(MyURLConnectionCompletionBlcok)completionHander;

@property(nonatomic,copy,readonly) MyURLConnectionCompletionBlcok completionHander;

@end

//----------------------------------------------------------

@implementation _URLConnectionDelegateForBlock

static pthread_mutex_t d_lock = PTHREAD_MUTEX_INITIALIZER;

+ (NSMutableSet *)delegateSet
{
    static NSMutableSet * delegateSet = nil;
    if (delegateSet == nil) {
        delegateSet = [NSMutableSet set];
    }
    
    return delegateSet;
}

+ (void)removeAllDelegate
{
    pthread_mutex_lock(&d_lock);
    [[self delegateSet] removeAllObjects];
    pthread_mutex_unlock(&d_lock);
}

+ (void)removeDelegate:(_URLConnectionDelegateForBlock *)delegate
{
    pthread_mutex_lock(&d_lock);
    [[self delegateSet] removeObject:delegate];
    pthread_mutex_unlock(&d_lock);
}

+ (instancetype)createDelegateWithCompletionHander:(MyURLConnectionCompletionBlcok)completionHander
{
    _URLConnectionDelegateForBlock * delegate = [[self alloc] initWithCompletionHander:completionHander];
    
    pthread_mutex_lock(&d_lock);
    [[self delegateSet] addObject:delegate];
    pthread_mutex_unlock(&d_lock);
    
    return delegate;
}

- (id)initWithCompletionHander:(MyURLConnectionCompletionBlcok)completionHander
{
    self = [super init];
    if (self) {
        _completionHander = completionHander;
    }
    
    return self;
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                        task:(NSURLSessionTask *)task
                    response:(NSURLResponse *)response
            didFailWithError:(NSError *)error
{
    [[self class] removeDelegate:self];
    
    if (self.completionHander) {
        self.completionHander(response, nil, error);
    }
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                        task:(NSURLSessionTask *)task
                    response:(NSURLResponse *)response
        didFinishLoadingData:(NSData *)data
{
    [[self class] removeDelegate:self];
    
    if (self.completionHander) {
        self.completionHander(response,data,nil);
    }
}

@end


//----------------------------------------------------------

@interface _URLConnectionData : NSObject

//- (id)initWithDelegate:(id<URLConnectionManagerDelegate>)delegate URLConnection:(NSURLConnection *)urlConnection;
- (id)initWithDelegate:(id<URLConnectionManagerDelegate>)delegate taks:(NSURLSessionTask *)task;

@property(nonatomic,strong,readonly) MyWeakDelegate<id<URLConnectionManagerDelegate>> * delegate;

@property(nonatomic,strong,readonly) NSURLSessionTask * task;
@property(nonatomic,strong,readonly) NSMutableData    * resultData;
@property(nonatomic,strong)          NSDate           * lastSendDataDate;
@property(nonatomic,strong,readonly) NSDate           * lastReceiveDataDate;
//@property(nonatomic,readonly) long long expectedDataLength;
//@property(nonatomic,readonly) NSURLResponse * response;

//返回接收数据的速度byte/s
- (NSUInteger)receiveData:(NSData *)data;

//返回发送速度byte/s
- (NSUInteger)speedForSendData:(NSUInteger)bytesWritten;

@end

//----------------------------------------------------------

@implementation _URLConnectionData

- (id)initWithDelegate:(id<URLConnectionManagerDelegate>)delegate taks:(NSURLSessionTask *)task
{
    if (self = [super init]) {
        _delegate = [[MyWeakDelegate alloc] initWithDelegate:delegate];
        _task  = task;
        _resultData = [NSMutableData data];
    }
    
    return self;
}

- (NSURLResponse *)response {
    return _task.response;
}

- (NSUInteger)speedForSendData:(NSUInteger)bytesWritten
{
    NSUInteger sendDataSpeed = 0;
    NSDate * now =  [NSDate date];
    
    //计算速度
    if (_lastSendDataDate) {
        
//        NSLog(@"bytesWritten = %i , time = %f",(int)bytesWritten ,[now timeIntervalSinceDate:_lastSendDataDate]);
        
        sendDataSpeed = bytesWritten / [now timeIntervalSinceDate:_lastSendDataDate];
        
//        NSLog(@" bytesWritten = %i speed = %i byte/s ",(int)bytesWritten,(int)sendDataSpeed);
    }
    
    //记录时间
    _lastSendDataDate = now;
    
    return sendDataSpeed;
}
                            
- (NSUInteger)receiveData:(NSData *)data
{
    MyAssert(data);
    
    NSUInteger receiveDataSpeed = 0;
    NSDate * now =  [NSDate date];
    
    //计算速度
    if (_lastReceiveDataDate) {
        receiveDataSpeed = data.length / [now timeIntervalSinceDate:_lastReceiveDataDate];
    }
    
    //记录时间
    _lastReceiveDataDate = now;
    
    //扩充数据
    [_resultData appendData:data];
    
    return receiveDataSpeed;
}


@end

//----------------------------------------------------------

@interface URLConnectionManager() < NSURLSessionDataDelegate >

@end

//----------------------------------------------------------

@implementation URLConnectionManager
{
    //锁
    pthread_mutex_t _lock;
    
    //url任务
    NSURLSession    * _urlSession;
    
    //代理到数据的映射表
    NSMutableDictionary    *_delegateToDataDicMap;
    //URL连接到数据的映射表
    NSMutableDictionary    *_urlConnectionToDataMap;
}

#pragma mark -

+ (URLConnectionManager *)defaultManager
{
    static URLConnectionManager * defaultManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [URLConnectionManager new];
    });
    
    return defaultManager;
}

- (id)init
{
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        _delegateToDataDicMap = [NSMutableDictionary dictionary];
        _urlConnectionToDataMap = [NSMutableDictionary dictionary];
        
    }
    
    return self;
}

#pragma mark -

- (id<URLConnectionManagerDelegate>)startConnectionWithRequest:(NSURLRequest *)request
                                              completionHander:(MyURLConnectionCompletionBlcok)completionHander
{
    _URLConnectionDelegateForBlock * delegate = [_URLConnectionDelegateForBlock createDelegateWithCompletionHander:completionHander];
    [self startConnection:delegate request:request];
    
    return delegate;
}

- (void)startConnection:(id<URLConnectionManagerDelegate>)delegate request:(NSURLRequest *)request
{
    if (request == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"请求不能为nil"
                                     userInfo:nil];
    }
    
    NSURLSessionDataTask * task = [_urlSession dataTaskWithRequest:request];
    if (task != nil) {
        
        _URLConnectionData *connectionData  = [[_URLConnectionData alloc] initWithDelegate:delegate taks:task];
        
        pthread_mutex_lock(&_lock);
        
        //添加任务
        [_urlConnectionToDataMap setObject:connectionData forKey:@(task.taskIdentifier)];
        id<NSCopying> delegateKey = connectionData.delegate.delegateKey;
        NSMutableSet *dataSet = [_delegateToDataDicMap objectForKey:delegateKey];
        if (dataSet == nil) {
            dataSet = [NSMutableSet set];
            [_delegateToDataDicMap setObject:dataSet forKey:delegateKey];
        }
        [dataSet addObject:connectionData];
        
        pthread_mutex_unlock(&_lock);
  
        //开始连接
        [task resume];
        
    }
}

- (NSData *)startSynchronousRequest:(NSURLRequest *)request
                  returningResponse:(NSURLResponse **)response
                              error:(NSError **)error
{
    if (request == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"请求不能为nil"
                                     userInfo:nil];
    }
    
    //信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    __block NSData * r_data = nil;
    __block NSError * r_error = nil;
    __block NSURLResponse * r_response = nil;
    
    [_urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        r_data = data;
        r_response = response;
        r_error = error;
        
        //发送信号
        dispatch_semaphore_signal(semaphore);
    }];
    
    //等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (response != NULL) {
        *response = r_response;
    }
    if (error != NULL) {
        *error = r_error;
    }
    
    return r_data;
}

#pragma mark -

- (void)cancleConnection:(id<URLConnectionManagerDelegate>)delegate {
    [self cancleConnection:delegate request:nil removeAll:YES];
}

- (void)cancleConnection:(id<URLConnectionManagerDelegate>)delegate request:(NSURLRequest *)request removeAll:(BOOL)removeAll
{
    id<NSCopying> delegateKey = [MyWeakDelegate keyForDelegate:delegate];
    
    pthread_mutex_lock(&_lock);
    
    NSMutableSet * dataSet = [_delegateToDataDicMap objectForKey:delegateKey];
    if (dataSet.count) {
        
        for (_URLConnectionData * connectionData in [dataSet allObjects]) {
            
            if (request == nil || [[connectionData.task originalRequest] isEqual:request]) {
                
                //取消任务
                [connectionData.task cancel];
                
                //移除数据
                [_urlConnectionToDataMap removeObjectForKey:@(connectionData.task.taskIdentifier)];
                [dataSet removeObject:connectionData];
                
                if (!removeAll){
                    break;
                }
            }
        }
        
        //无元素则移除
        if (dataSet.count == 0) {
            [_delegateToDataDicMap removeObjectForKey:delegateKey];
        }
    }
    
    pthread_mutex_unlock(&_lock);
    
    if ([delegate isKindOfClass:[_URLConnectionDelegateForBlock class]]) {
        [_URLConnectionDelegateForBlock removeDelegate:(id)delegate];
    }
}

- (void)cancleAllConnection
{
    pthread_mutex_lock(&_lock);
    
    for (_URLConnectionData * connectionData  in _urlConnectionToDataMap.allValues) {
        [connectionData.task cancel];
    }
    [_urlConnectionToDataMap removeAllObjects];
    [_delegateToDataDicMap removeAllObjects];
    
    pthread_mutex_unlock(&_lock);
    
    [_URLConnectionDelegateForBlock removeAllDelegate];
}

#pragma mark -

- (void)        URLSession:(NSURLSession *)session
                      task:(NSURLSessionTask *)task
           didSendBodyData:(int64_t)bytesSent
            totalBytesSent:(int64_t)totalBytesSent
  totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    pthread_mutex_lock(&_lock);
    
    _URLConnectionData * connectionData  = [_urlConnectionToDataMap objectForKey:@(task.taskIdentifier)];
    
    if (connectionData) {
        
        id<URLConnectionManagerDelegate> delegate = connectionData.delegate.delegate;
        NSUInteger sendDataSpeed = [connectionData speedForSendData:bytesSent];
        
        pthread_mutex_unlock(&_lock);
        
        ifRespondsSelector(delegate, @selector(urlConnectionManager:task:didSendHTTPBodyDataLength:expectedDataLength:sendDataSpeed:)){
            
            [delegate urlConnectionManager:self
                                      task:task
                 didSendHTTPBodyDataLength:totalBytesSent
                        expectedDataLength:totalBytesExpectedToSend
                             sendDataSpeed:sendDataSpeed];
        }
    }else {
       pthread_mutex_unlock(&_lock);
    }
}

- (void)    URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    pthread_mutex_lock(&_lock);
    
    _URLConnectionData *connectionData  = [_urlConnectionToDataMap objectForKey:@(dataTask.taskIdentifier)];
    
    if (connectionData) {
        
        id<URLConnectionManagerDelegate> delegate = connectionData.delegate.delegate;
        pthread_mutex_unlock(&_lock);
        
        ifRespondsSelector(delegate, @selector(urlConnectionManager:task:didReceiveResponse:))  {
            [delegate urlConnectionManager:self task:dataTask didReceiveResponse:response];
        }
        
    }else {
        pthread_mutex_unlock(&_lock);
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    pthread_mutex_lock(&_lock);
    
    _URLConnectionData *connectionData  = [_urlConnectionToDataMap objectForKey:@(dataTask.taskIdentifier)];
    
    if (connectionData ) {
        
        //接收数据
        NSUInteger speed = [connectionData receiveData:data];
        
        long long didReceiveDataLength = dataTask.countOfBytesReceived;
        long long expectedDataLength = dataTask.countOfBytesExpectedToReceive;
        id<URLConnectionManagerDelegate> delegate = connectionData.delegate.delegate;
        
        pthread_mutex_unlock(&_lock);
        
        ifRespondsSelector(delegate, @selector(urlConnectionManager:task:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)){
            
            [delegate urlConnectionManager:self
                                      task:dataTask
                      didReceiveDataLength:didReceiveDataLength
                        expectedDataLength:expectedDataLength
                          receiveDataSpeed:speed];
        }
        
    }else {
        pthread_mutex_unlock(&_lock);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    pthread_mutex_lock(&_lock);
    
    _URLConnectionData * connectionData = [_urlConnectionToDataMap objectForKey:@(task.taskIdentifier)];
    
    if (connectionData) {
        
        //移除请求数据
        [_urlConnectionToDataMap removeObjectForKey:@(connectionData.task.taskIdentifier)];
        id<NSCopying> delegateKey = connectionData.delegate.delegateKey;
        NSMutableSet * dataSet = [_delegateToDataDicMap objectForKey:delegateKey];
        [dataSet removeObject:connectionData];
        if (dataSet.count == 0) {
            [_delegateToDataDicMap removeObjectForKey:delegateKey];
        }
        
        pthread_mutex_unlock(&_lock);
        
        //发送消息
        id<URLConnectionManagerDelegate> delegate = connectionData.delegate.delegate;
        
        if (error == nil) { //成功
            
            ifRespondsSelector(delegate, @selector(urlConnectionManager:task:response:didFinishLoadingData:)) {
                
                [delegate urlConnectionManager:self
                                          task:connectionData.task
                                      response:connectionData.response
                          didFinishLoadingData:connectionData.resultData];
            }
            
        }else { //失败
            
            ifRespondsSelector(delegate, @selector(urlConnectionManager:task:response:didFailWithError:)) {
                
                [delegate urlConnectionManager:self
                                          task:connectionData.task
                                      response:connectionData.response
                              didFailWithError:error];
            }
        }
        
    }else {
        pthread_mutex_unlock(&_lock);
    }
}

#pragma mark -

- (void)    URLSession:(NSURLSession *)session
   didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
     completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if (self.needTrustCredential) { //信任
        if ([challenge previousFailureCount] == 0){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }else{
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
        }
    }else { //默认策略
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
    }
}

@end
