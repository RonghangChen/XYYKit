//
//  MyUserModule.m
//  
//
//  Created by LeslieChen on 15/3/19.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyUserModel.h"

@implementation MyUserModel

- (id)xyy_initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self updateWithInfo:dictionary];
    }
    
    return self;
}

- (NSDictionary *)infoUseForAuth {
    return nil;
}

- (NSDictionary *)updateWithInfo:(NSDictionary *)info
{
    NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionaryWithCapacity:info.count];
    
    for (NSString * key in info.keyEnumerator) {
        
        NSString * propertyName = [self xyy_propertyNameForKey:key];
        if (![self xyy_isValidateProperty:propertyName forDicToModel:YES]) {
            continue;
        }
        
        //获取新值
        id newValue = [self xyy_convertValue:info[key] forProperty:propertyName];
        //旧值
        id oldValue = [self xyy_valueForKey:propertyName forJson:NO];
        
        if(newValue != oldValue &&
           ![newValue isEqual:oldValue]) {
            
            //更新值
            [self xyy_updateProperty:propertyName withValue:newValue];
            [resultDictionary setObject:newValue ?: [NSNull null] forKey:propertyName];
        }
    }
    
    return resultDictionary;
}

- (NSDictionary *)infosForKeys:(NSArray *)keys
{
    NSMutableDictionary * infos = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString * key in keys) {
        id value = [self xyy_valueForKey:key forJson:NO];
        if (value != nil && value != [NSNull null]) {
            [infos setObject:value forKey:key];
        }
    }
    
    return infos;
}

- (id)infoForKey:(NSString *)key
{
    id value = [self xyy_valueForKey:key forJson:NO];
    if (value != nil && value != [NSNull null]) {
        return value;
    }
    return nil;
}

@end
