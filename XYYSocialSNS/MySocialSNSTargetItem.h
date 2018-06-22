//
//  MySocialSNSTargetItem.h
//  
//
//  Created by LeslieChen on 15/8/18.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MySocialSNSTargetItem.h"

//----------------------------------------------------------

//社会化平台的目标名字
typedef NSString * MySocialSNSTargetItemName;

//----------------------------------------------------------

UIKIT_EXTERN MySocialSNSTargetItemName const MySocialSNSTargetItemNameWeChat;
UIKIT_EXTERN MySocialSNSTargetItemName const MySocialSNSTargetItemNameWeChatCircle;
UIKIT_EXTERN MySocialSNSTargetItemName const MySocialSNSTargetItemNameWeibo;
UIKIT_EXTERN MySocialSNSTargetItemName const MySocialSNSTargetItemNameQQ;
UIKIT_EXTERN MySocialSNSTargetItemName const MySocialSNSTargetItemNameQQZone;
UIKIT_EXTERN MySocialSNSTargetItemName const MySocialSNSTargetItemNameAlipay;

//add when need

//----------------------------------------------------------

@interface MySocialSNSTargetItem : NSObject

+ (NSArray *)socialSNSTargetItemsWithNames:(NSArray *)names;
- (id)initWithName:(MySocialSNSTargetItemName)name;

@property(nonatomic,strong,readonly) MySocialSNSTargetItemName name;


@end
