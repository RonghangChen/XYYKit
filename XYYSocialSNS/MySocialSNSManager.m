//
//  ED_ShareManager.m
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySocialSNSManager.h"
#import "XYYFoundation.h"
#import <objc/message.h>

//----------------------------------------------------------

//判断是否属于某各类
#define XYY_SOCIAL_IS_KIND_OF_CLASS(obj,className) \
({\
    Class class = objc_getClass(className); \
    class != nil && [obj isKindOfClass: class]; \
})

//发送getter消息
#define XYY_SOCIAL_GET_MSG_SEND(rType,obj,selName) ((rType(*)(id,SEL))objc_msgSend)(obj,sel_registerName(selName))

//发送setter消息
#define XYY_SOCIAL_SET_MSG_SEND(vType,obj,selName,value) ((void(*)(id,SEL,vType))objc_msgSend)(obj,sel_registerName(selName),value)


//----------------------------------------------------------

//错误域
NSString * const MySocialSNSErrorDomain = @"MySocialSNSErrorDomain";

//错误创建
#define SOCIALSNSERROR_CREATE(_code,_des) ERROR_CREATE(MySocialSNSErrorDomain, _code, _des, nil)
#define MySocialSNSManagerLocalizedString(key) NSLocalizedStringFromTable(key, @"MySocialSNSManagerLocalizedString", nil)

//----------------------------------------------------------

@implementation MySocialSNSPayContext

- (id)initWXPayContextWithPartnerId:(NSString *)partnerId
                           prepayId:(NSString *)prepayId
                           nonceStr:(NSString *)nonceStr
                          timestamp:(NSUInteger)timestamp
                            package:(NSString *)package
                               sign:(NSString *)sign
{
    self = [super init];
    if (self) {
        _partnerId = partnerId;
        _prepayId = prepayId;
        _nonceStr = nonceStr;
        _timestamp = timestamp;
        _package = package;
        _sign = sign;
    }
    
    return self;
}

- (id)initAliPayContextWithOrderStr:(NSString *)orderStr
{
    self = [super init];
    if (self) {
        _orderStr = orderStr;
    }
    
    return self;
}

@end

//----------------------------------------------------------

//操作的类型
typedef NS_ENUM(NSInteger, _MySocialSNSHandleType) {
    //分享
    _MySocialSNSHandleTypeShare,
    //授权登录
    _MySocialSNSHandleTypeSSO,
    //支付
    _MySocialSNSHandleTypePay
};

//----------------------------------------------------------

@interface _MySocialSNSContext : NSObject

- (id)initWithHandleType:(_MySocialSNSHandleType)handleType
                  target:(MySocialSNSTargetItem *)target
                delegate:(id<MySocialSNSDelegate>)delegate
      baseViewController:(UIViewController *)baseViewController
                    info:(id)info;

//操作类型
@property(nonatomic,readonly) _MySocialSNSHandleType handleType;
//目标
@property(nonatomic,strong,readonly) MySocialSNSTargetItem * target;
//回调代理
@property(nonatomic,weak,readonly) id<MySocialSNSDelegate> delegate;

//基于的VC
@property(nonatomic,weak,readonly) UIViewController * baseViewController;

//扩展信息，不同类型上下文具有不同的扩展信息，比如分享，这块是MySocialShareBaseMessage
@property(nonatomic,strong,readonly) id info;

@end

//----------------------------------------------------------

@implementation _MySocialSNSContext

- (id)initWithHandleType:(_MySocialSNSHandleType)handleType
                  target:(MySocialSNSTargetItem *)target
                delegate:(id<MySocialSNSDelegate>)delegate
      baseViewController:(UIViewController *)baseViewController
                    info:(id)info
{
    self = [super init];
    if (self) {
        
        _handleType = handleType;
        _info = info;
        _target = target;
        _delegate = delegate;
        _baseViewController = baseViewController;
    }
    
    return self;
}

@end

//----------------------------------------------------------

//统一各平台的接口
@protocol _MySocialSNSTargetProtocol

//基于的类别
+ (Class)baseClass;

//名称
+ (NSString *)appName;
//是否安装应用
+ (BOOL)isAppInstalled;
//是否支持分享
+ (MySocialSNSTargetSupportResultType)isAppSupportShare;
//是否支持授权
+ (MySocialSNSTargetSupportResultType)isAppSupportSSO;
//是否支持第三方支付
+ (MySocialSNSTargetSupportResultType)isAppSupportPay;

//应用安装的url
+ (NSString *)appInstallUrl;

//注册
+ (BOOL)registerAppWithInfo:(NSDictionary *)info;
//处理url
+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context;

//开始分享
+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context;
//开始认证
+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context;
//开始支付
+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context;

@end

//----------------------------------------------------------

@interface MyWXApi : NSObject <_MySocialSNSTargetProtocol>

@end

//----------------------------------------------------------

@interface MyQQApi : NSObject <_MySocialSNSTargetProtocol>

+ (id)tencentOAuth;

@end

//----------------------------------------------------------

@interface MyWeiboApi : NSObject<_MySocialSNSTargetProtocol>

@end

//----------------------------------------------------------

@protocol MyAlipaySDKDelegate <NSObject>

- (void)alipayDidCompletedWithResult:(NSDictionary *)result;

@end

@interface MyAlipayApi : NSObject<_MySocialSNSTargetProtocol>

@end

//----------------------------------------------------------

@interface MySocialSNSManager () < MyAlipaySDKDelegate >

//身份信息
@property(nonatomic,strong,readonly) NSMutableDictionary * socialSNSTargetIdentifyInfos;

//上下文
@property(nonatomic,strong) _MySocialSNSContext * context;


@end

//----------------------------------------------------------

@implementation MySocialSNSManager

@synthesize socialSNSTargetIdentifyInfos = _socialSNSTargetIdentifyInfos;

#pragma mark - life circle

+ (MySocialSNSManager *)shareManager
{
    static MySocialSNSManager * shareManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[super allocWithZone:nil] init];
    });
    
    return shareManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

#pragma mark -

//返回第三方分享平台的app的名称（有的目标可能同属一个APP）
+ (NSString *)_socialSNSTargetAppNameForName:(MySocialSNSTargetItemName)name
{
    if ([name isEqualToString:MySocialSNSTargetItemNameWeChatCircle]) {
        return MySocialSNSTargetItemNameWeChat;
    }else if([name isEqualToString:MySocialSNSTargetItemNameQQZone]){
        return MySocialSNSTargetItemNameQQ;
    }
    
    return name;
}

- (NSMutableDictionary *)socialSNSTargetIdentifyInfos
{
    if (!_socialSNSTargetIdentifyInfos) {
        _socialSNSTargetIdentifyInfos = [NSMutableDictionary dictionaryWithContentsOfFile:PlistResourceFilePath(@"MySocialSNSTargetIdentifyInfos")];
    }
    
    return _socialSNSTargetIdentifyInfos;
}

+ (NSDictionary *)_socialSNSTargetIdentifyInfo:(MySocialSNSTargetItemName)targetItmeName {
    return [self shareManager].socialSNSTargetIdentifyInfos[[self _socialSNSTargetAppNameForName:targetItmeName]];
}


+ (BOOL)hasSocialSNSTargetIdentifyInfo:(MySocialSNSTargetItemName)targetItmeName {
    return [self _socialSNSTargetIdentifyInfo:targetItmeName] != nil;
}

#pragma mark -

+ (Class<_MySocialSNSTargetProtocol>)_shareTargetClassForName:(MySocialSNSTargetItemName)name
{
    Class<_MySocialSNSTargetProtocol> apiClass = nil;
    if ([name isEqualToString:MySocialSNSTargetItemNameWeChat] ||
        [name isEqualToString:MySocialSNSTargetItemNameWeChatCircle]) {
        apiClass = [MyWXApi class];
    }else if([name isEqualToString:MySocialSNSTargetItemNameQQ] ||
             [name isEqualToString:MySocialSNSTargetItemNameQQZone]){
        apiClass = [MyQQApi class];
    }else if ([name isEqualToString:MySocialSNSTargetItemNameWeibo]) {
        apiClass = [MyWeiboApi class];
    }else if ([name isEqualToString:MySocialSNSTargetItemNameAlipay]) {
        apiClass = [MyAlipayApi class];
    }
    
    return [apiClass baseClass] ? apiClass : nil;
}

+ (BOOL)isInstallSocialSNSTargetSDK:(MySocialSNSTargetItemName)targetItmeName {
    return [self _shareTargetClassForName:targetItmeName] != nil;
}

+ (BOOL)isInstallSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName
{
    Class<_MySocialSNSTargetProtocol> class = [self _shareTargetClassForName:targetItmeName];
    return class ? [class isAppInstalled] : NO;
}

+ (MySocialSNSTargetSupportResultType)isSupportShareForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName
{
    Class<_MySocialSNSTargetProtocol> class = [self _shareTargetClassForName:targetItmeName];
    return class ? [class isAppSupportShare] : MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (MySocialSNSTargetSupportResultType)isSupportSSOForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName
{
    Class<_MySocialSNSTargetProtocol> class = [self _shareTargetClassForName:targetItmeName];
    return class ? [class isAppSupportSSO] : MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (MySocialSNSTargetSupportResultType)isSupportPayForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName
{
    Class<_MySocialSNSTargetProtocol> class = [self _shareTargetClassForName:targetItmeName];
    return class ? [class isAppSupportPay] : MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (NSString *)appNameForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName
{
    Class<_MySocialSNSTargetProtocol> class = [self _shareTargetClassForName:targetItmeName];
    return class ?  [class appName] : nil;
}

#pragma mark -

+ (void)applicationDidFinishLaunching
{
    //注册key
    NSMutableDictionary * socialSNSTargetIdentifyInfos = [self shareManager].socialSNSTargetIdentifyInfos;
    NSMutableArray * registerFailTargetNames = [NSMutableArray arrayWithCapacity:socialSNSTargetIdentifyInfos.count];
    
    for (NSString * name in socialSNSTargetIdentifyInfos.allKeys) { //注册APP身份信息
        NSDictionary * identifyInfo = socialSNSTargetIdentifyInfos[name];
        Class<_MySocialSNSTargetProtocol> class = [self _shareTargetClassForName:name];
        if (class == nil || ![class registerAppWithInfo:identifyInfo]) {
            [registerFailTargetNames addObject:name];
        }
    }
    
    //移除注册失败的目标
    [socialSNSTargetIdentifyInfos removeObjectsForKeys:registerFailTargetNames];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    _MySocialSNSContext * context = [self shareManager].context;
    if (context != nil) {
        return [[self _shareTargetClassForName:context.target.name] handleOpenURL:url withContext:context];
    }
    
    return NO;
}

#pragma mark -

+ (NSError *)_checkShareMessgae:(MySocialShareBaseMessage *)message
{
    if ([message isMemberOfClass:[MySocialShareBaseMessage class]] ||
        [message isMemberOfClass:[MySocialShareBaseMediaMessage class]]) {
        return SOCIALSNSERROR_CREATE(MySocialSNSHandleInfoUnCompleteErrorCode,
                                     MySocialSNSManagerLocalizedString(@"ShareMessageErrorDescription"));
    }
    
    return nil;
}


+ (NSError *)startShareMessgae:(MySocialShareBaseMessage *)message
                      toTarget:(MySocialSNSTargetItem *)target
                  withDelegate:(id<MySocialSNSDelegate>)delegate
{
    if (!message || !target) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"分享目标及内容都不能为nil"
                                     userInfo:nil];
    }
    
    if (![self isInstallSocialSNSTargetSDK:target.name]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"未集成【%@】的SDK",target.name]
                                     userInfo:nil];
    }
    
    
    NSError * error = nil;
    MySocialSNSTargetSupportResultType supportType = [self isSupportShareForSocialSNSTarget:target.name];
    if (supportType != MySocialSNSTargetSupportResultTypeSupport) { //不支持
        
        Class shareTargetClass = [self _shareTargetClassForName:target.name];
        NSString * appName = [shareTargetClass appName];
        
        if (supportType == MySocialSNSTargetSupportResultTypeUnSupport) {
            
            error =  SOCIALSNSERROR_CREATE(MySocialSNSUnSupportErrorCode,
                                           ([NSString stringWithFormat:MySocialSNSManagerLocalizedString(@"SNSTargetUnSupportShareErrorDescription"),appName]));
            
        }else { //没有安装或需要更新
            
            BOOL isInstallApp = [shareTargetClass isAppInstalled];
            
            error = SOCIALSNSERROR_CREATE(isInstallApp ? MySocialSNSVersionUnSupportErrorCode : MySocialSNSUnInstallErrorCode,
                                           ([NSString stringWithFormat:isInstallApp ? MySocialSNSManagerLocalizedString(@"SNSTargetVersionUnSupportShareErrorDescription") : MySocialSNSManagerLocalizedString(@"SNSTargetUnInstallErrorDescription"),appName]));
            
            NSString * appInstallUrl = [shareTargetClass appInstallUrl];
            if (appInstallUrl.length && message.shouldOpenAppInstallPageIfNotAvailable) {
                
                NSString * alertMessage = [NSString stringWithFormat:isInstallApp ?
                                           MySocialSNSManagerLocalizedString(@"VersionUnSupportShare_AlertToUpdateApp") :
                                           MySocialSNSManagerLocalizedString(@"AlertToInstallApp"),appName];
                
                
                //警告视图
                [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:alertMessage okText:@"立即去" cancleText:@"取消" actionBlock:^(BOOL ok) {
                    if (ok) {
                        openURL([NSURL URLWithString:appInstallUrl]);
                    }
                }];
                
            }
            
        }
        
    }else {
        
        //核对待分享的消息
        error = [self _checkShareMessgae:message];
        if (!error) {
            
            _MySocialSNSContext * context = [[_MySocialSNSContext alloc] initWithHandleType:_MySocialSNSHandleTypeShare target:target delegate:delegate baseViewController:nil info:message];
            
            //开始分享
            if (![[self _shareTargetClassForName:target.name] startShareWithContext:context]) {
                error = SOCIALSNSERROR_CREATE(MySocialSNSHandleStartFailErrorCode, MySocialSNSManagerLocalizedString(@"ShareFailErrorDescription"));
                context = nil;
            }
            
            //记录分享上下文信息
            [self shareManager].context = context;
        }
    }

    return error;
}

#pragma mark -

+ (NSError *)startAuthorizeForTarget:(MySocialSNSTargetItem *)target
                      viewController:(UIViewController *)viewController
                        withDelegate:(id<MySocialSNSDelegate>)delegate
{
    return [self startAuthorizeForTarget:target
                       showWebViewIfNeed:YES
                showAppInstallPageIfNeed:YES
                          viewController:viewController
                            withDelegate:delegate];
}

+ (NSError *)startAuthorizeForTarget:(MySocialSNSTargetItem *)target
                   showWebViewIfNeed:(BOOL)showWebViewIfNeed
            showAppInstallPageIfNeed:(BOOL)showAppInstallPageIfNeed
                      viewController:(UIViewController *)viewController
                        withDelegate:(id<MySocialSNSDelegate>)delegate
{
    if (!target) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"授权目标不能为nil" userInfo:nil];
    }
    
    if (![self isInstallSocialSNSTargetSDK:target.name]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"未集成【%@】的SDK",target.name]
                                     userInfo:nil];
    }
    
    NSError * error = nil;
    MySocialSNSTargetSupportResultType supportType = [self isSupportShareForSocialSNSTarget:target.name];
    
    if (supportType == MySocialSNSTargetSupportResultTypeUnSupport) {
        
        error =  SOCIALSNSERROR_CREATE(MySocialSNSUnSupportErrorCode,
                                       ([NSString stringWithFormat:MySocialSNSManagerLocalizedString(@"SNSTargetUnSupportSSOErrorDescription"),[[self _shareTargetClassForName:target.name] appName]]));
        
    }else if (supportType == MySocialSNSTargetSupportResultTypeCanSupport &&
              !showWebViewIfNeed) {
        
        Class shareTargetClass = [self _shareTargetClassForName:target.name];
        NSString * appName = [shareTargetClass appName];
        BOOL isInstallApp = [shareTargetClass isAppInstalled];
        
        error = SOCIALSNSERROR_CREATE(isInstallApp ? MySocialSNSVersionUnSupportErrorCode : MySocialSNSUnInstallErrorCode,
                                       ([NSString stringWithFormat:isInstallApp ? MySocialSNSManagerLocalizedString(@"SNSTargetVersionUnSupportSSOErrorDescription") : MySocialSNSManagerLocalizedString(@"SNSTargetUnInstallErrorDescription"),appName]));
        
        NSString * appInstallUrl = [shareTargetClass appInstallUrl];
        if (appInstallUrl.length &&  showAppInstallPageIfNeed) {
            
            NSString * alertMessage = [NSString stringWithFormat: isInstallApp ?
                                       MySocialSNSManagerLocalizedString(@"VersionUnSupportSSO_AlertToUpdateApp") :
                                       MySocialSNSManagerLocalizedString(@"AlertToInstallApp"),appName];
            
            //警告视图
            [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:alertMessage okText:@"立即去" cancleText:@"取消" actionBlock:^(BOOL ok) {
                if (ok) {
                    openURL([NSURL URLWithString:appInstallUrl]);
                }
            }];
        }
        
    } else {
        
        _MySocialSNSContext * context = [[_MySocialSNSContext alloc] initWithHandleType:_MySocialSNSHandleTypeSSO target:target delegate:delegate baseViewController:viewController info:nil];
        
        //开始授权
        if (![[self _shareTargetClassForName:target.name] startAuthorizeWithContext:context]) {
            error = SOCIALSNSERROR_CREATE(MySocialSNSHandleStartFailErrorCode, MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
            context = nil;
        }
        
        //记录上下文信息
        [self shareManager].context = context;
    }
    
    return error;
}

#pragma mark -

+ (NSError *)   startPayWithContext:(MySocialSNSPayContext *)payContext
                           toTarget:(MySocialSNSTargetItem *)target
           showAppInstallPageIfNeed:(BOOL)showAppInstallPageIfNeed
                     viewController:(UIViewController *)viewController
                       withDelegate:(id<MySocialSNSDelegate>)delegate
{
    if (!target) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"支付目标不能为nil" userInfo:nil];
    }
    
    if (![self isInstallSocialSNSTargetSDK:target.name]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"未集成【%@】的SDK",target.name]
                                     userInfo:nil];
    }
    
    NSError * error = nil;
    
    MySocialSNSTargetSupportResultType supportType = [self isSupportPayForSocialSNSTarget:target.name];
    if (supportType != MySocialSNSTargetSupportResultTypeSupport) { //不支持
        
        Class shareTargetClass = [self _shareTargetClassForName:target.name];
        NSString * appName = [shareTargetClass appName];
        
        if (supportType == MySocialSNSTargetSupportResultTypeUnSupport) {
            
            error =  SOCIALSNSERROR_CREATE(MySocialSNSUnSupportErrorCode,
                                           ([NSString stringWithFormat:MySocialSNSManagerLocalizedString(@"SNSTargetUnSupportPayErrorDescription"),appName]));
            
        }else { //没有安装或需要更新
            
            BOOL isInstallApp = [shareTargetClass isAppInstalled];
            
            error = SOCIALSNSERROR_CREATE(isInstallApp ? MySocialSNSVersionUnSupportErrorCode : MySocialSNSUnInstallErrorCode,
                                          ([NSString stringWithFormat:isInstallApp ? MySocialSNSManagerLocalizedString(@"SNSTargetVersionUnSupportPayErrorDescription") : MySocialSNSManagerLocalizedString(@"SNSTargetUnInstallErrorDescription"),appName]));
            
            NSString * appInstallUrl = [shareTargetClass appInstallUrl];
            if (appInstallUrl.length) {
                
                NSString * alertMessage = [NSString stringWithFormat:isInstallApp ?
                                           MySocialSNSManagerLocalizedString(@"VersionUnSupportPay_AlertToUpdateApp") :
                                           MySocialSNSManagerLocalizedString(@"AlertToInstallApp"),appName];
                
                //警告视图
                [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:@"提醒" content:alertMessage okText:@"立即去" cancleText:@"取消" actionBlock:^(BOOL ok) {
                    if (ok) {
                        openURL([NSURL URLWithString:appInstallUrl]);
                    }
                }];
            }
        }
        
    }else {
        
        _MySocialSNSContext * context = [[_MySocialSNSContext alloc] initWithHandleType:_MySocialSNSHandleTypePay target:target delegate:delegate baseViewController:viewController info:payContext];
        
        //开始支付
        if (![[self _shareTargetClassForName:target.name] startPayWithContext:context]) {
            error = SOCIALSNSERROR_CREATE(MySocialSNSHandleStartFailErrorCode, MySocialSNSManagerLocalizedString(@"PayFailErrorDescription"));
            context = nil;
        }
        
        //记录上下文信息
        [self shareManager].context = context;
        
    }
    
    return error;
}

#pragma mark -

- (void)isOnlineResponse:(NSDictionary *)response {
    // do nothing
}

- (void)onReq:(id)req {
    // do nothing
}

- (void)onResp:(id)resp;
{
    if (XYY_SOCIAL_IS_KIND_OF_CLASS(resp, "SendMessageToQQResp")) { //QQ分享
        
        //上下文目标不是QQ则忽略
        if (self.context == nil ||
            self.context.handleType != _MySocialSNSHandleTypeShare ||
            ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameQQ]) {
            return;
        }
        
        id resultValue = XYY_SOCIAL_GET_MSG_SEND(id, resp, "result");
        NSInteger result = [resultValue integerValue];

        NSError * error = nil;
        if(result == -4){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleShareErrorDescription"));
        }else if(result != 0){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"ShareFailErrorDescription"));
        }

        //完成
        [self _sendCompletedShareMsgWithContext:self.context error:error];

        self.context = nil;
        
        return;
    }
    
    //微信
    //上下文目标不是微信则忽略
    if (self.context == nil ||
        ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameWeChat]) {
        return;
    }
    
    if (XYY_SOCIAL_IS_KIND_OF_CLASS(resp, "SendMessageToWXResp")) { //微信分享
        
        if (self.context.handleType != _MySocialSNSHandleTypeShare) {
            return;
        }
        
        NSError * error = nil;
        NSInteger errCode = XYY_SOCIAL_GET_MSG_SEND(int, resp, "errCode");
        if(errCode == -2 /*WXErrCodeUserCancel*/){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleShareErrorDescription"));
        }else if(errCode != 0 /*WXSuccess*/){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"ShareFailErrorDescription"));
        }
        
        //完成
        [self _sendCompletedShareMsgWithContext:self.context error:error];
        
    }else if (XYY_SOCIAL_IS_KIND_OF_CLASS(resp, "SendAuthResp")) { //微信授权
        
        if (self.context.handleType != _MySocialSNSHandleTypeSSO) {
            return;
        }
        
        NSError * error = nil;
        NSInteger errCode = XYY_SOCIAL_GET_MSG_SEND(int, resp, "errCode");
        if(errCode == -2 /*WXErrCodeUserCancel*/){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleSSOErrorDescription"));
        }else if(errCode != 0 /*WXSuccess*/){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
        }
        
        //完成授权登录
        [self _sendCompletedAuthMsgWithContext:self.context
                                   accessToken:nil
                                        openId:nil
                                          code:error ? nil : ((id(*)(id,SEL))objc_msgSend)(resp,sel_registerName("code"))
                                         error:error];
        
    }else if (XYY_SOCIAL_IS_KIND_OF_CLASS(resp, "PayResp")) { //微信支付
        
        if (self.context.handleType != _MySocialSNSHandleTypePay) {
            return;
        }
        
        NSError * error = nil;
        NSInteger errCode = XYY_SOCIAL_GET_MSG_SEND(int, resp, "errCode");
        if(errCode == -2 /*WXErrCodeUserCancel*/){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCanclePayErrorDescription"));
        }else if(errCode != 0 /*WXSuccess*/){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"PayFailErrorDescription"));
        }
        
        //回调结果
        [self _sendCompletedPayWithContext:self.context
                                    status:error ? MySocialSNSPayResultStatusFail : MySocialSNSPayResultStatusSuccess
                                     error:error];
    }
    
    self.context = nil;
    
}

- (void)didReceiveWeiboRequest:(id)request{
    // do nothing
}

- (void)didReceiveWeiboResponse:(id)response
{
    //上下文目标不是微博则忽略
    if (self.context == nil ||
        ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameWeibo]) {
        return;
    }
    
    if (XYY_SOCIAL_IS_KIND_OF_CLASS(response, "WBSendMessageToWeiboResponse")) { //分享

        if (self.context.handleType != _MySocialSNSHandleTypeShare) {
            return;
        }

        //错误
        NSError * error = nil;
        NSInteger statusCode = XYY_SOCIAL_GET_MSG_SEND(NSInteger, response, "statusCode");
        if(statusCode == -1 /*WeiboSDKResponseStatusCodeUserCancel*/){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleShareErrorDescription"));
        }else if(statusCode != 0 /*WeiboSDKResponseStatusCodeSuccess*/){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"ShareFailErrorDescription"));
        }

        //完成
        [self _sendCompletedShareMsgWithContext:self.context error:error];

    }else if (XYY_SOCIAL_IS_KIND_OF_CLASS(response, "WBAuthorizeResponse")) { //微博授权

        if (self.context.handleType != _MySocialSNSHandleTypeSSO) {
            return;
        }

        //错误
        NSError * error = nil;
        NSInteger statusCode = XYY_SOCIAL_GET_MSG_SEND(NSInteger, response, "statusCode");
        if(statusCode == -1 /*WeiboSDKResponseStatusCodeUserCancel*/){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleSSOErrorDescription"));
        }else if(statusCode != 0 /*WeiboSDKResponseStatusCodeSuccess*/){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
        }

        //完成
        [self _sendCompletedAuthMsgWithContext:self.context
                                   accessToken:error ? nil : XYY_SOCIAL_GET_MSG_SEND(id, response, "accessToken")
                                        openId:error ? nil : XYY_SOCIAL_GET_MSG_SEND(id, response, "userID")
                                          code:nil
                                         error:error];

    }

    self.context = nil;
}


- (void)tencentDidLogin
{
    NSError * error = nil;
    
    if (XYY_SOCIAL_GET_MSG_SEND(NSString *, [MyQQApi tencentOAuth], "accessToken").length == 0) {
        error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                      MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
    }

    [self _tecentAuthCompleteWithError:error];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSError * error = nil;
    if (cancelled) { //用户取消
        error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                      MySocialSNSManagerLocalizedString(@"UserCancleSSOErrorDescription"));
    }else {
        error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                      MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
    }

    [self _tecentAuthCompleteWithError:error];
}

- (void)tencentDidNotNetWork
{
    [self _tecentAuthCompleteWithError:SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                                             MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"))];
}

- (void)_tecentAuthCompleteWithError:(NSError *)error
{
    if (self.context == nil ||
        self.context.handleType != _MySocialSNSHandleTypeSSO ||
        ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameQQ]) {
        return;
    }

    //发送消息
    id tencentOAuth = [MyQQApi tencentOAuth];
    [self _sendCompletedAuthMsgWithContext:self.context
                               accessToken:error ? nil : XYY_SOCIAL_GET_MSG_SEND(id, tencentOAuth, "accessToken")
                                    openId:error ? nil : XYY_SOCIAL_GET_MSG_SEND(id, tencentOAuth, "openId")
                                      code:nil
                                     error:error];

    self.context = nil;
}
                                                                                       
- (void)alipayDidCompletedWithResult:(NSDictionary *)result
{
    //核对目标是支付宝
    if (self.context == nil ||
        self.context.handleType != _MySocialSNSHandleTypePay ||
        ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameAlipay]) {
        return;
    }
    
    //结果状态码
    NSInteger resultStatus = [result integerValueForKey:@"resultStatus"];
    
    NSError * error = nil;
    MySocialSNSPayResultStatus status;
    if (resultStatus == 9000) { //支付成功
        status = MySocialSNSPayResultStatusSuccess;
    }else if (resultStatus == 8000 || resultStatus == 6004) { //支付结果不确定
        status = MySocialSNSPayResultStatusUncertain;
    }else if (resultStatus == 6001) { //用户取消
        status = MySocialSNSPayResultStatusFail;
        error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                      MySocialSNSManagerLocalizedString(@"UserCanclePayErrorDescription"));
    }else { //失败
        status = MySocialSNSPayResultStatusFail;
        error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                      MySocialSNSManagerLocalizedString(@"PayFailErrorDescription"));
    }
    
    [self _sendCompletedPayWithContext:self.context status:status error:error];
    
    self.context = nil;
}

- (void)_sendCompletedShareMsgWithContext:(_MySocialSNSContext *)context error:(NSError *)error
{
    id<MySocialSNSDelegate> delegate = context.delegate;
    ifRespondsSelector(delegate, @selector(shareMessgae:toTarget:completedWithError:)) {
        [delegate shareMessgae:[context info] toTarget:context.target completedWithError:error];
    }
}

- (void)_sendCompletedAuthMsgWithContext:(_MySocialSNSContext *)context
                          accessToken:(NSString *)accessToken
                               openId:(NSString *)openId
                                 code:(NSString *)code
                                error:(NSError *)error
{
    id<MySocialSNSDelegate> delegate = context.delegate;
    ifRespondsSelector(delegate, @selector(authorizeForTarget:completedWithAccessToken:openId:code:error:)) {
        [delegate authorizeForTarget:context.target completedWithAccessToken:accessToken openId:openId code:code error:error];
    }
}

- (void)_sendCompletedPayWithContext:(_MySocialSNSContext *)context
                              status:(MySocialSNSPayResultStatus)status
                               error:(NSError *)error
{
    id<MySocialSNSDelegate> delegate = context.delegate;
    ifRespondsSelector(delegate, @selector(payWithInfo:toTarget:completedWithStatus:andError:)) {
        [delegate payWithInfo:context.info toTarget:context.target completedWithStatus:status andError:error];
    }
}


@end

//----------------------------------------------------------

@implementation MyWXApi

+ (Class)baseClass {
    return NSClassFromString(@"WXApi");
}

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_WX");
}

+ (BOOL)isAppInstalled {
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isWXAppInstalled");
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isWXAppSupportApi") ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isWXAppSupportApi") ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isWXAppSupportApi") ? MySocialSNSTargetSupportResultTypeSupport : MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (NSString *)appInstallUrl {
    return XYY_SOCIAL_GET_MSG_SEND(id, [self baseClass], "getWXAppInstallUrl");
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info
{
    NSString * appID = [info stringValueForKey:@"id"];
    if (appID.length) {
        return ((BOOL(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("registerApp:"),appID);
    }
    
    return NO;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context
{
    return ((BOOL(*)(id,SEL,id,id))objc_msgSend)([self baseClass],sel_registerName("handleOpenURL:delegate:"),url,[MySocialSNSManager shareManager]);
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context
{
    id req = [[objc_getClass("SendMessageToWXReq") alloc] init];
    
    MySocialShareBaseMessage * message = context.info;
    if (message.messageType == MyShareMessageTypeText) {
        XYY_SOCIAL_SET_MSG_SEND(id, req, "setText:", [(MySocialShareTextMessage *)message text]);
        XYY_SOCIAL_SET_MSG_SEND(BOOL, req, "setBText:", YES);
    }else {
        
        id mediaMessage = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WXMediaMessage"), "message");
        XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setTitle:", [(MySocialShareBaseMediaMessage *)message title]);
        XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setDescription:", [(MySocialShareBaseMediaMessage *)message description]);
        XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setThumbData:", [(MySocialShareBaseMediaMessage *)message thumbData]);

        switch (message.messageType) {
            case MyShareMessageTypeImage:
            {
                id imageObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WXImageObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, imageObject, "setImageData:", [(MySocialShareImageMessage *)message imageData]);
                
                XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setMediaObject:", imageObject);
            }
            break;
            
            case MyShareMessageTypeVideo:
            {
                id videoObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WXVideoObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, videoObject, "setVideoUrl:", [(MySocialShareVideoMessage *)message videoUrl]);
                
                XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setMediaObject:", videoObject);
            }
            
            break;
            
            case MyShareMessageTypeMusic:
            {
                id musicObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WXMusicObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, musicObject, "setMusicUrl:", [(MySocialShareMusicMessage *)message musicUrl]);
                XYY_SOCIAL_SET_MSG_SEND(id, musicObject, "setMusicDataUrl:", [(MySocialShareMusicMessage *)message musicStreamUrl]);
                
                XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setMediaObject:", musicObject);
            }
            
            break;
            
            case MyShareMessageTypeWebpage:
            {
                id webpageObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WXWebpageObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, webpageObject, "setWebpageUrl:", [(MySocialShareWebpageMessage *)message webpageUrl]);
                
                XYY_SOCIAL_SET_MSG_SEND(id, mediaMessage, "setMediaObject:", webpageObject);
            }
            
            default:
            break;
        }
        
        XYY_SOCIAL_SET_MSG_SEND(id, req, "setMessage:", mediaMessage);
    }
    
    
    //设置目标是朋友圈还是微信好友
    if ([context.target.name isEqualToString:MySocialSNSTargetItemNameWeChat]) {
        XYY_SOCIAL_SET_MSG_SEND(int, req, "setScene:", 0/*WXSceneSession*/);
    }else {
        XYY_SOCIAL_SET_MSG_SEND(int, req, "setScene:", 1/*WXSceneTimeline*/);
    }
    
    //发送请求
    return ((BOOL(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("sendReq:"),req);
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context
{
    //授权请求
    id authReq = [[objc_getClass("SendAuthReq") alloc] init];
    XYY_SOCIAL_SET_MSG_SEND(id, authReq, "setScope:", @"snsapi_userinfo");
    XYY_SOCIAL_SET_MSG_SEND(id, authReq, "setState:", [NSString uniqueIDString]);
    
    //开始授权
    return ((BOOL(*)(id,SEL,id,id,id))objc_msgSend)([self baseClass],sel_registerName("sendAuthReq:viewController:delegate:"),authReq,context.baseViewController,[MySocialSNSManager shareManager]);
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context
{
    MySocialSNSPayContext * payContext = context.info;
    
    id req = [[objc_getClass("PayReq") alloc] init];
    XYY_SOCIAL_SET_MSG_SEND(id, req, "setPartnerId:", payContext.partnerId);
    XYY_SOCIAL_SET_MSG_SEND(id, req, "setPrepayId:", payContext.prepayId);
    XYY_SOCIAL_SET_MSG_SEND(id, req, "setNonceStr:", payContext.nonceStr);
    XYY_SOCIAL_SET_MSG_SEND(UInt32, req, "setTimeStamp:", (UInt32)payContext.timestamp);
    XYY_SOCIAL_SET_MSG_SEND(id, req, "setPackage:", payContext.package);
    XYY_SOCIAL_SET_MSG_SEND(id, req, "setSign:", payContext.sign);
    
    //发送请求
    return ((BOOL(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("sendReq:"),req);
}

@end

//----------------------------------------------------------

@implementation MyQQApi

+ (Class)baseClass {
    return objc_getClass("QQApiInterface");
}

+ (Class)_TencentOAuthClass {
    return objc_getClass("TencentOAuth");
}

static id tencentOAuth = nil;
+ (id)tencentOAuth {
    return tencentOAuth;
}

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_QQ");
}

+ (BOOL)isAppInstalled {
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isQQInstalled");
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isQQSupportApi") ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self _TencentOAuthClass], "iphoneQQSupportSSOLogin") ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay
{
    //暂时没有实现QQ的支付功能
    return MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (NSString *)appInstallUrl {
    return XYY_SOCIAL_GET_MSG_SEND(id, [self baseClass], "getQQInstallUrl");
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info
{
    NSString * appID = [info stringValueForKey:@"id"];
    if (appID.length) {
        tencentOAuth = ((id(*)(id,SEL,id,id))objc_msgSend)([[self _TencentOAuthClass] alloc],sel_registerName("initWithAppId:andDelegate:"),appID,[MySocialSNSManager shareManager]);
    }else {
        tencentOAuth = nil;
    }
    
    return tencentOAuth != nil;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context
{
    if (((BOOL(*)(id,SEL,id))objc_msgSend)([self _TencentOAuthClass],sel_registerName("CanHandleOpenURL:"),url)) {
        return ((BOOL(*)(id,SEL,id))objc_msgSend)([self _TencentOAuthClass],sel_registerName("HandleOpenURL:"),url);
    }else {
        return ((BOOL(*)(id,SEL,id,id))objc_msgSend)([self baseClass],sel_registerName("handleOpenURL:delegate:"),url,[MySocialSNSManager shareManager]);
    }
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context
{
    id qqApiObject = nil;
    
    MySocialShareBaseMessage * message = context.info;
    if (message.messageType == MyShareMessageTypeText) {
        qqApiObject = ((id(*)(id,SEL,id))objc_msgSend)(objc_getClass("QQApiTextObject"),sel_registerName("objectWithText:"),[(MySocialShareTextMessage *)message text]);
    }else {
        
        NSString * title = [(MySocialShareBaseMediaMessage *)message title];
        NSString * description = [(MySocialShareBaseMediaMessage *)message description];
        NSData * thumbData = [(MySocialShareBaseMediaMessage *)message thumbData];

        switch (message.messageType) {
            case MyShareMessageTypeImage:
                qqApiObject = ((id(*)(id,SEL,id,id,id,id))objc_msgSend)(objc_getClass("QQApiImageObject"),sel_registerName("objectWithData:previewImageData:title:description:"),[(MySocialShareImageMessage *)message imageData],thumbData,title,description);
            break;
            
            case MyShareMessageTypeMusic:
            {
                NSString * musicStreamUrl = [(MySocialShareMusicMessage *)message musicStreamUrl];
                
                if (musicStreamUrl) {
                    qqApiObject = ((id(*)(id,SEL,id,id,id,id))objc_msgSend)(objc_getClass("QQApiAudioObject"),sel_registerName("objectWithURL:title:description:previewImageData:"),[NSURL URLWithString:musicStreamUrl],title,description,thumbData);
                }else {
                    qqApiObject = ((id(*)(id,SEL,id,id,id,id))objc_msgSend)(objc_getClass("QQApiNewsObject"),sel_registerName("objectWithURL:title:description:previewImageData:"),[NSURL URLWithString:[(MySocialShareMusicMessage *)message musicUrl]],title,description,thumbData);
                }
                
            }

            break;
            
            case MyShareMessageTypeVideo:
                qqApiObject = ((id(*)(id,SEL,id,id,id,id))objc_msgSend)(objc_getClass("QQApiNewsObject"),sel_registerName("objectWithURL:title:description:previewImageData:"),[NSURL URLWithString:[(MySocialShareVideoMessage *)message videoUrl]],title,description,thumbData);
            break;
            
            case MyShareMessageTypeWebpage:
                qqApiObject = ((id(*)(id,SEL,id,id,id,id))objc_msgSend)(objc_getClass("QQApiNewsObject"),sel_registerName("objectWithURL:title:description:previewImageData:"),[NSURL URLWithString:[(MySocialShareWebpageMessage *)message webpageUrl]],title,description,thumbData);
            break;
            
            default:
            break;
        }
    }

    int resultCode;
    
    id req = ((id(*)(id,SEL,id))objc_msgSend)(objc_getClass("SendMessageToQQReq"),sel_registerName("reqWithContent:"),qqApiObject);
    
    if ([context.target.name isEqualToString:MySocialSNSTargetItemNameQQ]) {
        resultCode = ((int(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("sendReq:"),req);
    }else {
        resultCode = ((int(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("SendReqToQZone:"),req);
        
#if DEBUG
        if (resultCode == 10000 /* EQQAPIQZONENOTSUPPORTTEXT*/) {
            NSLog(@"qzone分享不支持text类型分享 已转换为分享到QQ");
        }else if (resultCode == 10001 /*EQQAPIQZONENOTSUPPORTIMAGE*/) {
            NSLog(@"qzone分享不支持image类型分享 已转换为分享到QQ");
        }
#endif
        //转换到QQ分享
        if (resultCode >= 10000 /* EQQAPIQZONENOTSUPPORTTEXT*/) {
            resultCode = ((int(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("sendReq:"),req);
        }
    }
    
    return resultCode == 0 /*EQQAPISENDSUCESS*/;
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context
{
    NSArray * permissions = @[@"get_info", @"get_simple_userinfo", @"get_user_info"];
    
    //授权
    return ((BOOL(*)(id,SEL,id))objc_msgSend)(tencentOAuth,sel_registerName("authorize:"),permissions);
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context {
    return NO;
}

@end

//----------------------------------------------------------


@implementation MyWeiboApi

+ (Class)baseClass {
    return objc_getClass("WeiboSDK");
}

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_WB");
}

+ (BOOL)isAppInstalled {
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isWeiboAppInstalled");
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isCanShareInWeiboAPP") ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    return XYY_SOCIAL_GET_MSG_SEND(BOOL, [self baseClass], "isCanSSOInWeiboApp") ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay
{
    //暂时没有实现微博的支付功能
    return MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (NSString *)appInstallUrl {
    return XYY_SOCIAL_GET_MSG_SEND(id, [self baseClass], "getWeiboAppInstallUrl");
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info
{
    
#if DEBUG
    XYY_SOCIAL_SET_MSG_SEND(BOOL, [self baseClass], "enableDebugMode:", YES);
#endif
    
    NSString * appKey = [info stringValueForKey:@"key"];
    if (appKey.length) {
        return ((BOOL(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("registerApp:"),appKey);
    }
    
    return NO;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context
{
    return ((BOOL(*)(id,SEL,id,id))objc_msgSend)([self baseClass],sel_registerName("handleOpenURL:delegate:"),url,[MySocialSNSManager shareManager]);
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context
{
    id wbMessageObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WBMessageObject"), "message");
    
    MySocialShareBaseMessage * message = context.info;
    if (message.messageType == MyShareMessageTypeText) {
        XYY_SOCIAL_SET_MSG_SEND(id, wbMessageObject, "setText:", [(MySocialShareTextMessage *)message text]);
    }else if (message.messageType == MyShareMessageTypeImage) {

        id imageObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WBImageObject"), "object");
        XYY_SOCIAL_SET_MSG_SEND(id, imageObject, "setImageData:", [(MySocialShareImageMessage *)message imageData]);
        
#if DEBUG
      
        if ([(MySocialShareImageMessage *)message imageData] == nil) {
            NSLog(@"分享到微博的图片消息必须包含图片数据，由于当前为包含，所以将不显示图片");
        }
#endif
        XYY_SOCIAL_SET_MSG_SEND(id, wbMessageObject, "setImageObject:", imageObject);
        XYY_SOCIAL_SET_MSG_SEND(id, wbMessageObject, "seText:", [(MySocialShareImageMessage *)message title]);
        
    }else {
        
        id mediaObject = nil;
        
        switch (message.messageType) {
            case MyShareMessageTypeVideo:
            {
                id videoObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WBVideoObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, videoObject, "setVideoUrl:", [(MySocialShareVideoMessage *)message videoUrl]);
                XYY_SOCIAL_SET_MSG_SEND(id, videoObject, "setVideoStreamUrl:", [(MySocialShareVideoMessage *)message videoStreamUrl]);
                XYY_SOCIAL_SET_MSG_SEND(id, videoObject, "setObjectID:", [(MySocialShareVideoMessage *)message videoUrl]);
                
                mediaObject = videoObject;
            }
            
            break;
            
            case MyShareMessageTypeMusic:
            {
                id musicObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WBMusicObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, musicObject, "setMusicUrl:", [(MySocialShareMusicMessage *)message musicUrl]);
                XYY_SOCIAL_SET_MSG_SEND(id, musicObject, "setMusicStreamUrl:", [(MySocialShareMusicMessage *)message musicStreamUrl]);
                XYY_SOCIAL_SET_MSG_SEND(id, musicObject, "setObjectID:", [(MySocialShareMusicMessage *)message musicUrl]);

                mediaObject = musicObject;
            }
            
            break;
            
            case MyShareMessageTypeWebpage:
            {
                id webpageObject = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WBWebpageObject"), "object");
                XYY_SOCIAL_SET_MSG_SEND(id, webpageObject, "setWebpageUrl:", [(MySocialShareWebpageMessage *)message webpageUrl]);
                XYY_SOCIAL_SET_MSG_SEND(id, webpageObject, "setObjectID:", [(MySocialShareWebpageMessage *)message webpageUrl]);

                mediaObject = webpageObject;
            }
            break;
            
            
            default:
            break;
        }
        
        XYY_SOCIAL_SET_MSG_SEND(id, mediaObject, "setTitle:", [(MySocialShareBaseMediaMessage *)message title]);
        XYY_SOCIAL_SET_MSG_SEND(id, mediaObject, "setDescription:", [(MySocialShareBaseMediaMessage *)message description]);
        XYY_SOCIAL_SET_MSG_SEND(id, mediaObject, "setThumbnailData:", [(MySocialShareBaseMediaMessage *)message thumbData]);
        
        XYY_SOCIAL_SET_MSG_SEND(id, wbMessageObject, "setMediaObject:", mediaObject);
        XYY_SOCIAL_SET_MSG_SEND(id, wbMessageObject, "setText:", [(MySocialShareImageMessage *)message title]);
    }
    
    id req = ((id(*)(id,SEL,id))objc_msgSend)(objc_getClass("WBSendMessageToWeiboRequest"),sel_registerName("requestWithMessage:"),wbMessageObject);
    XYY_SOCIAL_SET_MSG_SEND(BOOL, req, "setShouldOpenWeiboAppInstallPageIfNotInstalled:", NO);

    return ((BOOL(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("sendRequest:"),req);
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context
{
    id authorizeRequest = XYY_SOCIAL_GET_MSG_SEND(id, objc_getClass("WBAuthorizeRequest"), "request");
    
    NSString * redirectURI = [[MySocialSNSManager _socialSNSTargetIdentifyInfo:context.target.name] objectForKey:@"redirectURI"] ?:  @"http://www.sina.com";
    XYY_SOCIAL_SET_MSG_SEND(id, authorizeRequest, "setRedirectURI:", redirectURI);
    XYY_SOCIAL_SET_MSG_SEND(id, authorizeRequest, "setScope:", @"all");
    
    //开始授权
    return ((BOOL(*)(id,SEL,id))objc_msgSend)([self baseClass],sel_registerName("sendRequest:"),authorizeRequest);
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context {
    return NO;
}

@end

//----------------------------------------------------------

@implementation MyAlipayApi

+ (Class)baseClass {
    return objc_getClass("AlipaySDK");
}

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_Alipay");
}

+ (BOOL)isAppInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://test"]];
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare {
    return MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    //暂时没有实现支付宝的授权登录功能
    return MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay {
    return MySocialSNSTargetSupportResultTypeSupport;
}

+ (NSString *)appInstallUrl {
    return nil;
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info {
    return YES;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context
{
    if (context.handleType == _MySocialSNSHandleTypePay &&
        [url.host isEqualToString:@"safepay"]) {
        
        //处理支付结果回调
        id defaultService = XYY_SOCIAL_GET_MSG_SEND(id, [self baseClass], "defaultService");
        ((void(*)(id,SEL,id,void(^)(NSDictionary *)))objc_msgSend)(defaultService,sel_registerName("processOrderWithPaymentResult:standbyCallback:"),url,^(NSDictionary *resultDic) {
            [self _completedPayCallbackWithResultDic:resultDic];
        });
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context {
    return NO;
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context {
    return NO;
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context
{
    MySocialSNSPayContext * payContext = context.info;
    NSString * orderStr = payContext.orderStr;
    NSString * scheme = [[MySocialSNSManager _socialSNSTargetIdentifyInfo:context.target.name] stringValueForKey:@"scheme"];
    
    if (orderStr.length && scheme.length) {
        
        //开始支付
        id defaultService = XYY_SOCIAL_GET_MSG_SEND(id, [self baseClass], "defaultService");
        ((void(*)(id,SEL,id,id,void(^)(NSDictionary *)))objc_msgSend)(defaultService,sel_registerName("payOrder:fromScheme:callback:"),orderStr,scheme,^(NSDictionary *resultDic) {
            [self _completedPayCallbackWithResultDic:resultDic];
        });
        
        return YES;
    }
    
    return NO;
}

+ (void)_completedPayCallbackWithResultDic:(NSDictionary *)resultDic
{
    id<MyAlipaySDKDelegate> delegate = [MySocialSNSManager shareManager];
    ifRespondsSelector(delegate, @selector(alipayDidCompletedWithResult:)) {
        [delegate alipayDidCompletedWithResult:resultDic];
    }
}

@end
