//
//  ED_ShareManager.h
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MySocialShareTargetItem.h"
#import "MySocialShareBaseMessage.h"

//----------------------------------------------------------

//错误域
UIKIT_EXTERN NSString * const MySocialSNSErrorDomain;

//----------------------------------------------------------

//开始操作失败
#define MySocialSNSHandleStartFailErrorCode      1001

//目标不支持功能
#define MySocialSNSUnSupportErrorCode            2001
//目标未安装错误
#define MySocialSNSUnInstallErrorCode            2002
//目标版本过低不支持
#define MySocialSNSVersionUnSupportErrorCode     2003

//操作的信息不完整错误（比如分享的消息不完整）
#define MySocialSNSHandleInfoUnCompleteErrorCode 3001

//用户取消错误
#define MySocialSNSUserCancleErrorCode           4001
//操作返回错误
#define MyShareSNSHandleFailErrorCode            4002

//----------------------------------------------------------

//第三方平台支持某种功能的结果
typedef NS_ENUM(NSInteger, MySocialSNSTargetSupportResultType) {
    //支持
    MySocialSNSTargetSupportResultTypeSupport,
    //不支持（完全不支持）
    MySocialSNSTargetSupportResultTypeUnSupport,
    //可以支持，但由于没安装或者版本原因不支持
    MySocialSNSTargetSupportResultTypeCanSupport
};

//第三方平台支付的结果状态
typedef NS_ENUM(NSInteger, MySocialSNSPayResultStatus) {
    //成功
    MySocialSNSPayResultStatusSuccess,
    //失败
    MySocialSNSPayResultStatusFail,
    //结果不确定（有可能成功，需要去服务器核对状态）
    MySocialSNSPayResultStatusUncertain
};

//----------------------------------------------------------

@interface MySocialSNSPayContext : NSObject

//微信相关
- (id)initWXPayContextWithPartnerId:(NSString *)partnerId
                           prepayId:(NSString *)prepayId
                           nonceStr:(NSString *)nonceStr
                          timestamp:(NSUInteger)timestamp
                            package:(NSString *)package
                               sign:(NSString *)sign;

//商户id
@property(nonatomic,strong,readonly) NSString * partnerId;
//预支付订单id
@property(nonatomic,strong,readonly) NSString * prepayId;
//随机字符串
@property(nonatomic,strong,readonly) NSString * nonceStr;
//package
@property(nonatomic,strong,readonly) NSString * package;
//timestamp时间戳
@property(nonatomic,readonly) NSUInteger timestamp;
//签名
@property(nonatomic,strong,readonly) NSString * sign;


//支付宝
- (id)initAliPayContextWithOrderStr:(NSString *)orderStr;

//订单详情string
@property(nonatomic,strong,readonly) NSString * orderStr;


@end

//----------------------------------------------------------

@protocol MySocialSNSDelegate <NSObject>

@optional

/**
 * 完成分享的回调
 * @param message message为分享的消息
 * @param target target为分享的目标
 * @param error error为错误信息，成功时改值为nil
 */
- (void)    shareMessgae:(MySocialShareBaseMessage *)message
                toTarget:(MySocialSNSTargetItem *)target
      completedWithError:(NSError *)error;


/**
 * 完成第三方授权的回调
 * @param target target为分享的目标
 * @param accessToken accessToken为授权的access，微信授权没有该值
 * @param openId openId为标识用户的id
 * @param code 仅仅对于微信有效
 * @param error error为错误信息，成功时改值为nil
 */
- (void)    authorizeForTarget:(MySocialSNSTargetItem *)target
      completedWithAccessToken:(NSString *)accessToken
                        openId:(NSString *)openId
                          code:(NSString *)code
                         error:(NSError *)error;

/**
 * 完成第三方支付的回调
 * @param payInfo payInfo为支付的订单信息
 * @param target target为支付的目标
 * @param status status为支付结果的状态
 * @param error error为错误信息，成功时该值为nil
 */
- (void)    payWithInfo:(NSDictionary *)payInfo
               toTarget:(MySocialSNSTargetItem *)target
    completedWithStatus:(MySocialSNSPayResultStatus)status
               andError:(NSError *)error;


@end

//----------------------------------------------------------

@interface MySocialSNSManager : NSObject

/**
 * 是否有社会化平台的身份信息（key等等）
 * @param targetItmeName targetItmeName为目标平台的名字
 */
+ (BOOL)hasSocialSNSTargetIdentifyInfo:(MySocialSNSTargetItemName)targetItmeName;

/**
 * 手机是否安装目标平台
 * @param targetItmeName targetItmeName为目标平台的名字
 */
+ (BOOL)isInstallSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName;

/**
 * 目标平台是否支持分享
 * @param targetItmeName targetItmeName为目标平台的名字
 */
+ (MySocialSNSTargetSupportResultType)isSupportShareForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName;

/**
 * 目标平台是否支持OSS授权
 * @param targetItmeName targetItmeName为目标平台的名字
 */
+ (MySocialSNSTargetSupportResultType)isSupportSSOForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName;

/**
 * 目标平台是否支持支付
 * @param targetItmeName targetItmeName为目标平台的名字
 */
+ (MySocialSNSTargetSupportResultType)isSupportPayForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName;


/**
 * 获取社会化分享目标平台应用的名称
 * @param targetItmeName targetItmeName为目标平台的名字
 */
+ (NSString *)appNameForSocialSNSTarget:(MySocialSNSTargetItemName)targetItmeName;


/**
 * 应用完成加载时调用该方法
 */
+ (void)applicationDidFinishLaunching;

/**
 * 应用处理URL时调用改方法
 * @param url url为应用处理的URL
 */
+ (BOOL)handleOpenURL:(NSURL *)url;


/**
 * 开始分享信息到第三方社交平台
 * @param message message为需要分享的信息
 * @param target target为分享的目标
 * @param delegate delegate为回调的代理
 * @return 如果开始分享失败则返回相应错误，可能是消息不合法，或目标不可用等等错误
 */
+ (NSError *)startShareMessgae:(MySocialShareBaseMessage *)message
                      toTarget:(MySocialSNSTargetItem *)target
                  withDelegate:(id<MySocialSNSDelegate>)delegate;


/**
 * 开始第三方授权
 * @param target target为需要授权的目标
 * @param showWebViewIfNeed showWebViewIfNeed指示是否显示web登陆如果没有安装应用或版本过低不支持授权,默认为YES
 * @param showAppInstallPageIfNeed showAppInstallPageIfNeed指示当应用没有安装时显示应用安装链接,默认为YES
 * @param viewController viewController为当前的视图控制器
 * @param delegate delegate为回调的代理
 * @return 如果开始授权失败则返回相应错误
 */
+ (NSError *)startAuthorizeForTarget:(MySocialSNSTargetItem *)target
                      viewController:(UIViewController *)viewController
                        withDelegate:(id<MySocialSNSDelegate>)delegate;
+ (NSError *)startAuthorizeForTarget:(MySocialSNSTargetItem *)target
                   showWebViewIfNeed:(BOOL)showWebViewIfNeed
            showAppInstallPageIfNeed:(BOOL)showAppInstallPageIfNeed
                      viewController:(UIViewController *)viewController
                        withDelegate:(id<MySocialSNSDelegate>)delegate;

/**
 * 开始第三方支付
 * @param context context为支付的订单上下文
 * @param target target为需要支付的目标
 * @param showAppInstallPageIfNeed showAppInstallPageIfNeed指示当应用没有安装或者版本过低不支持时显示应用安装链接
 * @param viewController viewController为当前的视图控制器
 * @param delegate delegate为回调的代理
 * @return 如果开始授权失败则返回相应错误
 */
+ (NSError *)   startPayWithContext:(MySocialSNSPayContext *)context
                           toTarget:(MySocialSNSTargetItem *)target
           showAppInstallPageIfNeed:(BOOL)showAppInstallPageIfNeed
                     viewController:(UIViewController *)viewController
                       withDelegate:(id<MySocialSNSDelegate>)delegate;



@end
