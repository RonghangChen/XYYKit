//
//  MyHTTPRequest.h
//  Bestone
//
//  Created by LeslieChen on 14-6-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

#define DataWithUTF8Code(_str) [_str dataUsingEncoding:NSUTF8StringEncoding]

//----------------------------------------------------------

//请求类型
typedef NS_ENUM(NSUInteger, HTTPRequestType){
    HTTPRequestTypeGet,     //GET
    HTTPRequestTypePost,    //POST
    HTTPRequestTypePut,     //PUT
    HTTPRequestTypeDelete   //DELETE
    
};

//body数据类型
typedef NS_ENUM(NSUInteger, HTTPRequestBodyContentType){
    HTTPRequestBodyContentTypeForm,  //表单
    HTTPRequestBodyContentTypeJson   //json
    
};

//----------------------------------------------------------

@protocol MyHTTPRequestProtocol;

//----------------------------------------------------------

@protocol MyHTTPRequestDelegate <NSObject>

@optional

/**
 * 发送过程委托方法
 * @param request request是当前的请求对象
 * @param sendDataLenght sendDataLenght是已经发送的数据长度，单位是byte
 * @param expectedDataLength expectedDataLength是预期发送的数据总长度，单位是byte
 * @param speed speed是当前发送数据的速度，单位是byte/s
 */
- (void)          httpRequest:(id<MyHTTPRequestProtocol>)request
    didSendHTTPBodyDataLength:(long long)sendDataLenght
           expectedDataLength:(long long)expectedDataLength
                sendDataSpeed:(NSUInteger)speed;

/**
 * 收到响应的委托方法
 * @param request request是当前的请求对象
 * @param response response是收到的响应
 */
- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didReceiveResponse:(NSHTTPURLResponse *)response;

/**
 * 接收过程的委托方法
 * @param request request是当前的请求对象
 * @param receiveDataLength receiveDataLength是已经接收到数据的长度，单位是byte
 * @param expectedDataLength expectedDataLength是预期接收的数据总长度，单位是byte，如果总长度未知则此值为
 *                          NSURLResponseUnknownLength
 * @param speed speed是当前接收数据的速度，单位是byte/s
 */
-  (void)   httpRequest:(id<MyHTTPRequestProtocol>)request
   didReceiveDataLength:(long long)receiveDataLength
     expectedDataLength:(long long)expectedDataLength
       receiveDataSpeed:(NSUInteger)speed;

/**
 * 请求完成的委托方法
 * @param request request是当前的请求对象
 * @param response response是收到的响应
 * @param data data是接收到的数据
 */
- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
                   response:(NSHTTPURLResponse *)response
  didSuccessRequestWithData:(NSData *)data;

/**
 * 请求失败的委托方法
 * @param request request是当前的请求对象
 * @param response response是收到的响应,可能为nil
 * @param error error是请求失败的原因
 */
- (void)        httpRequest:(id<MyHTTPRequestProtocol>)request
                   response:(NSHTTPURLResponse *)response
  didFailedRequestWithError:(NSError *)error;

@end

//----------------------------------------------------------

/**
 * 完成请求的回调block
 * @param response response是收到的响应，可能为nil
 * @param data data是收到的数据，失败是为nil
 * @param error error是请求失败的原因，成功时为nil
 */
typedef void(^HTTPRequestCompletedCallbackBlock)(NSHTTPURLResponse * response, id data, NSError * error);


//----------------------------------------------------------

@protocol MyHTTPRequestProtocol

//http请求
@property(nonatomic,strong,readonly) NSURLRequest * urlRequest;

//开始请求
- (void)startRequest;
- (void)startRequestWithContext:(id)context;

//开始同步请求
- (NSData *)startSynchronousRequestWithReturningResponse:(NSHTTPURLResponse **)response
                                                   error:(NSError **)error;

//取消请求
- (void)cancleRequest;

//是否正在请求
@property(nonatomic,readonly,getter = isRequesting) BOOL requesting;

//代理
@property(nonatomic,weak) id<MyHTTPRequestDelegate> delegate;

//完成请求回调block
@property(nonatomic,copy) HTTPRequestCompletedCallbackBlock completedCallbackBlock;

//上下文
@property(nonatomic,strong,readonly) id context;


@end

//----------------------------------------------------------


@interface MyHTTPRequest : NSObject <MyHTTPRequestProtocol>


//基本的GET请求初始化

- (id)initWithURL:(NSString *)url;
- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments;


//基本的POST请求初始化

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments;

- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments
  bodyContentType:(HTTPRequestBodyContentType)bodyContentType;


- (id)initWithURL:(NSString *)url
       pathFormat:(NSString *)pathFormat
    pathArguments:(NSDictionary *)pathArguments
  headerArguments:(NSDictionary *)headerArguments
         bodyData:(NSData *)bodyData;


//其他初始化方法
- (id)initWithURL:(NSString *)url                       //url
       pathFormat:(NSString *)pathFormat                //路径格式
    pathArguments:(NSDictionary *)pathArguments         //路径参数
   queryArguments:(NSDictionary *)queryArguments        //查询参数
  headerArguments:(NSDictionary *)headerArguments       //头参数
    bodyArguments:(NSDictionary *)bodyArguments         //body参数
             type:(HTTPRequestType)type;                //类型

- (id)initWithURL:(NSString *)url                       //url
       pathFormat:(NSString *)pathFormat                //路径格式
    pathArguments:(NSDictionary *)pathArguments         //路径参数
   queryArguments:(NSDictionary *)queryArguments        //查询参数
  headerArguments:(NSDictionary *)headerArguments       //头参数
    bodyArguments:(NSDictionary *)bodyArguments         //body参数
  bodyContentType:(HTTPRequestBodyContentType)bodyContentType //body参数类型
             type:(HTTPRequestType)type;                //请求类型


- (id)initWithURL:(NSString *)url                       //url
       pathFormat:(NSString *)pathFormat                //路径格式
    pathArguments:(NSDictionary *)pathArguments         //路径参数
   queryArguments:(NSDictionary *)queryArguments        //查询参数
  headerArguments:(NSDictionary *)headerArguments       //头参数
         bodyData:(NSData *)bodyData                    //body数据
             type:(HTTPRequestType)type;                //请求类型


@end

//----------------------------------------------------------

@interface MyHTTPRequest (Mutable)

//请求类型
@property(nonatomic) HTTPRequestType requestType;
//头参数
@property(nonatomic,strong) NSDictionary * headerArguments;

//请求体数据
@property(nonatomic,strong) NSData * bodyData;
//通过body参数设置请求体数据
- (void)setBodyDataWithBodyArguments:(NSDictionary *)bodyArguments bodyContentType:(HTTPRequestBodyContentType)bodyContentType;

@end


