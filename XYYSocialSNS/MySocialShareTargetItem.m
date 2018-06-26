//
//  MySocialShareTargetItem.m
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySocialShareTargetItem.h"
#import "MySocialSNSManager.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

static NSDictionary * allAvailableShareTargetItemInfos()
{
    static NSMutableDictionary * shareTargetItemInfos = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shareTargetItemInfos = [NSMutableDictionary dictionaryWithContentsOfFile:PlistResourceFilePath(@"MySocialShareTargetItemInfos")];
        
        //核对身份信息
        for (MySocialSNSTargetItemName name in shareTargetItemInfos.allKeys) {
            if (![MySocialSNSManager isInstallSocialSNSTargetSDK:name] ||
                ![MySocialSNSManager hasSocialSNSTargetIdentifyInfo:name] ||
                [MySocialSNSManager isSupportShareForSocialSNSTarget:name] == MySocialSNSTargetSupportResultTypeUnSupport) {
                [shareTargetItemInfos removeObjectForKey:name];
            }
        }
    });
    
    return shareTargetItemInfos;
}

inline static NSDictionary * shareTargetItmeInfoWithName(MySocialSNSTargetItemName name) {
    return [allAvailableShareTargetItemInfos() objectForKey:name];
}

//----------------------------------------------------------

@implementation MySocialShareTargetItem
{
    NSString * _iconName;
}

+ (NSArray *)allAvailableShareTargetItems
{
    static NSMutableArray * allAvailableShareTargetItems = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDictionary * allShareTargetItemInfos = allAvailableShareTargetItemInfos();
        allAvailableShareTargetItems = [NSMutableArray arrayWithCapacity:allShareTargetItemInfos.count];
        for (MySocialSNSTargetItemName name in allShareTargetItemInfos.allKeys) {
            [allAvailableShareTargetItems addObject:[[self alloc] initWithName:name andInfo:allShareTargetItemInfos[name]]];
        }
    });
    
    return allAvailableShareTargetItems;
}

- (id)initWithName:(MySocialSNSTargetItemName)name
{
    NSDictionary * shareTargetItmeInfo = shareTargetItmeInfoWithName(name);
    if (shareTargetItmeInfo == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"社会化分享目标平台%@无相关信息数据",name]
                                     userInfo:nil];
    }
    
    return [self initWithName:name andInfo:shareTargetItmeInfo];
}

+ (NSString *)iconNameForInfo:(NSDictionary *)info {
    return [info stringValueForKey:@"icon"];
}

- (id)initWithName:(MySocialSNSTargetItemName)name andInfo:(NSDictionary *)info
{
    self = [super initWithName:name];
    if (self) {
        
        _title = [info myTitle];
        _iconName = [[self class] iconNameForInfo:info];
        _shadowColor = [info colorValueForKey:@"shadowColor"];
    }

    return self;
}

- (UIImage *)icon {
    return _iconName.length ? ImageWithName(_iconName) : nil;
}


@end
