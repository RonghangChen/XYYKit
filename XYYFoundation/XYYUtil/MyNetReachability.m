//
//  MyNetReachability.m
//
//
//  Created by LeslieChen on 14-7-3.
//  Copyright (c) 2014年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyNetReachability.h"

//----------------------------------------------------------

NSString *const NetReachabilityChangedNotification = @"NetReachabilityChangedNotification";

//----------------------------------------------------------

@interface MyNetReachability ()

@property(nonatomic,strong,readonly) Reachability * reachability;

@end

//----------------------------------------------------------

@implementation MyNetReachability
{
    BOOL   _isNotifier;
}

@synthesize reachability = _reachability;

#pragma mark -

+ (MyNetReachability *)_shareNetReachability
{
    static MyNetReachability * shareNetReachability = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareNetReachability = [[super allocWithZone:nil] init];
    });
    
    return shareNetReachability;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

+ (NetworkStatus)currentNetReachabilityStatus {
    return [[self _shareNetReachability] _currentNetStatus];
}

- (Reachability *)reachability
{
    if (!_reachability) {
        
        _reachability = [Reachability reachabilityForInternetConnection];
      
        //开始通知
        [_reachability startNotifier];
        
        //观察通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_netReachabilityStatusChangeNotification:)
                                                     name:kReachabilityChangedNotification
                                                   object:_reachability];
    }
    
    return _reachability;
}

- (NetworkStatus)_currentNetStatus {
    return [self.reachability currentReachabilityStatus];
}

- (void)_netReachabilityStatusChangeNotification:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NetReachabilityChangedNotification
                                                            object:nil];
    }else {
        [self performSelectorOnMainThread:@selector(_netReachabilityStatusChangeNotification:)
                               withObject:notification
                            waitUntilDone:NO];
    }
}

@end
