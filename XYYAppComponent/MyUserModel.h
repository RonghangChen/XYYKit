//
//  MyUserModule.h
//  
//
//  Created by LeslieChen on 15/3/19.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XYYJsonModel;
@interface MyUserModel : NSObject<XYYJsonModel>

//更新数据
- (NSDictionary *)updateWithInfo:(NSDictionary *)info;

//返回用以授权的信息
- (NSDictionary *)infoUseForAuth;
//获取用户信息
- (NSDictionary *)infosForKeys:(NSArray *)keys;
- (id)infoForKey:(NSString *)key;

@end
