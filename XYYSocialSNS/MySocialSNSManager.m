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

//----------------------------------------------------------

//是否包含微信
#if __has_include(<WXApi.h>)
#define XYYSOCIALSNS_WECHAT_ENABLED 1
#import <WXApi.h>
#elif __has_include("WXApi.h")
#define XYYSOCIALSNS_WECHAT_ENABLED 1
#import "WXApi.h"
#endif

//微博
#if __has_include(<WeiboSDK.h>)
#define XYYSOCIALSNS_WEIBO_ENABLED 1
#import <WeiboSDK.h>
#elif __has_include("WeiboSDK.h")
#define XYYSOCIALSNS_WEIBO_ENABLED 1
#import "WeiboSDK.h"
#endif

//QQ
#if __has_include(<TencentOpenAPI/QQApiInterface.h>) && __has_include(<TencentOpenAPI/TencentOAuth.h>)
#define XYYSOCIALSNS_QQ_ENABLED 1
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#elif __has_include("TencentOpenAPI/QQApiInterface.h") && __has_include("TencentOpenAPI/TencentOAuth.h")
#define XYYSOCIALSNS_QQ_ENABLED 1
#import "TencentOpenAPI/QQApiInterface.h"
#import "TencentOpenAPI/TencentOAuth.h"
#endif

//支付宝
#if __has_include(<AlipaySDK/AlipaySDK.h>)
#define XYYSOCIALSNS_ALIPAY_ENABLED 1
#import <AlipaySDK/AlipaySDK.h>
#elif __has_include("AlipaySDK/AlipaySDK.h")
#define XYYSOCIALSNS_ALIPAY_ENABLED 1
#import <AlipaySDK/AlipaySDK.h>
#endif


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

#if XYYSOCIALSNS_WECHAT_ENABLED

@interface WXApi (MyShareTarget) <_MySocialSNSTargetProtocol>

@end

#endif

//----------------------------------------------------------

#if XYYSOCIALSNS_QQ_ENABLED

@interface MyQQApi : NSObject <_MySocialSNSTargetProtocol>

+ (TencentOAuth *)tencentOAuth;

@end

#endif

//----------------------------------------------------------


#if XYYSOCIALSNS_WEIBO_ENABLED

@interface WeiboSDK (MySocialSNSTarget) <_MySocialSNSTargetProtocol>

@end

#endif

//----------------------------------------------------------


#if XYYSOCIALSNS_ALIPAY_ENABLED

@protocol MyAlipaySDKDelegate <NSObject>

- (void)alipayDidCompletedWithResult:(NSDictionary *)result;

@end

//----------------------------------------------------------

@interface AlipaySDK(MySocialSNSTarget) <_MySocialSNSTargetProtocol>

@end

#endif

//----------------------------------------------------------

@interface MySocialSNSManager ()
<   NSObject
#if XYYSOCIALSNS_WECHAT_ENABLED
    ,WXApiDelegate
#endif
#if XYYSOCIALSNS_QQ_ENABLED
    ,QQApiInterfaceDelegate
    ,TencentSessionDelegate
#endif
#if XYYSOCIALSNS_WEIBO_ENABLED
    ,WeiboSDKDelegate
#endif
#if XYYSOCIALSNS_ALIPAY_ENABLED
    ,MyAlipaySDKDelegate
#endif
>

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
    NSString * className = nil;
    if ([name isEqualToString:MySocialSNSTargetItemNameWeChat] ||
        [name isEqualToString:MySocialSNSTargetItemNameWeChatCircle]) {
        className = @"WXApi";
    }else if([name isEqualToString:MySocialSNSTargetItemNameQQ] ||
             [name isEqualToString:MySocialSNSTargetItemNameQQZone]){
        className = @"MyQQApi";
    }else if ([name isEqualToString:MySocialSNSTargetItemNameWeibo]) {
        className = @"WeiboSDK";
    }else if ([name isEqualToString:MySocialSNSTargetItemNameAlipay]) {
        className = @"AlipaySDK";
    }
    
    return className.length ? NSClassFromString(className) : nil;
}

+ (BOOL)isInstallSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName {
    return [[self _shareTargetClassForName:targetItmeName] isAppInstalled];
}

+ (MySocialSNSTargetSupportResultType)isSupportShareForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName {
    return [[self _shareTargetClassForName:targetItmeName] isAppSupportShare];
}

+ (MySocialSNSTargetSupportResultType)isSupportSSOForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName {
    return [[self _shareTargetClassForName:targetItmeName] isAppSupportSSO];
}

+ (MySocialSNSTargetSupportResultType)isSupportPayForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName {
    return [[self _shareTargetClassForName:targetItmeName] isAppSupportPay];
}

+ (NSString *)appNameForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName {
    return [[self _shareTargetClassForName:targetItmeName] appName];
}

#pragma mark -

+ (void)applicationDidFinishLaunching
{
    //注册key
    NSMutableDictionary * socialSNSTargetIdentifyInfos = [self shareManager].socialSNSTargetIdentifyInfos;
    NSMutableArray * registerFailTargetNames = [NSMutableArray arrayWithCapacity:socialSNSTargetIdentifyInfos.count];
    
    for (NSString * name in socialSNSTargetIdentifyInfos.allKeys) { //注册APP身份信息
        NSDictionary * identifyInfo = socialSNSTargetIdentifyInfos[name];
        if (![[self _shareTargetClassForName:name] registerAppWithInfo:identifyInfo]) {
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
                UIAlertView * alertView = [UIAlertView alertWithCallBackBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if (buttonIndex != alertView.cancelButtonIndex) {
                        openURL([NSURL URLWithString:appInstallUrl]);
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appInstallUrl]];
                    }
                    
                }
                                                                        title:@"提醒"
                                                                      message:alertMessage
                                                             cancelButtonName:@"取消"
                                                            otherButtonTitles:@"立即去", nil];
                
                [alertView show];
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
            
            UIAlertView * alertView = [UIAlertView alertWithCallBackBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if (alertView.cancelButtonIndex != buttonIndex) {
                    openURL([NSURL URLWithString:appInstallUrl]);
                }
            }
                                                                    title:@"提醒"
                                                                  message:alertMessage
                                                         cancelButtonName:@"取消"
                                                        otherButtonTitles:@"立即去", nil];
            [alertView show];
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
                UIAlertView * alertView = [UIAlertView alertWithCallBackBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if (buttonIndex != alertView.cancelButtonIndex) {
                        openURL([NSURL URLWithString:appInstallUrl]);
                    }
                    
                }
                                                                        title:@"提醒"
                                                                      message:alertMessage
                                                             cancelButtonName:@"取消"
                                                            otherButtonTitles:@"立即去", nil];
                
                [alertView show];
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
#if XYYSOCIALSNS_QQ_ENABLED
    
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) { //QQ分享

        //上下文目标不是QQ则忽略
        if (self.context == nil ||
            self.context.handleType != _MySocialSNSHandleTypeShare ||
            ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameQQ]) {
            return;
        }

        NSInteger result = [[(QQBaseResp *)resp result] integerValue];

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
    
#endif
    
#if XYYSOCIALSNS_WECHAT_ENABLED
    
    //微信
    //上下文目标不是微信则忽略
    if (self.context == nil ||
        ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameWeChat]) {
        return;
    }
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) { //微信分享
        
        if (self.context.handleType != _MySocialSNSHandleTypeShare) {
            return;
        }
        
        NSInteger errCode = [(BaseResp *)resp errCode];
        
        NSError * error = nil;
        if(errCode == WXErrCodeUserCancel){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleShareErrorDescription"));
        }else if(errCode != WXSuccess){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"ShareFailErrorDescription"));
        }
        
        //完成
        [self _sendCompletedShareMsgWithContext:self.context error:error];
        
    }else if ([resp isKindOfClass:[SendAuthResp class]]) { //微信授权
        
        if (self.context.handleType != _MySocialSNSHandleTypeSSO) {
            return;
        }
        
        NSInteger errCode = [(BaseResp *)resp errCode];
        
        NSError * error = nil;
        if(errCode == WXErrCodeUserCancel){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleSSOErrorDescription"));
        }else if(errCode != WXSuccess){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
        }
        
        //完成授权登录
        [self _sendCompletedAuthMsgWithContext:self.context
                                   accessToken:nil
                                        openId:nil
                                          code:error ? nil : [(SendAuthResp *)resp code]
                                         error:error];
        
    }else if ([resp isKindOfClass:[PayResp class]]) { //微信支付
        
        if (self.context.handleType != _MySocialSNSHandleTypePay) {
            return;
        }
        
        NSInteger errCode = [(BaseResp *)resp errCode];
        
        NSError * error = nil;
        if(errCode == WXErrCodeUserCancel){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCanclePayErrorDescription"));
        }else if(errCode != WXSuccess){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"PayFailErrorDescription"));
        }
        
        //回调结果
        [self _sendCompletedPayWithContext:self.context
                                    status:error ? MySocialSNSPayResultStatusFail : MySocialSNSPayResultStatusSuccess
                                     error:error];
    }
    
    self.context = nil;
    
#endif
}

//微博
#if XYYSOCIALSNS_WEIBO_ENABLED

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    // do nothing
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    //上下文目标不是微博则忽略
    if (self.context == nil ||
        ![[[self class] _socialSNSTargetAppNameForName:self.context.target.name] isEqualToString:MySocialSNSTargetItemNameWeibo]) {
        return;
    }

    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) { //分享

        if (self.context.handleType != _MySocialSNSHandleTypeShare) {
            return;
        }

        //错误
        NSError * error = nil;
        if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleShareErrorDescription"));
        }else if(response.statusCode != WeiboSDKResponseStatusCodeSuccess){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"ShareFailErrorDescription"));
        }

        //完成
        [self _sendCompletedShareMsgWithContext:self.context error:error];

    }else if ([response isKindOfClass:[WBAuthorizeResponse class]]) { //微博授权

        if (self.context.handleType != _MySocialSNSHandleTypeSSO) {
            return;
        }

        //错误
        NSError * error = nil;
        if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel){ //用户取消
            error = SOCIALSNSERROR_CREATE(MySocialSNSUserCancleErrorCode,
                                          MySocialSNSManagerLocalizedString(@"UserCancleSSOErrorDescription"));
        }else if(response.statusCode != WeiboSDKResponseStatusCodeSuccess){
            error = SOCIALSNSERROR_CREATE(MyShareSNSHandleFailErrorCode,
                                          MySocialSNSManagerLocalizedString(@"SSOFailErrorDescription"));
        }

        //完成
        [self _sendCompletedAuthMsgWithContext:self.context
                                   accessToken:error ? nil : [(WBAuthorizeResponse *)response accessToken]
                                        openId:error ? nil : [(WBAuthorizeResponse *)response userID]
                                          code:nil
                                         error:error];

    }

    self.context = nil;
}

#endif


//QQ
#if XYYSOCIALSNS_WEIBO_ENABLED

- (void)tencentDidLogin
{
    NSError * error = nil;
    if ([MyQQApi tencentOAuth].accessToken.length == 0) {
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
    TencentOAuth * tencentOAuth = [MyQQApi tencentOAuth];
    [self _sendCompletedAuthMsgWithContext:self.context
                               accessToken:error ? nil : [tencentOAuth accessToken]
                                    openId:error ? nil : [tencentOAuth openId]
                                      code:nil
                                     error:error];

    self.context = nil;
}

#endif

//支付宝
#if XYYSOCIALSNS_ALIPAY_ENABLED

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

#endif

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

#if XYYSOCIALSNS_WECHAT_ENABLED

@implementation WXApi (MyShareTarget)

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_WX");
}

+ (BOOL)isAppInstalled {
    return [self isWXAppInstalled];
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare
{
    return [self isWXAppSupportApi] ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    return [self isWXAppSupportApi] ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay
{
    return [self isWXAppSupportApi] ? MySocialSNSTargetSupportResultTypeSupport : MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (NSString *)appInstallUrl {
    return [self getWXAppInstallUrl];
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info
{
    NSString * appID = [info stringValueForKey:@"id"];
    if (appID.length) {
        return [self registerApp:appID];
    }
    
    return NO;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context {
    return [self handleOpenURL:url delegate:[MySocialSNSManager shareManager]];
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context
{
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    
    MySocialShareBaseMessage * message = context.info;
    if (message.messageType == MyShareMessageTypeText) {
        req.text = [(MySocialShareTextMessage *)message text];
        req.bText = YES;
    }else {
        
        WXMediaMessage * mediaMessage = [WXMediaMessage message];
        mediaMessage.title = [(MySocialShareBaseMediaMessage *)message title];
        mediaMessage.description = [(MySocialShareBaseMediaMessage *)message description];
        mediaMessage.thumbData = [(MySocialShareBaseMediaMessage *)message thumbData];
        
        switch (message.messageType) {
            case MyShareMessageTypeImage:
            {
                WXImageObject * imageObject = [WXImageObject object];
                imageObject.imageData = [(MySocialShareImageMessage *)message imageData];
                
                mediaMessage.mediaObject = imageObject;
            }
            break;
            
            case MyShareMessageTypeVideo:
            {
                WXVideoObject * videoObject = [WXVideoObject object];
                videoObject.videoUrl = [(MySocialShareVideoMessage *)message videoUrl];
                
                mediaMessage.mediaObject = videoObject;
            }
            
            break;
            
            case MyShareMessageTypeMusic:
            {
                WXMusicObject * musicObject = [WXMusicObject object];
                musicObject.musicUrl = [(MySocialShareMusicMessage *)message musicUrl];
                musicObject.musicDataUrl = [(MySocialShareMusicMessage *)message musicStreamUrl];
                
                mediaMessage.mediaObject = musicObject;
            }
            
            break;
            
            case MyShareMessageTypeWebpage:
            {
                WXWebpageObject * webpageObject = [WXWebpageObject object];
                webpageObject.webpageUrl = [(MySocialShareWebpageMessage *)message webpageUrl];
                
                mediaMessage.mediaObject = webpageObject;
            }
            
            default:
            break;
        }
        
        req.message = mediaMessage;
    }
    
    
    //设置目标是朋友圈还是微信好友
    if ([context.target.name isEqualToString:MySocialSNSTargetItemNameWeChat]) {
        req.scene = WXSceneSession;
    }else {
        req.scene = WXSceneTimeline;
    }
    
    //发送请求
    return [self sendReq:req];
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context
{
    //授权请求
    SendAuthReq * authReq = [[SendAuthReq alloc] init];
    authReq.scope = @"snsapi_userinfo";
    authReq.state = [NSString uniqueIDString];
    
    //开始授权
    return [self sendAuthReq:authReq viewController:context.baseViewController delegate:[MySocialSNSManager shareManager]];
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context
{
    MySocialSNSPayContext * payContext = context.info;
    
    PayReq * req = [[PayReq alloc] init];
    req.partnerId = payContext.partnerId;
    req.prepayId = payContext.prepayId;
    req.nonceStr = payContext.nonceStr;
    req.timeStamp = (UInt32)payContext.timestamp;
    req.package = payContext.package;
    req.sign = payContext.sign;
    
    return [self sendReq:req];
}

@end

#endif

//----------------------------------------------------------

#if XYYSOCIALSNS_QQ_ENABLED

@implementation MyQQApi

static TencentOAuth * tencentOAuth = nil;
+ (TencentOAuth *)tencentOAuth {
    return tencentOAuth;
}

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_QQ");
}

+ (BOOL)isAppInstalled {
    return [QQApiInterface isQQInstalled];
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare
{
    return [QQApiInterface isQQSupportApi] ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    return [TencentOAuth iphoneQQSupportSSOLogin] ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay
{
    //暂时没有实现QQ的支付功能
    return MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (NSString *)appInstallUrl {
    return [QQApiInterface getQQInstallUrl];
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info
{
    NSString * appID = [info stringValueForKey:@"id"];
    if (appID.length) {
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:appID andDelegate:[MySocialSNSManager shareManager]];
    }else {
        tencentOAuth = nil;
    }
    
    return tencentOAuth != nil;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context
{
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }else {
        return [QQApiInterface handleOpenURL:url delegate:[MySocialSNSManager shareManager]];
    }
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context
{
    QQApiObject * qqApiObject = nil;
    
    MySocialShareBaseMessage * message = context.info;
    if (message.messageType == MyShareMessageTypeText) {
        qqApiObject = [QQApiTextObject objectWithText:[(MySocialShareTextMessage *)message text]];
    }else {
        
        NSString * title = [(MySocialShareBaseMediaMessage *)message title];
        NSString * description = [(MySocialShareBaseMediaMessage *)message description];
        NSData * thumbData = [(MySocialShareBaseMediaMessage *)message thumbData];

        switch (message.messageType) {
            case MyShareMessageTypeImage:
                qqApiObject = [QQApiImageObject objectWithData:[(MySocialShareImageMessage *)message imageData]
                                              previewImageData:thumbData
                                                         title:title
                                                   description:description];
            break;
            
            case MyShareMessageTypeMusic:
            {
                NSString * musicStreamUrl = [(MySocialShareMusicMessage *)message musicStreamUrl];
                
                if (musicStreamUrl) {
                    qqApiObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:musicStreamUrl]
                                                            title:title
                                                      description:description
                                                 previewImageData:thumbData];
                }else {
                    qqApiObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:[(MySocialShareMusicMessage *)message musicUrl]]
                                                           title:title
                                                     description:description
                                                previewImageData:thumbData];
                }
                
            }

            break;
            
            case MyShareMessageTypeVideo:
                qqApiObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:[(MySocialShareVideoMessage *)message videoUrl]]
                                                       title:title
                                                 description:description
                                            previewImageData:thumbData];
            break;
            
            
            case MyShareMessageTypeWebpage:
                qqApiObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:[(MySocialShareWebpageMessage *)message webpageUrl]]
                                                       title:title
                                                 description:description
                                            previewImageData:thumbData];
            break;
            
            default:
            break;
        }
    }

    QQApiSendResultCode resultCode;
    
    SendMessageToQQReq * req = [SendMessageToQQReq reqWithContent:qqApiObject];
    if ([context.target.name isEqualToString:MySocialSNSTargetItemNameQQ]) {
        resultCode = [QQApiInterface sendReq:req];
    }else {
        resultCode = [QQApiInterface SendReqToQZone:req];
        
#if DEBUG
        if (resultCode == EQQAPIQZONENOTSUPPORTTEXT ) {
            NSLog(@"qzone分享不支持text类型分享 已转换为分享到QQ");
        }else if (resultCode == EQQAPIQZONENOTSUPPORTIMAGE) {
            NSLog(@"qzone分享不支持image类型分享 已转换为分享到QQ");
        }
#endif
        //转换到QQ分享
        if (resultCode >= EQQAPIQZONENOTSUPPORTTEXT) {
            resultCode = [QQApiInterface sendReq:req];
        }
    }
    
    return resultCode == EQQAPISENDSUCESS;
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context
{
    NSArray * permissions = @[kOPEN_PERMISSION_GET_INFO,
                              kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                              kOPEN_PERMISSION_GET_USER_INFO];
    
    //已授权则重新授权，否则
    return [tencentOAuth authorize:permissions];
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context {
    return NO;
}

@end

#endif

//----------------------------------------------------------

#if XYYSOCIALSNS_WEIBO_ENABLED

@implementation WeiboSDK (MyShareTargetProtocol)

+ (NSString *)appName {
    return MySocialSNSManagerLocalizedString(@"AppName_WB");
}

+ (BOOL)isAppInstalled {
    return [self isWeiboAppInstalled];
}

+ (MySocialSNSTargetSupportResultType)isAppSupportShare
{
    return [self isCanShareInWeiboAPP] ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportSSO
{
    return [self isCanSSOInWeiboApp] ? MySocialSNSTargetSupportResultTypeSupport :MySocialSNSTargetSupportResultTypeCanSupport;
}

+ (MySocialSNSTargetSupportResultType)isAppSupportPay
{
    //暂时没有实现微博的支付功能
    return MySocialSNSTargetSupportResultTypeUnSupport;
}

+ (NSString *)appInstallUrl {
    return [self getWeiboAppInstallUrl];
}

+ (BOOL)registerAppWithInfo:(NSDictionary *)info
{
    
#if DEBUG
    [self enableDebugMode:YES];
#endif
    
    NSString * appKey = [info stringValueForKey:@"key"];
    if (appKey.length) {
        return [self registerApp:appKey];
    }
    
    return NO;
}

+ (BOOL)handleOpenURL:(NSURL *)url withContext:(_MySocialSNSContext *)context {
    return [self handleOpenURL:url delegate:[MySocialSNSManager shareManager]];
}

+ (BOOL)startShareWithContext:(_MySocialSNSContext *)context
{
    WBMessageObject * wbMessageObject = [WBMessageObject message];
    
    MySocialShareBaseMessage * message = context.info;
    if (message.messageType == MyShareMessageTypeText) {
        wbMessageObject.text = [(MySocialShareTextMessage *)message text];
    }else if (message.messageType == MyShareMessageTypeImage) {

        WBImageObject * imageObject = [WBImageObject object];
        imageObject.imageData = [(MySocialShareImageMessage *)message imageData];
        
#if DEBUG
      
        if (imageObject.imageData == nil) {
            NSLog(@"分享到微博的图片消息必须包含图片数据，由于当前为包含，所以将不显示图片");
        }
#endif
        wbMessageObject.imageObject = imageObject;
        wbMessageObject.text = [(MySocialShareImageMessage *)message title];
        
    }else {
        
        WBBaseMediaObject * mediaObject = nil;
        
        switch (message.messageType) {
            case MyShareMessageTypeVideo:
            {
                WBVideoObject * videoObject = [WBVideoObject object];
                videoObject.videoUrl = [(MySocialShareVideoMessage *)message videoUrl];
                videoObject.videoStreamUrl = [(MySocialShareVideoMessage *)message videoStreamUrl];
                videoObject.objectID = videoObject.videoUrl;
                
                mediaObject = videoObject;
            }
            
            break;
            
            case MyShareMessageTypeMusic:
            {
                WBMusicObject * musicObject = [WBMusicObject object];
                musicObject.musicUrl = [(MySocialShareMusicMessage *)message musicUrl];
                musicObject.musicStreamUrl = [(MySocialShareMusicMessage *)message musicStreamUrl];
                musicObject.objectID = musicObject.musicUrl;
                
                mediaObject = musicObject;
            }
            
            break;
            
            case MyShareMessageTypeWebpage:
            {
                WBWebpageObject * webpageObject = [WBWebpageObject object];
                webpageObject.webpageUrl = [(MySocialShareWebpageMessage *)message webpageUrl];
                webpageObject.objectID = webpageObject.webpageUrl;

                mediaObject = webpageObject;
            }
            break;
            
            
            default:
            break;
        }
        
        mediaObject.title = [(MySocialShareBaseMediaMessage *)message title];
        mediaObject.description = [(MySocialShareBaseMediaMessage *)message description];
        mediaObject.thumbnailData = [(MySocialShareBaseMediaMessage *)message thumbData];
        wbMessageObject.mediaObject = mediaObject;
        
        wbMessageObject.text = [(MySocialShareImageMessage *)message title];
    }
    
    WBSendMessageToWeiboRequest * req = [WBSendMessageToWeiboRequest requestWithMessage:wbMessageObject];
    req.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    
    return [self sendRequest:req];
}

+ (BOOL)startAuthorizeWithContext:(_MySocialSNSContext *)context
{
    WBAuthorizeRequest * authorizeRequest = [WBAuthorizeRequest request];
    authorizeRequest.redirectURI = [[MySocialSNSManager _socialSNSTargetIdentifyInfo:context.target.name] objectForKey:@"redirectURI"];
    authorizeRequest.redirectURI = authorizeRequest.redirectURI ?: @"http://www.sina.com";
    authorizeRequest.scope = @"all";
    
    //开始授权
    return [self sendRequest:authorizeRequest];
}

+ (BOOL)startPayWithContext:(_MySocialSNSContext *)context {
    return NO;
}

@end

#endif

//----------------------------------------------------------

#if XYYSOCIALSNS_ALIPAY_ENABLED

@implementation AlipaySDK (MyShareTargetProtocol)

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
        [[self defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [self _completedPayCallbackWithResultDic:resultDic];
        }];
        
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
        [[self defaultService] payOrder:orderStr
                             fromScheme:scheme
                               callback:^(NSDictionary *resultDic) {
                                   [self _completedPayCallbackWithResultDic:resultDic];
                               }];
        
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

#endif

