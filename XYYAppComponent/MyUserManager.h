//
//  MyUserManager.h
//  
//
//  Created by LeslieChen on 15/3/19.
//  Copyright (c) 2015年 ED. All rights reserved.
//
//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

typedef NS_ENUM(NSUInteger, MyUserHandleType) {
    MyUserHandleTypeLogin    = 1,
    MyUserHandleTypeRegister = 1 << 1,
    MyUserHandleTypeAuth     = 1 << 2,
    MyUserHandleTypeExit     = 1 << 3
};

//----------------------------------------------------------

//用户操作成功通知
UIKIT_EXTERN NSString *const MyUserHandleSuccessNotification;
//用户操作失败通知
UIKIT_EXTERN NSString *const MyUserHandleFailNotification;

//获取用户操作类型
#define MyUserHandleType(info) ((MyUserHandleType)[info[MyUserHandleTypeUserInfoKey] unsignedIntegerValue])

//操作类型
UIKIT_EXTERN NSString *const MyUserHandleTypeUserInfoKey;

//失败的原因
UIKIT_EXTERN NSString *const MyUserHandleFailErrorUserInfoKey;
#define MyUserHandleFailError(info) info[MyUserHandleFailErrorUserInfoKey]

//成功的信息
UIKIT_EXTERN NSString *const MyUserHandleInfoUserInfoKey;
#define MyUserHandleInfo(info) info[MyUserHandleInfoUserInfoKey]


//当前用户状态改变通知
UIKIT_EXTERN NSString *const MyCurrentUserStatusDidChangeNotification;

//先前的状态
UIKIT_EXTERN NSString *const MyFromUserStatusUserInfoKey;
#define MyFromUserStatus(info) [info[MyFromUserStatusUserInfoKey] unsignedIntegerValue]


//用户信息改变的通知
UIKIT_EXTERN NSString * const MyCurrentUserInfoDidChangeNotification;

//用户改变的信息
UIKIT_EXTERN NSString * const MyCurrentUserChangedInfoUserInfoKey;
#define MyCurrentUserChangedInfo(info) info[MyCurrentUserChangedInfoUserInfoKey]

//----------------------------------------------------------

//用户状态
typedef NS_ENUM(NSInteger, MyUserStatus) {
    MyUserStatusNone,   //无当前用户
    MyUserStatusNoAuth, //当前用户没有授权，自动登录成功前持续的状态,可以返回用户数据但无法访问接口
    MyUserStatusValid   //当前用户有效
};

//----------------------------------------------------------

@interface MyUserManager : NSObject

+ (instancetype)shareManager;

//用户模型类
+ (Class)userModelClass;

//开始用户操作
- (BOOL)beginUserHandle:(MyUserHandleType)handleType withInfo:(NSDictionary *)info;

//操作的具体实现，由子类实现
- (void)userHandle:(MyUserHandleType)handleType withInfo:(NSDictionary *)info;

//用户操作的回调,由子类调用
- (void)userHandle:(MyUserHandleType)handleType successWithInfo:(NSDictionary *)info;
- (void)userHandle:(MyUserHandleType)handleType failWithError:(NSError *)error info:(NSDictionary *)info;

//取消用户操作如果必要的话
- (void)cancleUserHandleIfNeed:(MyUserHandleType)handleType;
//取消用户操作由子类实现
- (void)cancleUserHandle:(MyUserHandleType)handleType;

//返回此类型操作是否在进行
- (BOOL)isHandleingWithType:(MyUserHandleType)handleType;

//当前用户状态
@property(nonatomic,readonly) MyUserStatus currentUserStatus;
//无当前用户则返回nil
@property(nonatomic,strong,readonly) id currentUser;
//退出当前用户,authInvaild(授权失效)
- (void)exitCurrentUser:(BOOL)authInvaild;


//保存当前用户信息到文件
- (void)saveCurrentUserInfoToFile;
//清除当前用户信息
+ (void)clearCurrentUserInfo;

//是否有有效地用户
@property(nonatomic,readonly) BOOL hasVaildUser;
//清除当期用户的授权信息
- (void)clearCurrentUserAuthInfo;

//是否有登录授权信息(子类实现)
- (BOOL)hasUserAuthInfo;
//更新用户登录授权信息(子类实现)
- (void)updateUserAuthInfo:(NSDictionary *)info;
//移除用户登录授权信息(子类实现)
- (void)removeUserAuthInfo;


//返回用于记录登录的信息，子类重载实现
+ (NSDictionary *)getLoginRecorderInfoWithInfo:(NSDictionary *)info;


//用户登录记录，记录用户名等等信息
+ (void)clearLoginRecorder;
//最近登录记录信息
+ (NSDictionary *)recentLoginRecorderInfo;


//更新用户信息
- (void)updateUserInfo:(NSDictionary *)info;

@end

//----------------------------------------------------------


