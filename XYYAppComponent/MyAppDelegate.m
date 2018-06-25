//
//  MyAppDelegate.m
//  5idj
//
//  Created by LeslieChen on 14-9-28.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyAppDelegate.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

#define MyKAppID                        @"AppID"                      //app的ID
#define MyKAppBundleInfo                @"AppBundleInfo"              //app包信息
#define MyKAppVersion                   @"AppVersion"                 //app的版本
#define MyKLastAppVersion               @"LastAppVersion"             //上一次安装的app的版本
#define MyKAppBuild                     @"AppBuild"                   //app的构建版本（完整版本）
#define MyKUserGuideViewVersion         @"UserGuideViewVersion"       //用户引导页版本
#define MyKAppLaunchTimes               @"AppLaunchTimes"             //当前版本app加载的次数
#define MyKAppEnterForegroundTimes      @"AppEnterForegroundTimes"    //当前版本app进入前台的次数，即点击次数
#define MyKAppLastLaunchDate            @"AppLastLaunchDate"          //app上一次加载的时间
#define MyKAppLastEnterForegroundDate   @"AppLastEnterForegroundDate" //app上一次进入前台的时间
#define MyKAppContinuousClickDays       @"AppContinuousClickDays"     //app连续点击的天数
#define MyKHadSorceApp                  @"HadSorceApp"                //是否评价了当前版本的app
#define MyKAppIgnoreSorceTimes          @"AppIgnoreSorceTimes"        //忽略评价的次数
//#define MyKHadIgnoreNewVersion          @"HadIgnoreNewVersion"        //忽略了的新版本更新

#define MyKAppLocalNotificationIdentifier   @"AppLocalNotificationIdentifier"     //本地通知id的key

//----------------------------------------------------------

@interface MyAppDelegate ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
< UNUserNotificationCenterDelegate >
#endif

//当主窗口完成显示执行的action
@property(nonatomic,strong,readonly) NSMutableArray * mainWindowDidShowActions;

//网络状态改变的观察者
@property(nonatomic,strong) id networkStatusChangeNotificationObsever;

//预约集合
@property(nonatomic,strong,readonly) NSMutableDictionary * timers;


@end

//----------------------------------------------------------

@implementation MyAppDelegate

@synthesize window     = _window;
@synthesize appVersion = _appVersion;
@synthesize appBuild   = _appBuild;
@synthesize appID      = _appID;
//@synthesize appUMKey   = _appUMKey;
@synthesize mainWindowDidShowActions = _mainWindowDidShowActions;
@synthesize timers = _timers;

#pragma mark - life circle

+ (instancetype)appDelegate {
    return (id)[UIApplication sharedApplication].delegate;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        NSDictionary * appVersionInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppVersionConfig" ofType:@"plist"]];
        
        //获取key及版本数据
        _appID = [appVersionInfo stringValueForKey:MyKAppID];
        _userGuideViewVersion = [appVersionInfo stringValueForKey:MyKUserGuideViewVersion];
        
        NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _appBuild   = [infoDictionary objectForKey:@"CFBundleVersion"];
        _appBundleIdentifier = [infoDictionary objectForKey:@"CFBundleName"];
        _appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        _appScheme = [[[[infoDictionary objectForKey:@"CFBundleURLTypes"] firstObject] objectForKey:@"CFBundleURLSchemes"] firstObject];
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * appVersion = [userDefaults objectForKey:MyKAppVersion];
        if (![appVersion isEqualToString:_appVersion]) { //app版本改变记录上一次安装App的版本
            _lastInstallAppVersion = appVersion;
            [userDefaults setObject:_appVersion forKey:MyKAppVersion];
            [userDefaults setObject:_lastInstallAppVersion forKey:MyKLastAppVersion];
        }else {
            _lastInstallAppVersion = [userDefaults objectForKey:MyKLastAppVersion];
        }
    }
    
    return self;
}

#pragma mark -

- (NSString *)appIdentifier {
    return [NSString stringWithFormat:@"%@.%@",_appID,_appBundleIdentifier];
}

- (void)setAppBundleInfo:(MyApplicationBundleInfo)appBundleInfo {
    [[NSUserDefaults standardUserDefaults] setInteger:appBundleInfo forKey:MyKAppBundleInfo];
}

- (MyApplicationBundleInfo)appBundleInfo {
    return [[NSUserDefaults standardUserDefaults] integerForKey:MyKAppBundleInfo];
}


//- (void)appBundleInfoDidChangeForm:(MyApplicationBundleInfo)oldBundleInfo {
//    //do nothing
//}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DefaultDebugLog(@"应用状态变为完成加载");
    
    _applicationState = MyApplicationStateDidFinishLaunching;
    _launchOptions = launchOptions;
    
    //计数
    [self _launchApp];
    
    
    //第一次启动当前版本APP
    if ([[self class] isFirstLaunchApp]) {
        [self doSomethingWhenAppFirstLaunch];
    }
    
    //开始显示视图
    [self startShowView];
    
    return YES;
}

//进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DefaultDebugLog(@"应用状态变为将要进入前台");
    _applicationState = MyApplicationStateWillEnterForeground;
    
    [self _clickApp];
}

//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _applicationState = MyApplicationStateBackground;
    DefaultDebugLog(@"应用状态变为已进入后台");
}

//未激活
- (void)applicationWillResignActive:(UIApplication *)application
{
    _applicationState = MyApplicationStateInactive;
    DefaultDebugLog(@"应用状态变为未激活");
}

//激活
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _applicationState = MyApplicationStateActive;
    DefaultDebugLog(@"应用状态变为激活");
}

#pragma mark -

- (void)_launchApp
{
    //记录加载次数及时间
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@([[NSDate date] timeIntervalSince1970]) forKey:MyKAppLastLaunchDate];
    [userDefaults setObject:@([[self class] appLaunchTimes] + 1) forKey:MyKAppLaunchTimes];
    
    
    [self appDidLaunch];
    
    //点击app
    [self _clickApp];
}

- (void)appDidLaunch {
    // do nothing
}

- (void)_clickApp
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //点击次数+1
    NSUInteger appEnterForegroundTimes = [[self class] appClickTimes] + 1;
    [userDefaults setObject:@(appEnterForegroundTimes) forKey:MyKAppEnterForegroundTimes];
    
    //上一次点击的日期
    NSDate * lastClickDate = [[self class] appLastClickDate];
    
    NSDate * now = [NSDate date]; //上一次点击的日期和昨天是同一天，则连续点击次数+1
    if (lastClickDate && [lastClickDate isSameDay:[now dateWithMoveDay:-1]]) {
        [userDefaults setObject:@([[self class] appContinuousClickDays] + 1) forKey:MyKAppContinuousClickDays];
    }else if(!lastClickDate || ![lastClickDate isSameDay:now]) { //无上一次点击时间或者上一次点击时间不是今天则将次数置为1
        [userDefaults setObject:@1 forKey:MyKAppContinuousClickDays];
    }
    
    //记录点击时间
    [userDefaults setObject:@([now timeIntervalSince1970]) forKey:MyKAppLastEnterForegroundDate];
    
    //click回调
    [self appDidClick];
    
    //显示去评价app
    if ([[self class] canShowScoreAlertView] && self.showScoreAlertViewPerClickTimes &&
        appEnterForegroundTimes % self.showScoreAlertViewPerClickTimes == 0) {
        [self showScoreAlertView];
    }
}

- (void)appDidClick {
    //do nothing
}

+ (NSUInteger)appLaunchTimes;
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //获取版本信息
    NSString * appBuild = [[userDefaults objectForKey:MyKAppBuild] description];
    NSString * currentAppBuild = [(MyAppDelegate *)[self appDelegate] appBuild];
    
    //版本号改变，重置值
    if (![appBuild isEqualToString:currentAppBuild]) {
        [userDefaults setObject:currentAppBuild forKey:MyKAppBuild];
        
        [userDefaults removeObjectForKey:MyKAppLaunchTimes];
        [userDefaults removeObjectForKey:MyKAppEnterForegroundTimes];
        [userDefaults removeObjectForKey:MyKAppContinuousClickDays];
        [userDefaults removeObjectForKey:MyKAppLastLaunchDate];
        [userDefaults removeObjectForKey:MyKAppLastEnterForegroundDate];
        [userDefaults removeObjectForKey:MyKHadSorceApp];
        [userDefaults removeObjectForKey:MyKAppIgnoreSorceTimes];
    }
    
    return [[userDefaults objectForKey:MyKAppLaunchTimes] unsignedIntegerValue];
}

+ (NSUInteger)appClickTimes {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:MyKAppEnterForegroundTimes] unsignedIntegerValue];
}

+ (BOOL)isFirstLaunchApp {
    return [self appLaunchTimes] == 1;
}

+ (NSDate *)appLastLauchDate
{
    NSTimeInterval timeInterval = [[NSUserDefaults standardUserDefaults] integerForKey:MyKAppLastLaunchDate];
    return timeInterval ? [NSDate dateWithTimeIntervalSince1970:timeInterval] : nil;
}

+ (NSDate *)appLastClickDate
{
    NSTimeInterval timeInterval = [[NSUserDefaults standardUserDefaults] integerForKey:MyKAppLastEnterForegroundDate];
    return timeInterval ? [NSDate dateWithTimeIntervalSince1970:timeInterval] : nil;
}

+ (NSUInteger)appContinuousClickDays {
    return [[[NSUserDefaults standardUserDefaults]  objectForKey:MyKAppContinuousClickDays] unsignedIntegerValue];
}

#pragma mark - 

- (void)doSomethingWhenAppFirstLaunch {
    //do nothing
}

- (void)startShowView
{
    //判断是否需要显示引导视图
    if ([self needShowUserGuideView]) {
        [self showUserGuideView];
    }else{
        [self showMainWindow];
    }
}

- (BOOL)needShowUserGuideView
{
    //用户引导页的版本改变,则需要显示用户引导页面
    NSString * userGuideViewVersion = [[NSUserDefaults standardUserDefaults] objectForKey:MyKUserGuideViewVersion];
    if (self.userGuideViewVersion.length && ![userGuideViewVersion isEqualToString:self.userGuideViewVersion]) {
        return YES;
    }else {
        return NO;
    }
}

- (void)showUserGuideView {
    // do nothing
}

- (void)completedShowUserGuideView
{
    //设置引导页面版本
    if ([self userGuideViewVersion].length) {
        [[NSUserDefaults standardUserDefaults] setObject:[self userGuideViewVersion] forKey:MyKUserGuideViewVersion];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:MyKUserGuideViewVersion];
    }
}

- (void)showMainWindow {
}

- (void)completedShowMainWindow
{
    if (!self.appDidShowMainWindow) {
        _appDidShowMainWindow = YES;
        
        //尝试注册通知
        [self _tryRegisterRemoteNotification];
        
        //尝试注册3D Touch快捷项目
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        [self _tryRegister3DTouchShortcutItems];
#endif
        
        //处理通知
        if (!GreaterThanIOS10System) {
            
            //远程通知
            if (![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
                
                NSDictionary * remoteNotificationInfo = self.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
                if (remoteNotificationInfo) {
                    [self applicationDidReceiveRemoteNotification:remoteNotificationInfo
                                                            state:MyApplicationReceiveNotificationStateLaunchApp isTap:YES];
                }
            }
            
            //本地通知
            UILocalNotification * localNotification = self.launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
            if (localNotification) {
                [self applicationDidReceiveLocalNotification:localNotification.userInfo state:MyApplicationReceiveNotificationStateLaunchApp isTap:YES];
            }
            
        }
        
        //执行action并移除
        for (void(^action)(void) in _mainWindowDidShowActions) {
            action();
        }
        [_mainWindowDidShowActions removeAllObjects];
        
        //注册计时器
        [self setupRegisterTimer];
        
        _launchOptions = nil;
    }
}

- (NSMutableArray *)mainWindowDidShowActions
{
    if (!_mainWindowDidShowActions) {
        _mainWindowDidShowActions = [NSMutableArray array];
    }
    
    return _mainWindowDidShowActions;
}

- (void)performActionWhenDidShowMainWindow:(void (^)(void))action
{
    if (action) {
        if (self.appDidShowMainWindow) {
            action();
        }else {
            [self.mainWindowDidShowActions addObject:[action copy]];
        }
    }
}

#pragma mark - check update and app store

+ (void)openInAppStore
{
    NSString * appID = [[self appDelegate] appID];
    if (appID.length) {
        gotoAppStore(appID);
    }
}

+ (void)openInAppStoreReview
{
    NSString * appID = [[self appDelegate] appID];
    if (appID.length) {
        gotoAppStoreReview(appID);
    }
}

+ (BOOL)canShowScoreAlertView {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:MyKHadSorceApp];
}

- (NSString *)scoreAlertViewContentText {
    return _scoreAlertViewContentText ? : @"亲，你觉得怎么样？去评价一下吧。\n我们不完美，但我们会一直努力。\n你的肯定是我们最大的动力。";
}

- (void)showScoreAlertView
{
    UIAlertView * alertView = [UIAlertView alertWithCallBackBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    
        MyAppScoreAlertViewResult result = MyAppScoreAlertViewResultIgnore;
        if (alertView.cancelButtonIndex == buttonIndex) {
            result = MyAppScoreAlertViewResultDeny;
        }else if(alertView.firstOtherButtonIndex == buttonIndex){
            result = MyAppScoreAlertViewResultGoto;
        }
        
        [self scoreAlertViewCompletedShowWithResult:result];
        
    }
                                                            title:@"给我们评价"
                                                          message:[self scoreAlertViewContentText]
                                                 cancelButtonName:@"残忍拒绝"
                                                otherButtonTitles:@"立即评价",@"稍后提醒", nil];
    
    [alertView show];
}

+ (NSUInteger)appScoreIgnoreTimes {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:MyKAppIgnoreSorceTimes] unsignedIntegerValue];
}

- (void)scoreAlertViewCompletedShowWithResult:(MyAppScoreAlertViewResult)result
{
    if (result != MyAppScoreAlertViewResultIgnore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:MyKHadSorceApp];
        if (result == MyAppScoreAlertViewResultGoto) {
            [[self class] openInAppStoreReview];
        }
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:@([[self class] appScoreIgnoreTimes] + 1)
                                                  forKey:MyKAppIgnoreSorceTimes];
    }
}

#pragma mark -

- (void)setShowNetworkStatusChange:(BOOL)showNetworkStatusChange
{
    if (_showNetworkStatusChange != showNetworkStatusChange) {
        
        if (_showNetworkStatusChange && self.networkStatusChangeNotificationObsever) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.networkStatusChangeNotificationObsever];
            self.networkStatusChangeNotificationObsever = nil;
        }
        
        _showNetworkStatusChange = showNetworkStatusChange;
        
        if (_showNetworkStatusChange) {
            
            self.networkStatusChangeNotificationObsever =
                [[NSNotificationCenter defaultCenter] addObserverForName:NetReachabilityChangedNotification
                                                                  object:nil
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  //显示网络状态
                                                                  [self showNetworkStatus];
                                                              }];
        }
    }
}

- (void)showNetworkStatus {
    showNetworkStatusMessage(nil);
}

#pragma mark -

- (BOOL)    application:(UIApplication *)application
                openURL:(NSURL *)url
      sourceApplication:(NSString *)sourceApplication
             annotation:(id)annotation
{
    MyAssert(self.applicationState != MyApplicationStateBackground);
    
    //状态
    MyApplicationOpenURLState state;
    
    switch (self.applicationState) {
            
        case MyApplicationStateDidFinishLaunching:
            state = MyApplicationOpenURLStateLaunchApp;
            break;
            
        case MyApplicationStateWillEnterForeground:
            state = MyApplicationOpenURLStateEnterForeground;
            break;
            
        default:
            state = MyApplicationOpenURLStateActive;
            break;
    }

    
    [self performActionWhenDidShowMainWindow:^{
        [self applicationDidOpenURL:url sourceApplication:sourceApplication annotation:annotation state:state];
    }];
    
    return YES;
}

- (void)applicationDidOpenURL:(NSURL *)url
            sourceApplication:(NSString *)sourceApplication
                   annotation:(id)annotation
                        state:(MyApplicationOpenURLState)state
{
    //do nothing
}

#pragma mark -

- (BOOL)needRegisterRemoteNotification {
    return NO;
}

- (void)_tryRegisterRemoteNotification
{
    if ([self needRegisterRemoteNotification]) {
        [self registerRemoteNotification];
    }
}

- (void)registerRemoteNotification
{
    //推送注册的默认实现
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
    if (@available(iOS 10.0, *)) {
        
        UNUserNotificationCenter * uncenter = [UNUserNotificationCenter currentNotificationCenter];
        uncenter.delegate = self;
        
        //授权申请
        [uncenter requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
//                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        return;
    }
    
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    
    if (@available(iOS 8.0, *)) {
        
        //通知设置
        UIUserNotificationSettings * userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        
        //注册设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
        
        //注册通知
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                               UIRemoteNotificationTypeBadge |
                                                                               UIRemoteNotificationTypeSound )];
    }
    
#else
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound )];
#endif
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (NetNotReachable()) { //网络不可用，则网络恢复后重试
        __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NetReachabilityChangedNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification *note) {

                                                                                //删除观察
                                                                                [[NSNotificationCenter defaultCenter] removeObserver:observer];

                                                                                //重新注册
                                                                                [self _tryRegisterRemoteNotification];

                                                                            }];
    }
}

#pragma mark -

- (void)addLocalNotificationWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                  userInfo:(NSDictionary *)userInfo
                            dateComponents:(NSDateComponents *)dateComponents
                                   repeats:(BOOL)repeats
{
    identifier = identifier.length ? identifier : [NSString uniqueIDString];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
    if (@available(iOS 10.0, *)) {
        
        UNCalendarNotificationTrigger * trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:repeats];
        
        DefaultDebugLog(@"本地推送时间 %@",[[trigger nextTriggerDate] dateStringWithFormat:@"yyy-MM-dd hh:mm:ss"]);
        
        UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
        content.body = title;
        content.userInfo = userInfo;
        content.sound = [UNNotificationSound defaultSound];
        
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:[UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger] withCompletionHandler:^(NSError * error){
            
            
        }];
        
        return;
    }
    
#endif
    
    UILocalNotification *  notification = [[UILocalNotification alloc] init];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    NSDate * currentDate = [NSDate date];
    
    //生成开始时间
    NSDateComponents * fireDateComponents = [currentDate dateComponentsWithCalendar:dateComponents.calendar andUnit:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ];
    fireDateComponents.hour = dateComponents.hour;
    fireDateComponents.minute = dateComponents.minute;
    fireDateComponents.second = dateComponents.second;
    
    NSDate * fireDate = [NSDate dateWithDateComponents:fireDateComponents calendar:dateComponents.calendar];
    if (fireDate.timeIntervalSince1970 <= currentDate.timeIntervalSince1970) { //如果开始时间早于当前时间，则后一天开始
        NSDateComponents * next = [[NSDateComponents alloc] init];
        next.day = 1;
        fireDate = [dateComponents.calendar ?: [NSCalendar currentCalendar] dateByAddingComponents:next toDate:fireDate options:0];
    }
    
    DefaultDebugLog(@"本地推送时间 %@",[fireDate dateStringWithFormat:@"yyy-MM-dd hh:mm:ss"]);
    
    notification.fireDate = fireDate;
    notification.repeatCalendar = dateComponents.calendar;
    notification.repeatInterval = NSCalendarUnitDay;
    
    notification.alertBody = title;
    
    NSMutableDictionary * tempUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [tempUserInfo setObject:identifier forKey:MyKAppLocalNotificationIdentifier];
    notification.userInfo = tempUserInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)addLocalNotificationWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                  userInfo:(NSDictionary *)userInfo
                              timeInterval:(NSTimeInterval)timeInterval
{
    identifier = identifier.length ? identifier : [NSString uniqueIDString];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
    if (@available(iOS 10.0, *)) {
        
        UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval repeats:NO];
        
        DefaultDebugLog(@"本地推送时间 %@",[[trigger nextTriggerDate] dateStringWithFormat:@"yyy-MM-dd hh:mm:ss"]);
        
        UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
        content.body = title;
        content.userInfo = userInfo;
        content.sound = [UNNotificationSound defaultSound];
        
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:[UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger] withCompletionHandler:nil];
        
        return;
    }
    
#endif
    
    UILocalNotification *  notification = [[UILocalNotification alloc] init];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:timeInterval];
    notification.alertBody = title;
    
    DefaultDebugLog(@"本地推送时间 %@",[notification.fireDate dateStringWithFormat:@"yyy-MM-dd hh:mm:ss"]);
    
    NSMutableDictionary * tempUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [tempUserInfo setObject:identifier forKey:MyKAppLocalNotificationIdentifier];
    notification.userInfo = tempUserInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)getHadLocalNotificationWithIdentifier:(NSString *)identifier completionHandler:(void(^)(BOOL bRet))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    if (identifier.length == 0) {
        completionHandler(NO);
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
    if (@available(iOS 10.0, *)) {
        
        [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            
            BOOL bRet = NO;
            for (UNNotificationRequest * request in requests) {
                if (![request.trigger isKindOfClass:[UNPushNotificationTrigger class]] &&
                    [request.identifier isEqualToString:identifier]) {
                    bRet = YES;
                    break;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(bRet);
            });
            
        }];
        
        return;
    }
    
#endif
    
    //查找本地通知
    for (UILocalNotification * localNotification in [UIApplication sharedApplication].scheduledLocalNotifications) {
        if ([[localNotification.userInfo stringValueForKey:MyKAppLocalNotificationIdentifier] isEqualToString:identifier]) {
            completionHandler(YES);
            return;
        }
    }
    
    completionHandler(NO);
}

- (void)removeLocalNotificationWithIdentifier:(NSString *)identifier
{
    if (identifier.length == 0) {
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
    if (@available(iOS 10.0, *)) {
        
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
        
        return;
    }
    
#endif
    
    //查找本地通知
    NSMutableArray * localNotifications = [NSMutableArray array];
    for (UILocalNotification * localNotification in [UIApplication sharedApplication].scheduledLocalNotifications) {
        if ([[localNotification.userInfo stringValueForKey:MyKAppLocalNotificationIdentifier] isEqualToString:identifier]) {
            [localNotifications addObject:localNotification];
        }
    }
    
    //移除通知
    for (UILocalNotification * localNotification in localNotifications) {
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    }
}

- (void)removeAllLocalNotifications
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    }else {
       [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
#else
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
#endif
    
}

#pragma mark -

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self _applicationDidNotificationWithData:userInfo isRemote:YES isTap:nil];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [self _applicationDidNotificationWithData:userInfo isRemote:YES isTap:nil];
    
    //完成回调
    completionHandler(UIBackgroundFetchResultNewData);
}

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler NS_AVAILABLE_IOS(10_0)
{
    //是否是远程推送通知
    BOOL isRemote = [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]];

    [self _applicationDidNotificationWithData:notification.request.content.userInfo isRemote:isRemote isTap:@NO];
    
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

- (void)    userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10_0)
{
    //是否是远程推送通知
    BOOL isRemote = [response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]];

    [self _applicationDidNotificationWithData:response.notification.request.content.userInfo isRemote:isRemote isTap:@YES];
    
    completionHandler();

}

#endif

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self _applicationDidNotificationWithData:notification.userInfo isRemote:NO isTap:nil];
}

- (void)_applicationDidNotificationWithData:(NSDictionary * )userInfo
                                   isRemote:(BOOL)isRemote
                                      isTap:(NSNumber *)isTap
{
    MyAssert(self.applicationState != MyApplicationStateBackground);
    
    //状态
    MyApplicationReceiveNotificationState state;
    
    switch (self.applicationState) {
        case MyApplicationStateDidFinishLaunching:
            state = MyApplicationReceiveNotificationStateLaunchApp;
            break;
            
        case MyApplicationStateWillEnterForeground:
            state = MyApplicationReceiveNotificationStateEnterForeground;
            break;
            
        case MyApplicationStateActive:
            state = MyApplicationReceiveNotificationStateActive;
            break;
            
        default:
            state = MyApplicationReceiveNotificationStateInactive;
            break;
    }
    
    if (isTap == nil) {
        isTap = @(state == MyApplicationReceiveNotificationStateLaunchApp ||
                  state == MyApplicationReceiveNotificationStateEnterForeground);
    }
    
    //发送通知
    [self performActionWhenDidShowMainWindow:^{
        if (isRemote) {
            [self applicationDidReceiveRemoteNotification:userInfo
                                                    state:state
                                                    isTap:[isTap boolValue]];
        }else {
            [self applicationDidReceiveLocalNotification:userInfo
                                                   state:state
                                                   isTap:[isTap boolValue]];
        }
    }];
}

- (void)applicationDidReceiveLocalNotification:(NSDictionary *)userInfo state:(MyApplicationReceiveNotificationState)state isTap:(BOOL)isTap {
    //do nothing
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo state:(MyApplicationReceiveNotificationState)state isTap:(BOOL)isTap {
    //do nothing
}

#pragma mark -

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

- (void)_tryRegister3DTouchShortcutItems
{
    if ([self isSupported3DTouch] && [self needRegister3DTouchShortcutItems]) {
        [self register3DTouchShortcutItems];
    }
}

- (BOOL)needRegister3DTouchShortcutItems {
    return NO;
}

- (BOOL)isSupported3DTouch {
    return systemVersion() >= 9.0;
}

- (void)register3DTouchShortcutItems {
    //do nothing
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    //发送通知
    [self performActionWhenDidShowMainWindow:^{
        [self applicationPerformActionForShortcutItem:shortcutItem];
    }];
    
    completionHandler(YES);
}

- (void)applicationPerformActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    //do nothing
}

#endif


#pragma mark -

- (NSMutableDictionary *)timers
{
    if (!_timers) {
        _timers = [NSMutableDictionary dictionary];
    }
    
    return _timers;
}

#define ISPreDefinedTimer(_identity) (_identity == MyAppPreDefinedTimerIdentityPerSecond || \
                                      _identity == MyAppPreDefinedTimerIdentityPerMinute || \
                                      _identity == MyAppPreDefinedTimerIdentityPerHour   || \
                                      _identity == MyAppPreDefinedTimerIdentityPerDay)

- (void)registerPreDefinedTimerWithIdentity:(NSInteger)identity
{
    if (!ISPreDefinedTimer(identity)) {
        NSLog(@"注册失败,identity = %i的预约不是预定义预约。请使用registerTimerCallBackWithFireDate:interval:identity:进行注册",(int)identity);
    }else if(self.timers[@(identity)]) {
        NSLog(@"注册预定义预约行为被取消，identity = %i的预定义预约已经注册。如需重新注册请先取消",(int)identity);
    }else {
        
        NSDate * fireDate = nil;
        NSTimeInterval interval = 0.0f;
        BOOL rep = YES;
        
        switch (identity) {
            case MyAppPreDefinedTimerIdentityPerSecond:
                
                fireDate = [[NSDate date] dateWithMoveSec:1];
                interval = 1.0;
                
                break;
                
            case MyAppPreDefinedTimerIdentityPerMinute:
                
                fireDate = [[NSDate date] dateWithMoveMin:1];
                interval = SecPerMin;
                
                break;
                
            case MyAppPreDefinedTimerIdentityPerHour:
                
                fireDate = [[NSDate date] dateWithMoveHour:1];
                interval = SecPerHour;
                
                break;
                
            case MyAppPreDefinedTimerIdentityPerDay:
                
                fireDate = [[NSDate date] dateWithMoveDay:1];
                interval = SecPerDay;
                
                break;
        }
        
        MyAssert(fireDate && interval);
        
        //注册
        [self _registerTimerCallBackWithFireDate:fireDate interval:interval repeats:rep identity:identity];
    }
}

- (void)registerTimerCallBackWithFireDate:(NSDate *)date
                                 interval:(NSTimeInterval)ti
                                  repeats:(BOOL)rep
                                 identity:(NSInteger)identity
{
    if (ISPreDefinedTimer(identity)) {
        NSLog(@"注册失败,identity = %i的预约是预定义预约。请使用registerPreDefinedTimerWithIdentity:进行注册",(int)identity);
    }else {
        NSLog(@"identity = %i的预定义预约已经注册。先前注册的已取消，现已重新注册",(int)identity);
        [self _registerTimerCallBackWithFireDate:date interval:ti repeats:rep identity:identity];
    }
}

- (void)_registerTimerCallBackWithFireDate:(NSDate *)date
                                  interval:(NSTimeInterval)ti
                                   repeats:(BOOL)rep
                                  identity:(NSInteger)identity
{
    [self cancleRegisterTimerWithIdentity:identity];
    
    //
    date = date ? [date laterDate:[NSDate date]] : [NSDate date];
    
    NSTimer * timer = [[NSTimer alloc] initWithFireDate:date
                                               interval:ti
                                                 target:self
                                               selector:@selector(_timerHandle:)
                                               userInfo:@(identity)
                                                repeats:rep];
    self.timers[@(identity)] = timer;
    
    //加入
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}


- (void)cancleRegisterTimerWithIdentity:(NSInteger)identity
{
    NSTimer * timer = self.timers[@(identity)];
    if (timer) {
        [timer invalidate];
        [self.timers removeObjectForKey:@(identity)];
    }
}

- (void)_timerHandle:(NSTimer *)timer
{
    //回调
    [self timerCallBackWithIdentity:[timer.userInfo integerValue]];
    
    if (!timer.isValid) { //单词执行的timer执行后会无效,无效后删除
        [self.timers removeObjectForKey:timer.userInfo];
    }
}

- (void)timerCallBackWithIdentity:(NSInteger)identity {
    //do nothing
}

- (void)setupRegisterTimer {
    //do nothing
}

@end
