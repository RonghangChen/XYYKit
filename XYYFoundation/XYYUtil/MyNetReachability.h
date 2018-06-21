//
//  MyNetReachability.h
//
//
//  Created by LeslieChen on 14-7-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "Reachability.h"

//----------------------------------------------------------

extern NSString *const NetReachabilityChangedNotification;

//----------------------------------------------------------

//当前网络状态
#define CurrentNetStatus()    [MyNetReachability currentNetReachabilityStatus]

//无网络
#define NetNotReachable()     (CurrentNetStatus() == NotReachable)
//网络可用
#define NetworkAvailable()    (CurrentNetStatus() != NotReachable)
//手机 网络
#define NetReachableViaWWAN() (CurrentNetStatus() == ReachableViaWiFi)
//wifi 网络
#define NetReachableViaWiFi() (CurrentNetStatus() == ReachableViaWiFi)

//----------------------------------------------------------


/**
 * 网络可达性监听
 */
@interface MyNetReachability : NSObject

/**
 * 返回当前网络状态
 */
+ (NetworkStatus)currentNetReachabilityStatus;


@end
