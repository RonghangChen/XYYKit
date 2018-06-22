//
//  MySocialShareTargetItem.h
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MySocialSNSTargetItem.h"

//----------------------------------------------------------

@interface MySocialShareTargetItem : MySocialSNSTargetItem

//所有的可获取的分享目标
+ (NSArray *)allAvailableShareTargetItems;
//返回icon名字
+ (NSString *)iconNameForInfo:(NSDictionary *)info;

- (id)initWithName:(MySocialSNSTargetItemName)name andInfo:(NSDictionary *)info;

@property(nonatomic,strong,readonly) NSString * title;
@property(nonatomic,strong,readonly) UIImage *  icon;

@property(nonatomic,strong,readonly) UIColor * shadowColor;

@end
