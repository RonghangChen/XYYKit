//
//  MyAppDelegate.h
//  5idj
//
//  Created by LeslieChen on 14-9-28.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//----------------------------------------------------------

//应用包信息
typedef NS_OPTIONS(NSUInteger, MyApplicationBundleInfo) {
    MyApplicationBundleInfoUnknow = 0, //未知
    MyApplicationBundleInfoDebug = 1, //debug包
    MyApplicationBundleInfoDevelopEnv = 1 << 1, //服务器开发环境
    MyApplicationBundleInfoProductionEnv = 1 << 2, //服务器生产环境
    
    //环境掩码
    MyApplicationBundleInfoEnvMask = MyApplicationBundleInfoDevelopEnv | MyApplicationBundleInfoProductionEnv,
    
    //默认开发包
    MyApplicationBundleInfoDefaultDevelop = MyApplicationBundleInfoDebug | MyApplicationBundleInfoDevelopEnv,
    //默认发布包
    MyApplicationBundleInfoDefaultProduction = MyApplicationBundleInfoProductionEnv
};

/**
 * 应用状态
 *
 * 应用状态的改变过程，有以下几种类型
 * 1.应用刚加载：DidFinishLaunching -> Active
 * 2.应用激活状态改变（拉下通知中心或拉上操作中心等等）：Active -> Inactive -> Active
 * 3.应用进入后台：Active -> Inactive -> Background
 * 4.应用进入前台 WillEnterForeground -> Active
 */
typedef NS_ENUM(NSInteger, MyApplicationState) {
    MyApplicationStateDidFinishLaunching,       //完成加载,完成加载到激活的一个过渡状态
    MyApplicationStateActive,                   //激活状态
    MyApplicationStateInactive,                 //未激活状态
    MyApplicationStateBackground,               //后台状态
    MyApplicationStateWillEnterForeground       //将要进入前台状态，后台进入到激活的一个过渡状态
};


//收到通知时的状态
typedef NS_ENUM(NSInteger, MyApplicationReceiveNotificationState) {
    MyApplicationReceiveNotificationStateLaunchApp,         //加载APP，应用未打开，点击通知进入
    MyApplicationReceiveNotificationStateEnterForeground,   //进入前台，应用在后台，点击通知进入
    MyApplicationReceiveNotificationStateInactive,          //应用处于非活动状态收到通知，应用处于前台，状态栏或操作栏处于显示时
    MyApplicationReceiveNotificationStateActive             //App处于活动状态收到通知
};


//openURL时的状态
typedef NS_ENUM(NSInteger, MyApplicationOpenURLState) {
    MyApplicationOpenURLStateLaunchApp,          //加载APP，应用未打开，通过其他应用OpenURL进入
    MyApplicationOpenURLStateEnterForeground,    //进入前台，应用在后台，通过其他应用OpenURL进入
    MyApplicationOpenURLStateActive              //App处于活动状态，应用内OpenURL
};


//预定义预约的身份定义
typedef NS_ENUM(NSInteger, MyAppPreDefinedTimerIdentity) {
    MyAppPreDefinedTimerIdentityPerSecond  = 1000,    //每分钟，每整秒都会调用一次
    MyAppPreDefinedTimerIdentityPerMinute  = 1001,    //每分钟，每整分钟都会调用一次
    MyAppPreDefinedTimerIdentityPerHour    = 1002,    //每小时，每整小时都会调用一次
    MyAppPreDefinedTimerIdentityPerDay     = 1003     //每天，每整天都会调用一次
};

//评分弹框的结果
typedef NS_ENUM(NSInteger, MyAppScoreAlertViewResult) {
    MyAppScoreAlertViewResultGoto,  //立即去
    MyAppScoreAlertViewResultDeny,  //拒绝
    MyAppScoreAlertViewResultIgnore //忽视，即稍后评价
};


//----------------------------------------------------------

@interface MyAppDelegate : UIResponder < UIApplicationDelegate
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
,UNUserNotificationCenterDelegate
#endif
>

+ (instancetype)appDelegate;

//                app的基本信息
//-----------------------------------------------------

////app构建版本(每一次提交对应的数字版本,与安卓统一)
//@property(nonatomic,readonly) NSInteger appBuildVersion;

//版本（x.x）
@property(nonatomic,strong,readonly) NSString * appVersion;
//上一个安装的APP版本
@property(nonatomic,strong,readonly) NSString * lastInstallAppVersion;
//build
@property(nonatomic,strong,readonly) NSString * appBuild;
//app store中的ID
@property(nonatomic,strong,readonly) NSString * appID;
//app名字
@property(nonatomic,strong,readonly) NSString * appName;
//appScheme
@property(nonatomic,strong,readonly) NSString * appScheme;
//用户引导页面的版本
@property(nonatomic,strong,readonly) NSString * userGuideViewVersion;


//                  app包信息
//-----------------------------------------------------


//应用包信息
@property(nonatomic) MyApplicationBundleInfo appBundleInfo;
//应用包身份信息
@property(nonatomic,strong,readonly) NSString * appBundleIdentifier;
//应用身份信息，由appBundleIdentifier和appID合成
@property(nonatomic,strong,readonly) NSString * appIdentifier;

////app包信息改变
//- (void)appBundleInfoDidChangeForm:(MyApplicationBundleInfo)oldBundleInfo;

//                  app更新
//-----------------------------------------------------


////程序launch时是否检查更新，默认为YES
//@property(nonatomic) BOOL checkUpdateWhenLaunch;
////检查更新
//+ (void)checkUpdate:(BOOL)showNoUpdateMessage;

//在appstroe打开
+ (void)openInAppStore;
//在appstroe打开评价
+ (void)openInAppStoreReview;


//                app的点击次数信息
//-----------------------------------------------------


//app已经加载,默认不做任何事，子类重载进行自定义操作
- (void)appDidLaunch;
//app已经点击,默认不做任何事，子类重载进行自定义操作
- (void)appDidClick;


//以下数据基于当前版本app

//app加载的次数
+ (NSUInteger)appLaunchTimes;
//是否为第一次LaunchApp
+ (BOOL)isFirstLaunchApp;
//app进入前台的次数
+ (NSUInteger)appClickTimes;

//app上一次加载的时间
+ (NSDate *)appLastLauchDate;
//app上一次点击的时间
+ (NSDate *)appLastClickDate;

//连续点击天数
+ (NSUInteger)appContinuousClickDays;


//是否显示网络状态改变，默认为NO
@property(nonatomic) BOOL showNetworkStatusChange;
//显示网络状态的的处理函数
- (void)showNetworkStatus;

//返回是否可以显示评分视图，即是否已经评价
+ (BOOL)canShowScoreAlertView;

//每click多少次显示评价页面，默认为0,及不显示
@property(nonatomic) NSUInteger showScoreAlertViewPerClickTimes;

//显示评价页面,可重载进行特定评分视图的显示
- (void)showScoreAlertView;
//评价页面内容文字
@property(nonatomic,strong) NSString * scoreAlertViewContentText;

//评价忽视的次数
+ (NSUInteger)appScoreIgnoreTimes;

//评价页面完成了显示
- (void)scoreAlertViewCompletedShowWithResult:(MyAppScoreAlertViewResult)result;


//                app状态信息
//-----------------------------------------------------

//应用状态
@property(nonatomic,readonly) MyApplicationState applicationState;


//                app加载信息
//-----------------------------------------------------

//应用加载的选项信息
@property(nonatomic,strong,readonly) NSDictionary * launchOptions;

//当前版本APP第一次加载会调用该方法
- (void)doSomethingWhenAppFirstLaunch;

//开始显示视图，默认是需要显示引导页面显示引导页面，否则显示主窗口，可重载自定义
- (void)startShowView;

//是否需要显示用户引导页面
- (BOOL)needShowUserGuideView;
//显示引导页面
- (void)showUserGuideView;
//完成显示引导页面
- (void)completedShowUserGuideView;

//显示主window
- (void)showMainWindow;
//完成显示主window
- (void)completedShowMainWindow;


//应用已经显示的主窗口
@property(nonatomic,readonly) BOOL appDidShowMainWindow;
//执行动作当显示了主window，如果主窗口已经显示直接执行，否则加入队列当完成显示主界面时执行时
- (void)performActionWhenDidShowMainWindow:(void(^)(void))action;


//应用处理openURL
- (void)applicationDidOpenURL:(NSURL *)url
            sourceApplication:(NSString *)sourceApplication
                   annotation:(id)annotation
                        state:(MyApplicationOpenURLState)state;


//                    注册远程通知相关
//-----------------------------------------------------


//是否需要注册远程通知，默认返回NO
- (BOOL)needRegisterRemoteNotification;
//注册远程通知
- (void)registerRemoteNotification;

//收到远程通知,主窗口显示后才会调用
- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
                                          state:(MyApplicationReceiveNotificationState)state
                                          isTap:(BOOL)isTap;


//                    注册本地通知相关
//-----------------------------------------------------

//添加每天特定时间的本地通知
- (void)addLocalNotificationWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                  userInfo:(NSDictionary *)userInfo
                            dateComponents:(NSDateComponents *)dateComponents
                                   repeats:(BOOL)repeats;

//添加一定时间间隔后的本地通知
- (void)addLocalNotificationWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                  userInfo:(NSDictionary *)userInfo
                              timeInterval:(NSTimeInterval)timeInterval;

//是否有某一个本地通知
- (void)getHadLocalNotificationWithIdentifier:(NSString *)identifier completionHandler:(void(^)(BOOL bRet))completionHandler;

//移除本地通知
- (void)removeLocalNotificationWithIdentifier:(NSString *)identifier;
- (void)removeAllLocalNotifications;

//收到本地通知,主窗口显示后才会调用
- (void)applicationDidReceiveLocalNotification:(NSDictionary *)userInfo
                                         state:(MyApplicationReceiveNotificationState)state
                                         isTap:(BOOL)isTap;;


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

//                    3D Touch 快捷项
//-----------------------------------------------------


//是否需要注册3D Touch快捷项（默认为NO）
- (BOOL)needRegister3DTouchShortcutItems;
//是否支持3DTouch
- (BOOL)isSupported3DTouch;
//注册3D Touch快捷项
- (void)register3DTouchShortcutItems;

//处理3D Touch快捷项事件
- (void)applicationPerformActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem NS_AVAILABLE_IOS(9_0);

#endif

//                实现的代理函数,子类实现时需调用
//-----------------------------------------------------

//状态相关
//加载
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

//进入前后台
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;

//激活
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

//openURL
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

//通知相关
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler NS_AVAILABLE_IOS(9_0);

#endif


//                注册某一时间的预约
//-----------------------------------------------------

/**
 * 注册预约回调
 * @param date date为开始执行的时间,date为nil或小于当前时间则从当前时间开始
 * @param ti ti为时间间隔，小于等于0则会改为0.1
 * @param rep rep标识是否重复
 * @param identity identity为预约的身份信息，标识唯一一个预约，如果重复会被覆盖
 */
- (void)registerTimerCallBackWithFireDate:(NSDate *)date
                                 interval:(NSTimeInterval)ti
                                  repeats:(BOOL)rep
                                 identity:(NSInteger)identity;

/**
 * 注册预定义的预约回调
 * @param identity identity为预定义的标识，具体取值见MyAppPreDefinedTimerIdentity
 */
- (void)registerPreDefinedTimerWithIdentity:(NSInteger)identity;

/**
 * 取消预约回调
 * @param identity identity为预定义的标识
 */
- (void)cancleRegisterTimerWithIdentity:(NSInteger)identity;

/**
 * 预约回调函数
 * @param identity identity为预约的身份信息，标识唯一一个预约
 */
- (void)timerCallBackWithIdentity:(NSInteger)identity;


//初始化注册预约
- (void)setupRegisterTimer;


@end
