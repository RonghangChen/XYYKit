//
//  MySocialSNSTargetItem.m
//  
//
//  Created by LeslieChen on 15/8/18.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySocialSNSTargetItem.h"
#import "MySocialSNSManager.h"

//----------------------------------------------------------

MySocialSNSTargetItemName const MySocialSNSTargetItemNameWeChat       = @"WeChat";
MySocialSNSTargetItemName const MySocialSNSTargetItemNameWeChatCircle = @"WeChatCircle";
MySocialSNSTargetItemName const MySocialSNSTargetItemNameWeibo        = @"Weibo";
MySocialSNSTargetItemName const MySocialSNSTargetItemNameQQ           = @"QQ";
MySocialSNSTargetItemName const MySocialSNSTargetItemNameQQZone       = @"QQZone";
MySocialSNSTargetItemName const MySocialSNSTargetItemNameAlipay       = @"Alipay";

//----------------------------------------------------------

@implementation MySocialSNSTargetItem

+ (NSArray *)socialSNSTargetItemsWithNames:(NSArray *)names
{
    NSMutableArray * socialSNSTargetItems = [NSMutableArray arrayWithCapacity:names.count];
    for (MySocialSNSTargetItemName name in names) {
        @try {
            id socialSNSTargetItem = [[self alloc] initWithName:name];
            [socialSNSTargetItems addObject:socialSNSTargetItem];
        }
        @catch (NSException *exception) {
            //do nithing
        }
    }

    return socialSNSTargetItems;
}


- (id)initWithName:(MySocialSNSTargetItemName)name
{    
//    if (![MySocialSNSManager hasSocialSNSTargetIdentifyInfo:name]) {
//        @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                       reason:[NSString stringWithFormat:@"社会化平台%@无任何身份信息，初始化失败",name]
//                                     userInfo:nil];
//    }
    
    self = [super init];
    if (self) {
        _name = name;
    }
    
    return self;
}

@end
