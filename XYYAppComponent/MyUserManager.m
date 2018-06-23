//
//  MyUserManager.m
//  
//
//  Created by LeslieChen on 15/3/19.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyUserManager.h"
#import "MyUserModel.h"
#import "XYYFoundation.h"
#import "XYYModel.h"

//----------------------------------------------------------

#define MyUserManagerDomain @"MyUserManagerDomain"

//----------------------------------------------------------

#define MyUserLoginRecorderInfoKey @"%_MyUserManager_MyUserLoginRecorderInfoKey_%"

//----------------------------------------------------------

NSString *const MyUserHandleSuccessNotification = @"MyUserManager_MyUserHandleSuccessNotification";
NSString *const MyUserHandleFailNotification = @"MyUserManager_MyUserHandleFailNotification";

NSString *const MyUserHandleTypeUserInfoKey = @"MyUserManager_MyUserHandleTypeUserInfoKey";
NSString *const MyUserHandleFailErrorUserInfoKey = @"MyUserManager_MyUserHandleFailErrorUserInfoKey";
NSString *const MyUserHandleInfoUserInfoKey = @"MyUserManager_MyUserHandleInfoUserInfoKey";

NSString *const MyCurrentUserStatusDidChangeNotification = @"MyUserManager_MyCurrentUserStatusDidChangeNotification";
NSString *const MyFromUserStatusUserInfoKey = @"MyFromUserStatusUserInfoKey";

NSString * const MyCurrentUserInfoDidChangeNotification = @"MyUserManager_MyCurrentUserInfoDidChangeNotification";
NSString * const MyCurrentUserChangedInfoUserInfoKey = @"MyUserManager_MyCurrentUserChangedInfoUserInfoKey";

//----------------------------------------------------------

@interface MyUserManager ()

//记录是否在处理的掩码
@property(nonatomic) NSUInteger handleingMask;

//当前的登录信息
@property(nonatomic,strong) NSDictionary * currentLoginInfo;
//@property(nonatomic,strong,readonly) NSString * pathForCurrentUserInfoFile;

@end

//----------------------------------------------------------

@implementation MyUserManager

//@synthesize pathForCurrentUserInfoFile = _pathForCurrentUserInfoFile;

+ (Class)userModelClass {
    return [MyUserModel class];
}

+ (instancetype)shareManager
{
    static MyUserManager * shareUserManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (self == [MyUserManager class]) {
            @throw [NSException exceptionWithName:NSGenericException
                                           reason:@"MyUserManager为抽象类不能进行初始化"
                                         userInfo:nil];
            
        }
        
        shareUserManager = [[super allocWithZone:nil] init];
    });
    
    return shareUserManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        if ((_currentUser = [self _createUserFromFile])) {
            [self _postCurrentStatusDidChangeNotificationFromStatus:MyUserStatusNone];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (Class)_getUserModelClass
{
    Class userModelClass = [[self class] userModelClass];
    if (![userModelClass isSubclassOfClass:[MyUserModel class]]) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"userModelClass必须为MyUserMode的子类"
                                     userInfo:nil];
    }
    
    return userModelClass;
}

+ (NSString *)pathForCurrentUserInfoFile
{
    static NSString * pathForCurrentUserInfoFile = nil;
    if (!pathForCurrentUserInfoFile) {
        pathForCurrentUserInfoFile = [MyPathManager pathForType:MyPathTypeDocument
                                                     directory:@"UserInfo"
                                                     fileName:@"CurrentUserInfo.data"];
    }
    
    return pathForCurrentUserInfoFile;
}

- (MyUserModel *)_createUserFromFile
{
    @try {
        MyUserModel * user = [NSKeyedUnarchiver unarchiveObjectWithFile:[MyUserManager pathForCurrentUserInfoFile]];
        if (user && ![user isKindOfClass:[self _getUserModelClass]]) {
            NSLog(@"获取到的用户数据不正常");
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"获取到的用户数据不正常"
                                         userInfo:nil];
        }
        
        return user;
    }
    @catch (NSException *exception) {
        NSLog(@"从文件获取用户数据失败，已删除数据");
        [[NSFileManager defaultManager] removeItemAtPath:[MyUserManager pathForCurrentUserInfoFile]
                                                   error:NULL];
        return nil;
    }
    
}

- (id)_createUserFromInfo:(NSDictionary *)info {
    return info ? [[[self _getUserModelClass] alloc] xyy_initWithDictionary:info] : nil;
}

- (void)saveCurrentUserInfoToFile
{
    if (self.currentUser) {
        [NSKeyedArchiver archiveRootObject:self.currentUser toFile:[MyUserManager pathForCurrentUserInfoFile]];
    }
}

+ (void)clearCurrentUserInfo {
    [[NSFileManager defaultManager] removeItemAtPath:[MyUserManager pathForCurrentUserInfoFile] error:NULL];
}

- (void)_clearCurrentUserInfo {
    [[NSFileManager defaultManager] removeItemAtPath:[MyUserManager pathForCurrentUserInfoFile] error:NULL];
}

#pragma mark -

- (MyUserStatus)currentUserStatus
{
    MyUserModel * currentUser = self.currentUser;
    if(currentUser && self.hasUserAuthInfo){
        return MyUserStatusValid;
    }else if(currentUser){
        return MyUserStatusNoAuth;
    }else{
        return MyUserStatusNone;
    }
}

- (BOOL)hasVaildUser {
    return self.currentUserStatus == MyUserStatusValid;
}

- (BOOL)hasUserAuthInfo {
    return NO;
}

- (void)updateUserAuthInfo:(NSDictionary *)info {
    //do nothing
}

- (void)removeUserAuthInfo {
    //do nothing
}

- (void)clearCurrentUserAuthInfo
{
    if ([self hasVaildUser]) {
        [self removeUserAuthInfo];
        [self _postCurrentStatusDidChangeNotificationFromStatus:MyUserStatusValid];
    }
}


- (void)exitCurrentUser:(BOOL)authInvaild
{
    if (authInvaild) {
        [self clearCurrentUserAuthInfo];
    }
    
    [self beginUserHandle:MyUserHandleTypeExit withInfo:nil];
}

#if DEBUG

- (NSString *)_descriptionForUserStatus:(MyUserStatus)status
{
    switch (status) {
        case MyUserStatusNone:
            return @"无用户";
            break;
            
        case MyUserStatusNoAuth:
            return @"无授权";
            break;
            
        case MyUserStatusValid:
            return @"有效";
            break;
    }
}

#endif

- (void)_postCurrentStatusDidChangeNotificationFromStatus:(MyUserStatus)fromStatus
{
    DebugLog(MyUserManagerDomain, @"当前用户状态由 %@ 变为 %@",[self _descriptionForUserStatus:fromStatus],[self _descriptionForUserStatus:[self currentUserStatus]]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MyCurrentUserStatusDidChangeNotification
                                                        object:self
                                                      userInfo:@{MyFromUserStatusUserInfoKey : @(fromStatus)}];
}

#pragma mark -

- (void)_setHandleing:(BOOL)handle forType:(MyUserHandleType)handleType
{
    if (handle) {
        self.handleingMask |= handleType;
    }else{
        self.handleingMask &= ~handleType;
    }
}

- (BOOL)isHandleingWithType:(MyUserHandleType)handleType {
    return handleType & self.handleingMask;
}

#pragma mark -

- (BOOL)beginUserHandle:(MyUserHandleType)handleType withInfo:(NSDictionary *)info
{
    if ([self isHandleingWithType:handleType]) {
        return NO;
    }
    
    switch (handleType) {
        case MyUserHandleTypeLogin:
            
            if (self.currentUserStatus != MyUserStatusNone) {
                NSLog(@"用户已经登录了,登录取消");
                return NO;
            }
            
            self.currentLoginInfo = info;
            
            break;
            
        case MyUserHandleTypeAuth:
            
            if (self.currentUserStatus != MyUserStatusNoAuth) {
                NSLog(@"无用户或者用户已经授权了,授权取消");
                return NO;
            }
            
            if ([self isHandleingWithType:MyUserHandleTypeExit]) {
                NSLog(@"正在退出用户操作，无法进行授权，授权取消");
                return NO;
            }
            
            break;
            
        case MyUserHandleTypeExit:
            
            if (self.currentUserStatus == MyUserStatusNone) {
                NSLog(@"当前无用户,退出取消取消");
                return NO;
            }
            
            //取消授权
            [self cancleUserHandleIfNeed:MyUserHandleTypeAuth];
            
            break;
            
        default:
            break;
    }
    
    //设置掩码
    [self _setHandleing:YES forType:handleType];
    
    //开始处理
    [self userHandle:handleType withInfo:info];
    
    return YES;
}

- (void)userHandle:(MyUserHandleType)handleType withInfo:(NSDictionary *)info
{
    // 子类实现
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"userHandle:withInfo:需要子类实现"
                                 userInfo:nil];
    
}

- (void)userHandle:(MyUserHandleType)handleType successWithInfo:(NSDictionary *)info
{
    if (![self isHandleingWithType:handleType]) {
        return;
    }
    
    [self _setHandleing:NO forType:handleType];
    
    switch (handleType) {
        case MyUserHandleTypeLogin:
        {
            MyAssert(self.currentUserStatus == MyUserStatusNone && info);
            
            //获取的信息与登陆信息合并
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:self.currentLoginInfo];
            [userInfo addEntriesFromDictionary:info];
            info = userInfo;
            
            //创建新的用户
            _currentUser = [self _createUserFromInfo:userInfo];
            [self updateUserAuthInfo:userInfo];
            
            //记录用户信息
            [self saveCurrentUserInfoToFile];
            
            //添加登录记录的信息
            [self _addLoginRecorderInfo];
            self.currentLoginInfo = nil;
            
            //发送通知
            [self _postCurrentStatusDidChangeNotificationFromStatus:MyUserStatusNone];
            
        }
            break;
            
        case MyUserHandleTypeAuth:
        {
            MyAssert(info);
            
            //用户授权信息
            [self updateUserAuthInfo:info];
            MyAssert([self hasUserAuthInfo]);
            
            //更新用户信息
            NSDictionary * changeInfos = [(MyUserModel *)self.currentUser updateWithInfo:info];
            
            //记录用户信息
            [self saveCurrentUserInfoToFile];
            
            //发送通知
            [self _postCurrentStatusDidChangeNotificationFromStatus:MyUserStatusNoAuth];
            [self _sendUserInfoChangeNotification:changeInfos];
            
        }
            break;
            
        case MyUserHandleTypeExit:
        {
            MyUserStatus currentUserStatus = [self currentUserStatus];
            
            //清除用户数据
            _currentUser = nil;
            [self removeUserAuthInfo];
            [self _clearCurrentUserInfo];
            
            //发送通知
            [self _postCurrentStatusDidChangeNotificationFromStatus:currentUserStatus];
        }
            
        default:
            break;
    }
    
    //发送用户操作成功信息
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:@(handleType) forKey:MyUserHandleTypeUserInfoKey];
    if (info.count) [userInfo setValue:info forKey:MyUserHandleInfoUserInfoKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:MyUserHandleSuccessNotification
                                                        object:self
                                                      userInfo:userInfo];
    
}

- (void)userHandle:(MyUserHandleType)handleType failWithError:(NSError *)error info:(NSDictionary *)info
{
    if (![self isHandleingWithType:handleType]) {
        return;
    }
    
    [self _setHandleing:NO forType:handleType];
    
    //发送用户操作失败信息
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:@(handleType) forKey:MyUserHandleTypeUserInfoKey];
    if (error) [userInfo setValue:error forKey:MyUserHandleFailErrorUserInfoKey];
    
    //发送并清空登陆信息
    if (handleType == MyUserHandleTypeLogin && self.currentLoginInfo.count) {
        NSMutableDictionary * tempInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        [tempInfo addEntriesFromDictionary:self.currentLoginInfo];
        info = tempInfo;
        self.currentLoginInfo = nil;
    }
    
    if (info.count) [userInfo setValue:info forKey:MyUserHandleInfoUserInfoKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MyUserHandleFailNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)cancleUserHandleIfNeed:(MyUserHandleType)handleType
{
    if ([self isHandleingWithType:handleType]) {
        [self cancleUserHandle:handleType];
        
        [self _setHandleing:NO forType:handleType];
        if (handleType == MyUserHandleTypeLogin) {
            self.currentLoginInfo = nil;
        }
    }
}

- (void)cancleUserHandle:(MyUserHandleType)handleType
{
    // 子类实现
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"cancleUserHandle:需要子类实现"
                                 userInfo:nil];
    
}

#pragma mark -

+ (NSDictionary *)getLoginRecorderInfoWithInfo:(NSDictionary *)info {
    return info;
}

- (void)_addLoginRecorderInfo
{
    NSDictionary * loginRecorderInfo = [[self class] getLoginRecorderInfoWithInfo:self.currentLoginInfo];
    
    if (loginRecorderInfo.count) {
        [[NSUserDefaults standardUserDefaults] setValue:loginRecorderInfo forKey:MyUserLoginRecorderInfoKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary *)recentLoginRecorderInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:MyUserLoginRecorderInfoKey];
}

+ (void)clearLoginRecorder
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MyUserLoginRecorderInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

- (void)_applicationWillResignActive:(NSNotification *)notification {
    [self saveCurrentUserInfoToFile];
}

#pragma mark -

- (void)updateUserInfo:(NSDictionary *)info
{
    MyUserModel * user = [self currentUser];
    if (user && info.count) {
        [self _sendUserInfoChangeNotification:[user updateWithInfo:info]];
    }
}

- (void)_sendUserInfoChangeNotification:(NSDictionary *)changedInfo
{
    if(changedInfo.count){
        [[NSNotificationCenter defaultCenter] postNotificationName:MyCurrentUserInfoDidChangeNotification
                                                            object:nil
                                                          userInfo:@{MyCurrentUserChangedInfoUserInfoKey : changedInfo}];
        
    }
}


@end
