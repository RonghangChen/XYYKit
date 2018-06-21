 //
//  help.c
//
//
//  Created by LeslieChen on 13-12-11.
//  Copyright (c) 2013年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "XYYCommonUtil.h"
#import "XYYBaseDef.h"
#import "MyNetReachability.h"
#import <objc/runtime.h>
#import "ScreenAdaptation.h"
#import <sys/sysctl.h>
#import <mach/mach.h>  

void checkIndexAtRange(NSUInteger index,NSRange range)
{
    if (!NSLocationInRange(index,range)) {
        
        @throw [[NSException alloc] initWithName:NSRangeException
                                          reason:[NSString stringWithFormat:@"index = %u 超出范围 %u ~ %u",(unsigned int)index,(unsigned int)range.location,(unsigned int)NSMaxRange(range)]
                                        userInfo:nil];
    }
    
}


NSArray * indexPathsFromRange(NSInteger section,NSRange range) {
    return indexPathsFromIndexSet(section, [NSIndexSet indexSetWithIndexesInRange:range]);
}

NSArray * indexPathsFromIndexSet(NSInteger section,NSIndexSet * indexSet)
{
    NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:indexSet.count];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    
    return indexPaths;
}

NSArray * makeDatasToLocalizedIndexed(NSArray * datas, SEL collationStringSelector)
{
    if (datas.count == 0) {
        return nil;
    }
    
    //本地化索引集合
    UILocalizedIndexedCollation  * collation = [UILocalizedIndexedCollation currentCollation];
    
    //索引总数
    NSUInteger indexTitleCount = collation.sectionIndexTitles.count;
    
    //初始化结果数组
    NSMutableArray * resultDatasArray = [NSMutableArray arrayWithCapacity:indexTitleCount];
    for (NSUInteger i = 0 ;i < indexTitleCount ; i++) {
        [resultDatasArray addObject:[NSMutableArray array]];
    }
    
    //遍历所有数据并把其加到对应的索引数组内数组内
    for (id data in datas) {
        NSUInteger index = [collation sectionForObject:data collationStringSelector:collationStringSelector];
        [resultDatasArray[index] addObject:data];
    }
    
    //删除无数据的索引和对数据进行排序
    NSMutableIndexSet * indexsNeedRemove = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0 ;i < indexTitleCount ; i++) {
        NSArray * subDatas = resultDatasArray[i];
        if (subDatas.count == 0) {
            [indexsNeedRemove addIndex:i];
        }else {
            [resultDatasArray replaceObjectAtIndex:i withObject:[collation sortedArrayFromArray:subDatas collationStringSelector:collationStringSelector]];
        }
    }
   
    [resultDatasArray removeObjectsAtIndexes:indexsNeedRemove];
    NSMutableArray * indexTitles = [NSMutableArray arrayWithArray:collation.sectionIndexTitles];
    [indexTitles removeObjectsAtIndexes:indexsNeedRemove];

    return @[indexTitles,resultDatasArray];
}


CGAffineTransform rotationAffineTransformForOrientation(UIInterfaceOrientation orientation)
{
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(- M_PI_2);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
            break;
            
        default:
            return CGAffineTransformIdentity;
            break;
    }
}

void _showNetworkActivityIndicator(BOOL bShow)
{
    static NSUInteger networkActivityIndicatorShowTimes = 0;
    
    if (bShow) {
        
        if (networkActivityIndicatorShowTimes == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
        
        //显示次数+1
        networkActivityIndicatorShowTimes ++ ;
        
    }else if (networkActivityIndicatorShowTimes > 0) {
        
        networkActivityIndicatorShowTimes -- ;
        
        //无显示次数，则隐藏
        if (networkActivityIndicatorShowTimes == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
    
}

void showNetworkActivityIndicator(BOOL bShow)
{
    if ([NSThread isMainThread]) {
        _showNetworkActivityIndicator(bShow);
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            _showNetworkActivityIndicator(bShow);
        });
    }
}

CAShapeLayer * createLineLayer(CGPoint startPoint,CGPoint endPoint,CGFloat lineWidth,UIColor * lineColor)
{
    CAShapeLayer * lineLayer = [[CAShapeLayer alloc] init];
    lineLayer.lineWidth = lineWidth;
    lineLayer.strokeColor = lineColor.CGColor;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    CGPathCloseSubpath(path);
    lineLayer.path = path;
    CGPathRelease(path);
    
    return lineLayer;
}

#pragma mark -

NSString * appStoreURL(NSString * appID) {
    return [NSString  stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appID];
}

NSString * appStoreReviewURL(NSString * appID)
{
    if (systemVersion() >= 11.0) {
        return appStoreURL(appID);
    }else {
        return [NSString  stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8",appID];
    }
}

NSString * appStoreHTTPURL(NSString * appID) {
    return [NSString  stringWithFormat: @"http://itunes.apple.com/cn/app/id%@?mt=8",appID];
}

void gotoAppStore(NSString * appID) {
    openURL([NSURL URLWithString:appStoreURL(appID)]);
}

void gotoAppStoreReview(NSString * appID) {
    openURL([NSURL URLWithString:appStoreReviewURL(appID)]);
}

BOOL openURL(NSURL * url)
{
//    NSURL * _url = [NSURL URLWithString:url];
    if (url == nil) {
        return NO;
    }
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO} completionHandler:nil];
        return YES;
    } else {
        return [[UIApplication sharedApplication] openURL:url];
    }
}

void callPhoneNumber(NSString * phoneNumber)
{    
    if (phoneNumber.length) {
        openURL([NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]]);
    }
}
#pragma mark -

NSString * const defaultReuseDef = @"defaultReuseDef";

#pragma mark -

//返回物理内存大小，单位是MB
double physicalMemorySize() {
    return [[NSProcessInfo processInfo] physicalMemory] / (1024.0 * 1024.0);
}

//当前任务占用的内存数，单位是MB
double usedMemorySize()
{
    //获取当前任务的信息
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return MyMemorySizeUnknown;
    }
    
    return taskInfo.resident_size / (1024.0 * 1024.0);
}

double memorySizeForType(MyMemoryType type)
{
    if (type == MyMemoryTypeNone) {
        return 0.0;
    }
    
    //获取内存统计信息
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return MyMemorySizeUnknown;
    }
    
    unsigned long long size = 0;
    
    if (type & MyMemoryTypeFree) size += vmStats.free_count;
    if (type & MyMemoryTypeUsed) size += (vmStats.active_count + vmStats.wire_count);
    if (type & MyMemoryTypeInactive) size += vmStats.inactive_count;
    
    return (size * vm_page_size) / (1024.0 * 1024.0);
}

#pragma mark -

BOOL NSProtocolContainSelector(Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod)
{
    struct objc_method_description method_description = protocol_getMethodDescription(p,aSel,isRequiredMethod,isInstanceMethod);
    return method_description.name != NULL && method_description.types != NULL;
}

