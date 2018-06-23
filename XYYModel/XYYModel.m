//
//  MyModel.m
//
//
//  Created by 陈荣航 on 2017/12/6.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "XYYModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

//----------------------------------------------------------

//属性类型
typedef NS_ENUM(NSInteger,_MyPropertyType) {
    _MyPropertyTypeObject = 0, //对象
    _MyPropertyTypeStruct, //结构体或联合体
    _MyPropertyTypeNumber, //C语言数字
    _MyPropertyTypeOther, //其他
    _MyPropertyTypeUnsupported = _MyPropertyTypeOther //其他不支持
};

//属性数字值
typedef union {
    char charValue;
    unsigned char unsignedCharValue;
    short shortValue;
    unsigned short unsignedShortValue;
    int intValue;
    unsigned int unsignedIntValue;
    long longValue;
    unsigned long unsignedLongValue;
    long long longLongValue;
    unsigned long long unsignedLongLongValue;
    float floatValue;
    double doubleValue;
    bool boolValue;
} _MyPropertyNumberValue;


//获取属性类型
static inline _MyPropertyType _getPropertyType(const char * type) {
    
    if (type == NULL) {
        return _MyPropertyTypeOther;
    }
    
    switch (*type) {
        case '@':
            return _MyPropertyTypeObject;
            break;
            
        case '{':
        case '(':
            return _MyPropertyTypeStruct;
            break;
            
        case 'c':
        case 'i':
        case 's':
        case 'l':
        case 'q':
        case 'C':
        case 'I':
        case 'S':
        case 'L':
        case 'Q':
        case 'f':
        case 'd':
        case 'B':
            return _MyPropertyTypeNumber;
            break;
            
        default:
            break;
    }
    
    return _MyPropertyTypeOther;
}

//获取类型的变量占用的内存
static inline size_t _sizeForType(const char * type)
{
    NSMethodSignature * methodSignature = [NSMethodSignature signatureWithObjCTypes:[NSString stringWithFormat:@"%s@:",type].UTF8String];
    
    return methodSignature.methodReturnLength;
}

//获取对象属性的类
static inline Class _objectPropertyClassForType(NSString * type)
{
    assert([type hasPrefix:@"@"]);
    if (type.length > 3) { //@"className"
        NSString * className = [type substringWithRange:NSMakeRange(2, type.length - 3)];
        return NSClassFromString(className);
    }
    
    return nil;
}

//获取结构体/联合体属性的结构体/联合体
static inline NSString * _structPropertyNameForType(NSString * type)
{
    assert([type hasPrefix:@"{"] || [type hasPrefix:@"("]);
    
    NSScanner * scanner = [[NSScanner alloc] initWithString:type];
    NSString * structName = nil;
    if ([scanner scanUpToString:@"=" intoString:&structName]) {
        return [structName substringFromIndex:1];
    }
    
    return nil;
}


//----------------------------------------------------------

//属性元数据
@interface _MyModelPropertyData : NSObject
{
    @package
    
    //属性名
    NSString * _name;
    
    //属性类型
    _MyPropertyType _type;
    //属性类型编码
    NSString * _typeEncoding;
    //属性类型所占用内存大小
    size_t _typeSize;
    
    //对象类型的class（如果属性类型是对象该值有意义）
    Class _typeClass;
    //结构体/联合体类型名称（如果属性类型是结构体/联合体该值有意义）
    NSString * _typeStruct;
    
    //属性getter方法
    SEL _getterSelector;
    //属性setter方法（只读属性改值为nil）
    SEL _setterSelector;
    //属性关联的变量(无关联变量为nil)
    Ivar _ivar;
}

- (id)initWithName:(NSString *)name;

@end

@implementation _MyModelPropertyData

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@implementation NSObject(XYYModel)

#pragma mark - 初始化


+ (NSMutableArray *)xyy_modelsWithDictionarys:(NSArray<NSDictionary *> *)dictionarys
{
    NSMutableArray * models = [NSMutableArray arrayWithCapacity:dictionarys.count];
    for (NSDictionary * dictionary in dictionarys) {
        id model = [[self alloc] xyy_initWithDictionary:dictionary];
        if (model != nil) {
            [models addObject:model];
        }
    }
    
    return models;
}


- (id)xyy_initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        [self xyy_updateWithDictionary:dictionary];
    }
    
    return self;
}

#pragma mark - 帮助方法

- (_MyModelPropertyData *)_getPropertyData:(NSString *)propertyName forDicToModel:(BOOL)dicToModel
{
    if (propertyName.length == 0) {
        return nil;
    }
    
    static NSCache * cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    
    //生成属性名称
    NSMutableString * cacheKey = [NSMutableString stringWithUTF8String:class_getName(self.class)];
    [cacheKey appendString:@":"];
    [cacheKey appendString:propertyName];
    
    _MyModelPropertyData * data = [cache objectForKey:cacheKey];
    if (data != nil) { //存在缓存直接返回
        goto end;
    }
    
    //获取属性信息
    objc_property_t property = class_getProperty([self class], propertyName.UTF8String);
    if (property != NULL) {
        
        BOOL isReadonly = NO;
        const char * typeValue = NULL;
        const char * ivarValue = NULL;
        const char * getterValue = NULL;
        const char * setterValue = NULL;
        
        //获取属性的特性信息
        unsigned int outCount = 0;
        objc_property_attribute_t * attributes = property_copyAttributeList(property, &outCount);
        for (unsigned int i = 0; i < outCount; ++ i) {
            objc_property_attribute_t attribute = attributes[i];
            char attributeName = *attribute.name;
            if (attributeName == 'T') { //属性类型
                typeValue = attribute.value;
            }else if (attributeName == 'R') { //是否readonly
                isReadonly = YES;
            }else if (attributeName == 'V') { //关联的成员变量
                ivarValue = attribute.value;
            }else if (attributeName == 'S') { //setter方法名
                setterValue = attribute.value;
            }else if (attributeName == 'G') { //getter方法名
                getterValue = attribute.value;
            }
        }
        
        _MyPropertyType type = _getPropertyType(typeValue);
        
        //判断属性是否有效
        if (type != _MyPropertyTypeOther) { //类型支持有效
            
            data = [[_MyModelPropertyData alloc] initWithName:propertyName];
            
            //缓存类型信息
            data->_type = type;
            data->_typeEncoding = [NSString stringWithUTF8String:typeValue];
            switch (type) {
                case _MyPropertyTypeObject:
                    data->_typeClass = _objectPropertyClassForType(data->_typeEncoding);
                    break;
                    
                case _MyPropertyTypeStruct:
                    data->_typeStruct = _structPropertyNameForType(data->_typeEncoding);
                    break;
                    
                default:
                    break;
            }
            
            //获取类型内存尺寸
            data->_typeSize = _sizeForType(data->_typeEncoding.UTF8String);
            
            //获取属性关联的成员变量
            if (ivarValue) {
                data -> _ivar = class_getInstanceVariable(self.class, ivarValue);
            }
            
            //获取属性getter方法
            data->_getterSelector = sel_registerName(getterValue ? getterValue : propertyName.UTF8String);
            
            //获取属性setter方法
            if (!isReadonly) {
                data->_setterSelector = sel_registerName(setterValue ? setterValue : [propertyName xyy_defaultSetterSelectorString].UTF8String);
            }
        }
        
        //释放内存
        if (attributes != NULL) {
            free(attributes);
        }
        
        //缓存
        [cache setObject:data ?: [NSNull null] forKey:cacheKey];
    }
    
end:
    
    if (data == nil || data == (id)[NSNull null]) {
        return nil;
    }else if (dicToModel && data ->_setterSelector == NULL && data ->_ivar == NULL) { //转换成模型且没有setter和关联的成员变量则返回nil
        return nil;
    }else {
        return data;
    }
}


- (BOOL)xyy_isValidateProperty:(NSString *)propertyName forDicToModel:(BOOL)dicToModel
{
    //是否需要忽略
    if ([self xyy_needIgnoreProperty:propertyName forDicToModel:dicToModel]) {
        return NO;
    }
    
    _MyModelPropertyData * data = [self _getPropertyData:propertyName forDicToModel:dicToModel];
    return data != nil;
}


#pragma mark - dic/json to model

//key转换成属性名称（key到属性名的映射），默认返回key值
- (NSString *)xyy_propertyNameForKey:(NSString *)key {
    return key;
}

//是否需要忽视属性
- (BOOL)xyy_needIgnoreProperty:(NSString *)propertyName forDicToModel:(BOOL)dicToModel {
    return NO;
}

- (BOOL)xyy_alwaysAccessIvarDirectlyIfCanForDicToModel:(BOOL)dicToModel {
    return NO;
}

- (void)xyy_updateWithDictionary:(NSDictionary *)dictionary
{
    for (NSString * key in dictionary.allKeys) {
        
        //1.使用Key找到对应的属性
        NSString * propertyName = [self xyy_propertyNameForKey:key];
        
        //2.开始更新属性
        [self xyy_startUpdateProperty:propertyName withValue:dictionary[key]];
        
    }
}

- (void)xyy_startUpdateProperty:(NSString *)propertyName withValue:(id)value
{
    //是否需要忽略
    if ([self xyy_needIgnoreProperty:propertyName forDicToModel:YES]) {
        return;
    }
    
    //对属性进行筛选，剔除掉不存在和无效的属性
    _MyModelPropertyData * data = [self _getPropertyData:propertyName forDicToModel:YES];
    if (data == nil) {
        return;
    }
    
    assert(data->_type != _MyPropertyTypeOther);
    
    //对value进行转换
    value = [self _convertValue:value propertyData:data];
    
    //对属性进行赋值
    [self _updateProperty:data withValue:value];
}

- (void)xyy_updateProperty:(NSString *)propertyName withValue:(id)value
{
    _MyModelPropertyData * propertyData = [self _getPropertyData:propertyName forDicToModel:YES];
    if (propertyData) {
        [self _updateProperty:propertyData withValue:value];
    }
}

- (void)_updateProperty:(_MyModelPropertyData *)propertyData withValue:(id)value
{
    //使用setter赋值
    if (propertyData->_setterSelector &&
        (propertyData ->_ivar == NULL || ![self xyy_alwaysAccessIvarDirectlyIfCanForDicToModel:YES])) {
        SEL setter = propertyData->_setterSelector;
        switch (propertyData->_type) {
            case _MyPropertyTypeObject: //对象
                ((void(*)(id,SEL,id))objc_msgSend)(self,setter,value);
                break;
                
            case _MyPropertyTypeStruct: //结构体/联合体
            {
                NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:setter]];
                
                //读取值
                void * pValue = malloc(invocation.methodSignature.methodReturnLength);
                [(NSValue *)value getValue:pValue];
                
                //设置参数
                [invocation setArgument:pValue atIndex:2];
                
                //执行
                invocation.selector = setter;
                [invocation invokeWithTarget:self];
                
                free(pValue);
            }
                break;
                
            default: //数字
            {
                _MyPropertyNumberValue numberValue = {0};
                [value xyy_unboxValue:&numberValue typeEncoding:propertyData->_typeEncoding.UTF8String];
                ((void(*)(id,SEL,_MyPropertyNumberValue))objc_msgSend)(self,setter,numberValue);
                
            }
                break;
        }
        
    }else { //直接对成员变量进行赋值
        
        assert(propertyData->_ivar != nil);
        
        if (propertyData->_type == _MyPropertyTypeObject) { //对象
            object_setIvar(self, propertyData->_ivar, value);
        }else {
            
            //获取成员变量偏移
            ptrdiff_t offset = ivar_getOffset(propertyData->_ivar);
            void * location = (((char *)(__bridge void *)self) + offset);
            
            if (propertyData->_type == _MyPropertyTypeStruct) { //结构体/联合体
                
                //读取值
                void * pValue = malloc(propertyData->_typeSize);
                memset(pValue, 0, propertyData->_typeSize);
                [(NSValue *)value getValue:pValue];
                
                //设置值
                memcpy(location, pValue, propertyData->_typeSize);
                
                free(pValue);
                
            }else { //数字
                
                _MyPropertyNumberValue numberValue = {0};
                [value xyy_unboxValue:&numberValue typeEncoding:propertyData->_typeEncoding.UTF8String];
                memcpy(location, &numberValue, propertyData->_typeSize);
            }
        }
    }
}


#pragma mark - 属性值转换

- (Class)xyy_arrayContentClassForProperty:(NSString *)propertyName {
    return nil;
}

- (id)xyy_convertValue:(id)value forProperty:(NSString *)propertyName
{
    _MyModelPropertyData * propertyData = [self _getPropertyData:propertyName forDicToModel:YES];
    if (propertyData) {
        return [self _convertValue:value propertyData:propertyData];
    }
    
    return nil;
}

- (id)_convertValue:(id)value propertyData:(_MyModelPropertyData *)propertyData
{
    //自定义转换属性值(通过selector转换优先级最高)
    SEL convertSelector = NSSelectorFromString([NSString stringWithFormat:@"convert%@Value:",[propertyData->_name xyy_firstUppercaseString]]);
    if ([self respondsToSelector:convertSelector]) {
        
        NSMethodSignature * methodSignature = [self methodSignatureForSelector:convertSelector];
        if (methodSignature != nil) {
            
            //验证转换方法参数合理性,是否包含一个唯一对象参数
            if (methodSignature.numberOfArguments == 3 &&
                *[methodSignature getArgumentTypeAtIndex:2] == '@') {
                
                //验证返回值是否合理
                BOOL bRet = YES;
                if (*methodSignature.methodReturnType == 'v') { //返回值是空
                    bRet = NO;
                }else {
                    bRet = propertyData->_type == _getPropertyType(methodSignature.methodReturnType);
                    
                    //如果是结构体/联合体需要完全匹配
                    if (bRet && propertyData->_type == _MyPropertyTypeStruct) {
                        bRet = strcmp(methodSignature.methodReturnType, propertyData->_typeEncoding.UTF8String) == 0;
                    }
                }
                
                if (bRet) {
                    
                    //执行转换方法
                    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    [invocation setArgument:&value atIndex:2];
                    invocation.selector = convertSelector;
                    [invocation invokeWithTarget:self];
                    
                    //返回装箱后返回值
                    return [invocation xyy_getBoxReturnValue];
                }
            }
        }
    }
    
    //如果没有自定义转换则进行默认转换
    return [self _defaultConvertValue:value propertyData:propertyData];
}

- (id)_defaultConvertValue:(id)value propertyData:(_MyModelPropertyData *)propertyData
{
    //首先返回空值
    if (value == nil || value == [NSNull null]) {
        return [self _nilValueForPropertyData:propertyData];
    }
    
    //通过属性类型进行默认转换
    switch (propertyData->_type) {
        case _MyPropertyTypeObject: //对象
        {
            //获取对象类
            Class objectClass = propertyData -> _typeClass;
            if (objectClass == nil) { //不知道属性类型信息直接返回，不进行转换
                
                return value;
                
            }else if ([objectClass isSubclassOfClass:[NSArray class]]) { //数组类型
                
                if ([value isKindOfClass:[NSArray class]]) {
                    
                    //获取数组内容类型
                    Class contentClass = [self xyy_arrayContentClassForProperty:propertyData->_name];
                    if (contentClass != nil) { //数组内容对象转换
                        return [contentClass xyy_modelsWithDictionarys:value];
                    }else {
                        return [value isKindOfClass:objectClass] ? value : [objectClass arrayWithArray:value];
                    }
                }
                
            }else if ([value isKindOfClass:objectClass]) { //值和属性同一类型直接返回，不需要进行转换
                
                return value;
                
            }else if ([objectClass isSubclassOfClass:[NSString class]]) { //字符串则通过对象描述进行转换
                
                return [objectClass stringWithString:[value description]];
                
            }else if ([objectClass isSubclassOfClass:[NSDictionary class]]) { //字典
                
                if ([value isKindOfClass:[NSDictionary class]]) {
                    return [objectClass dictionaryWithDictionary:value];
                }
                
            }else if (objectClass == [NSNumber class]) { //数字类型
                
                return [value xyy_performDefaultConvertToNumber];
                
            }else if ([objectClass isSubclassOfClass:[NSDecimalNumber class]]) { //Decimal数字类型
                
                if ([value isKindOfClass:[NSString class]]) { //通过字符串进行转换
                    return [objectClass decimalNumberWithString:value];
                }else if ([value isKindOfClass:[NSNumber class]]) { //number转换
                    return [objectClass decimalNumberWithString:[(NSNumber *)value stringValue]];
                }
                
            }else if ([objectClass isSubclassOfClass:[NSDate class]]) { //时间
                
                //首先通过默认时间格式转换
                if([value isKindOfClass:[NSString class]]) {
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss z";
                    NSDate * dateValue = [dateFormatter dateFromString:value];
                    if (dateValue == nil) { //尝试用另一个时间格式转换
                        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                        dateValue = [dateFormatter dateFromString:value];
                    }
                    if (dateValue == nil) { //尝试用另一个时间格式转换
                        dateFormatter.dateFormat = @"yyyy-MM-dd";
                        dateValue = [dateFormatter dateFromString:value];
                    }
                    
                    if (dateValue != nil) {
                        return objectClass == [NSDate class] ? dateValue : [objectClass dateWithTimeIntervalSince1970:dateValue.timeIntervalSince1970];
                    }
                }
                
                //尝试通过时间戳初始化
                NSTimeInterval timeInterval = [[value xyy_performDefaultConvertToNumber] doubleValue];
                if (timeInterval != 0.0) {
                    return [objectClass dateWithTimeIntervalSince1970:timeInterval];
                }
                
            }else if ([objectClass conformsToProtocol:@protocol(XYYJsonModel)]) { //自定义模型类型
                
                if ([value isKindOfClass:[NSDictionary class]]) { //通过字典初始化
                    return [[objectClass alloc] xyy_initWithDictionary:value];
                }
            }
        }
            break;
            
        case _MyPropertyTypeStruct: //结构体/联合体
        {
            if ([value isKindOfClass:[NSValue class]] &&
                strcmp([value objCType], propertyData->_typeEncoding.UTF8String) == 0) { //类型相等直接返回
                
                return value;
                
            }else {
                
                SEL convertSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Value", propertyData -> _typeStruct]);
                
                //执行默认转换方法
                id convertValue = [value xyy_performConvertReturnTypes:[NSSet setWithObject:propertyData->_typeEncoding] selectors:convertSelector, NULL];
                
                //无法进行转换返回nil值
                if (convertValue == nil) {
                    return [self _nilValueForPropertyData:propertyData];
                }else {
                    return convertValue;
                }
            }
        }
            break;
            
        case _MyPropertyTypeNumber: //数字
        {
            if ([value isKindOfClass:[NSNumber class]]) { //如果是数字对象直接返回
                return value;
            }else {
                
                if ([propertyData->_typeEncoding isEqualToString:@"f"] ||
                    [propertyData->_typeEncoding isEqualToString:@"d"])  { //浮点类型
                    
                    value = [value xyy_performDefaultConvertToNumber];
                    
                }else if ([propertyData->_typeEncoding isEqualToString:@"B"]) { //布尔类型
                    
                    value = [value xyy_performConvertReturnTypes:[NSObject xyy_numberTypeEncodings]
                                                       selectors:@selector(boolValue),
                             @selector(doubleValue),
                             @selector(longLongValue),
                             @selector(floatValue),
                             @selector(integerValue),
                             @selector(intValue),NULL];
                    
                }else { //整形
                    
                    value = [value xyy_performConvertReturnTypes:[NSObject xyy_numberTypeEncodings]
                                                       selectors:@selector(longLongValue),
                             @selector(integerValue),
                             @selector(doubleValue),
                             @selector(intValue),
                             @selector(floatValue),
                             @selector(boolValue),NULL];
                    
                }
                
                return value ?: @0;
            }
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (id)_nilValueForPropertyData:(_MyModelPropertyData *)propertyData
{
    //获取自定义空值
    SEL nibSelector = NSSelectorFromString([NSString stringWithFormat:@"nil%@Value",[propertyData->_name xyy_firstUppercaseString]]);
    if ([self respondsToSelector:nibSelector]) {
        
        NSMethodSignature * methodSignature = [self methodSignatureForSelector:nibSelector];
        if (methodSignature != nil) {
            
            //验证转换方法参数合理性
            if (methodSignature.numberOfArguments == 2) {
                
                //验证返回值是否合理
                BOOL bRet = YES;
                if (*methodSignature.methodReturnType == 'v') { //返回值是空
                    bRet = NO;
                }else {
                    bRet = propertyData->_type == _getPropertyType(methodSignature.methodReturnType);
                    
                    //如果是结构体/联合体需要完全匹配
                    if (bRet && propertyData->_type == _MyPropertyTypeStruct) {
                        bRet = strcmp(methodSignature.methodReturnType, propertyData->_typeEncoding.UTF8String) == 0;
                    }
                }
                
                if (bRet) {
                    
                    //执行转换方法
                    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    invocation.selector = nibSelector;
                    [invocation invokeWithTarget:self];
                    
                    //返回装箱后返回值
                    return [invocation xyy_getBoxReturnValue];
                }
            }
        }
    }
    
    //获取默认空值
    switch (propertyData->_type) {
        case _MyPropertyTypeObject: //对象
            return nil;
            break;
            
        case _MyPropertyTypeStruct: //结构体/联合体
        {
            void * value = malloc(propertyData->_typeSize);
            memset(value, 0, propertyData->_typeSize);
            
            id nilValue = [NSValue value:value withObjCType:propertyData->_typeEncoding.UTF8String];
            
            free(value);
            
            return nilValue;
        }
            break;
            
        case _MyPropertyTypeNumber:
            return @0;
            break;
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - model to dic/json

- (NSDictionary *)xyy_convertToDictionaryWithKeys:(NSArray<NSString *> *)keys forJson:(BOOL)forJson
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString * key in keys) {
        id value = [self _valueForProperty:[self xyy_propertyNameForKey:key] forJson:forJson];
        if (value) {
            [dictionary setObject:value forKey:key];
        }
    }
    
    return dictionary;
}

- (NSDictionary *)xyy_convertToDictionary:(BOOL)forJson
{
    //获取所有属性
    unsigned int outCount;
    objc_property_t * propertys = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:outCount];
    for (int i = 0; i < outCount; ++ i) {
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(propertys[i])];
        id value = [self _valueForProperty:propertyName forJson:forJson];
        if (value) {
            [dictionary setObject:value forKey:propertyName];
        }
    }
    
    //释放内存
    if (propertys) {
        free(propertys);
    }
    
    return dictionary;
}

- (id)xyy_valueForKey:(NSString *)key forJson:(BOOL)forJson {
    return [self _valueForProperty:[self xyy_propertyNameForKey:key] forJson:forJson];
}

- (id)_valueForProperty:(NSString *)propertyName forJson:(BOOL)forJson
{
    if (![self xyy_needIgnoreProperty:propertyName forDicToModel:NO]) {
        _MyModelPropertyData * propertyData = [self _getPropertyData:propertyName forDicToModel:NO];
        if (propertyData) {
            
            if (forJson) { //首先进行自定义转换
                
                //进行转换
                SEL convertSelector = NSSelectorFromString([NSString stringWithFormat:@"convert%@ToJsonValue", [propertyData->_name xyy_firstUppercaseString]]);
                if ([self respondsToSelector:convertSelector]) {
                    
                    NSMethodSignature * methodSignature = [self methodSignatureForSelector:convertSelector];
                    if (methodSignature != nil) {
                        
                        //验证转换方法参数及返回值是否合理
                        if (methodSignature.numberOfArguments == 2 &&
                            *methodSignature.methodReturnType == '@') {
                            
                            //执行转换方法
                            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                            invocation.selector = convertSelector;
                            [invocation invokeWithTarget:self];
                            
                            //返回装箱后返回值
                            return [invocation xyy_getBoxReturnValue] ?: [NSNull null];
                            
                        }
                    }
                }
                
            }
            
            //进行默认转换
            id value = nil;
            if (propertyData->_ivar && [self xyy_alwaysAccessIvarDirectlyIfCanForDicToModel:NO]) { //   直接访问成员变量进行取值
                
                switch (propertyData->_type) {
                    case _MyPropertyTypeObject: //对象
                    {
                        value = object_getIvar(self, propertyData->_ivar);
                        if (value && forJson) {
                            value = [value xyy_convertToJsonValue];
                        }
                    }
                        break;
                        
                    case _MyPropertyTypeNumber: //数字
                    {
                        void * location = (((char *)(__bridge void *)self) + ivar_getOffset(propertyData->_ivar));
                        _MyPropertyNumberValue numberValue;
                        memcpy(&numberValue, location, propertyData->_typeSize);
                        
                        value = [NSObject xyy_boxValue:&numberValue typeEncoding:propertyData->_typeEncoding.UTF8String];
                    }
                        break;
                        
                    case _MyPropertyTypeStruct: //结构体/联合体
                    {
                        void * location = (((char *)(__bridge void *)self) + ivar_getOffset(propertyData->_ivar));
                        void * buffer = malloc(propertyData->_typeSize);
                        memcpy(buffer, location, propertyData->_typeSize);
                        
                        if (forJson) { //进行json转换
                            value = [self _convertToJsonStructValue:buffer forPropertyData:propertyData];
                        }else { //直接装箱
                            value = [NSObject xyy_boxValue:buffer typeEncoding:propertyData->_typeEncoding.UTF8String];
                        }
                        
                        free(buffer);
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }else { //使用getter进行取值
                
                SEL getter = propertyData->_getterSelector;
                if (propertyData->_type == _MyPropertyTypeObject) { //对象
                    
                    value = ((id(*)(id,SEL))objc_msgSend)(self,getter);
                    if (value && forJson) {
                        return [value xyy_convertToJsonValue];
                    }
                    
                }else {
                    
                    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:getter]];
                    invocation.selector = getter;
                    [invocation invokeWithTarget:self];
                    
                    if (propertyData->_type == _MyPropertyTypeNumber) { //数字
                        _MyPropertyNumberValue numberValue;
                        [invocation getReturnValue:&numberValue];
                        
                        //装箱
                        value = [NSObject xyy_boxValue:&numberValue typeEncoding:propertyData->_typeEncoding.UTF8String];
                        
                    }else { //结构体/联合体
                        
                        void * buffer = malloc(propertyData->_typeSize);
                        [invocation getReturnValue:buffer];
                        
                        if (forJson) { //进行json转换
                            value = [self _convertToJsonStructValue:buffer forPropertyData:propertyData];
                        }else { //直接装箱
                            value = [NSObject xyy_boxValue:buffer typeEncoding:propertyData->_typeEncoding.UTF8String];
                        }
                        
                        free(buffer);
                    }
                }
            }
            
            return value ?: [NSNull null];
        }
    }
    
    return nil;
}

- (id)_convertToJsonStructValue:(void *)value forPropertyData:(_MyModelPropertyData *)propertyData
{
    //进行转换
    SEL convertSelector = NSSelectorFromString([NSString stringWithFormat:@"stringWith%@:", propertyData -> _typeStruct]);
    if ([NSString respondsToSelector:convertSelector]) {
        
        NSMethodSignature * methodSignature = [NSString methodSignatureForSelector:convertSelector];
        if (methodSignature != nil) {
            
            //验证转换方法参数及返回值是否合理
            if (methodSignature.numberOfArguments == 3 &&
                strcmp([methodSignature getArgumentTypeAtIndex:2], propertyData->_typeEncoding.UTF8String) == 0 &&
                strcmp(methodSignature.methodReturnType, @encode(NSString *)) == 0) {
                
                //执行转换方法
                NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                invocation.selector = convertSelector;
                [invocation setArgument:value atIndex:2];
                [invocation invokeWithTarget:[NSString class]];
                
                //返回装箱后返回值
                return [invocation xyy_getBoxReturnValue];
                
            }
        }
    }
    
    return nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        unsigned int outCount;
        Ivar * ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; ++ i) {
            Ivar ivar = ivars[i];
            
            const char * typeEncoding = ivar_getTypeEncoding(ivar);
            _MyPropertyType type = _getPropertyType(typeEncoding);
            if (type == _MyPropertyTypeOther) {
                continue;
            }
            
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [aDecoder decodeObjectForKey:key];
            if (type == _MyPropertyTypeObject) { //对象
                object_setIvar(self, ivar, value);
            }else {
                void * location = (((char *)(__bridge void *)self) + ivar_getOffset(ivar));
                size_t size = _sizeForType(typeEncoding);
                if (type == _MyPropertyTypeNumber) { //数字
                    _MyPropertyNumberValue numberValue = {0};
                    [value xyy_unboxValue:&numberValue typeEncoding:typeEncoding];
                    memcpy(location, &numberValue, size);
                }else { //其他
                    void * buffer = malloc(size);
                    memset(buffer, 0, size);
                    [(NSValue *)value getValue:buffer];
                    
                    memcpy(location, buffer, size);
                    
                    free(buffer);
                }
            }
        }
        
        //释放内存
        if (ivars) {
            free(ivars);
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        
        const char * typeEncoding = ivar_getTypeEncoding(ivar);
        _MyPropertyType type = _getPropertyType(typeEncoding);
        if (type == _MyPropertyTypeOther) {
            continue;
        }
        
        id value = nil;
        if (type == _MyPropertyTypeObject) { //对象
            value = object_getIvar(self, ivar);
        }else {
            void * location = (((char *)(__bridge void *)self) + ivar_getOffset(ivar));
            size_t size = _sizeForType(typeEncoding);
            if (type == _MyPropertyTypeNumber) { //数字
                _MyPropertyNumberValue buffer;
                memcpy(&buffer, location, size);
                value = [NSObject xyy_boxValue:&buffer typeEncoding:typeEncoding];
            }else { //其他
                void * buffer = malloc(size);
                memcpy(buffer, location, size);
                value = [NSObject xyy_boxValue:buffer typeEncoding:typeEncoding];
                free(buffer);
            }
        }
        
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [aCoder encodeObject:value forKey:key];
    }
    
    //释放内存
    if (ivars) {
        free(ivars);
    }
}

@end

//----------------------------------------------------------

@implementation NSObject(ValueConvert)

+ (NSSet<NSString *> *)xyy_numberTypeEncodings
{
    static NSSet<NSString *> * numberTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberTypes = [NSSet setWithObjects:@"c",@"i",@"s",@"l",@"q",@"C",@"I",@"S",@"L",@"Q",@"f",@"d",@"B",nil];
    });
    
    return numberTypes;
}


+ (id)xyy_boxValue:(void *)value typeEncoding:(const char *)typeEncoding
{
    if (typeEncoding == NULL || *typeEncoding == '\0') {
        return nil;
    }
    
    id returnValue = nil;
    
    switch (*typeEncoding) {
        case 'v': //空值
            returnValue = [NSNull null];
            break;
            
        case '@': //对象
            returnValue = value ? (__bridge id)(*(void **)value) : nil;
            break;
            
        case 'c': //数字
            returnValue = value ? [NSNumber numberWithChar:*((char *)value)] : @0;
            break;
        case 'C':
            returnValue = value ? [NSNumber numberWithChar:*((char *)value)] : @0;
            break;
        case 's':
            returnValue = value ? [NSNumber numberWithShort:*((short *)value)] : @0;
            break;
        case 'S':
            returnValue = value ? [NSNumber numberWithUnsignedShort:*((unsigned short *)value)] : @0;
            break;
        case 'i':
            returnValue = value ? [NSNumber numberWithInt:*((int *)value)] : @0;
            break;
        case 'I':
            returnValue = value ? [NSNumber numberWithUnsignedInt:*((unsigned int *)value)] : @0;
            break;
        case 'l':
            returnValue = value ? [NSNumber numberWithLong:*((long *)value)] : @0;
            break;
        case 'L':
            returnValue = value ? [NSNumber numberWithUnsignedLong:*((unsigned long *)value)] : @0;
            break;
        case 'q':
            returnValue = value ? [NSNumber numberWithLongLong:*((long long *)value)] : @0;
            break;
        case 'Q':
            returnValue = value ? [NSNumber numberWithUnsignedLongLong:*((unsigned long long *)value)] : @0;
            break;
        case 'f':
            returnValue = value ? [NSNumber numberWithFloat:*((float *)value)] : @0;
            break;
        case 'd':
            returnValue = value ? [NSNumber numberWithDouble:*((double *)value)] : @0;
            break;
        case 'B':
            returnValue = value ? [NSNumber numberWithBool:*((bool *)value)] : @0;
            break;
            
        default: //其他
            
            if (value != NULL) {
                returnValue = [NSValue valueWithBytes:value objCType:typeEncoding];
            }else {
                
                //申请内存，填充0
                size_t size = _sizeForType(typeEncoding);
                value = malloc(size);
                memset(value, 0, size);
                
                //打包
                returnValue = [NSValue valueWithBytes:value objCType:typeEncoding];
                
                //释放
                free(value);
            }
            
            break;
    }
    
    return returnValue;
}

- (void)xyy_unboxValue:(void *)buffer typeEncoding:(const char *)typeEncoding
{
    if (buffer == NULL || typeEncoding == NULL || *typeEncoding == '\0') {
        return;
    }
    
    switch (*typeEncoding) {
        case 'v': //空值
            return;
            break;
            
        case '@': //对象
            *(void **)buffer = (__bridge void *)self;
            break;
            
        case 'c': //整形
            *(char *)buffer = [(NSNumber *)self charValue];
            break;
        case 'C':
            *(unsigned char *)buffer = [(NSNumber *)self unsignedCharValue];
            break;
        case 's':
            *(short *)buffer = [(NSNumber *)self shortValue];
            break;
        case 'S':
            *(unsigned short *)buffer = [(NSNumber *)self unsignedShortValue];
            break;
        case 'i':
            *(int *)buffer = [(NSNumber *)self intValue];
            break;
        case 'I':
            *(unsigned int *)buffer = [(NSNumber *)self unsignedIntValue];
            break;
        case 'l':
            *(long *)buffer = [(NSNumber *)self longValue];
            break;
        case 'L':
            *(unsigned long *)buffer = [(NSNumber *)self unsignedLongValue];
            break;
        case 'q':
            *(long long *)buffer = [(NSNumber *)self longLongValue];
            break;
        case 'Q':
            *(unsigned long long *)buffer = [(NSNumber *)self unsignedLongLongValue];
            break;
        case 'f':
            *(float *)buffer = [(NSNumber *)self floatValue];
            break;
        case 'd':
            *(double *)buffer = [(NSNumber *)self doubleValue];
            break;
        case 'B':
            *(bool *)buffer = [(NSNumber *)self boolValue];
            break;
            
        default: //其他
            
            if ([self isKindOfClass:[NSValue class]] &&
                strcmp(typeEncoding, [(NSValue *)self objCType]) == 0) {
                [(NSValue *)self getValue:buffer];
            }
            
            break;
    }
}

- (id)xyy_performConvertReturnTypes:(NSSet<NSString *> *)returnTypes selectors:(SEL)aSelector,...
{
    if (aSelector == NULL) {
        return nil;
    }
    
    //读取不定参数
    va_list args;
    va_start(args, aSelector);
    
    NSPointerArray * aSelectors = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality];
    
    do {
        [aSelectors addPointer:aSelector];
    }while ((aSelector = va_arg(args, SEL)));
    
    va_end(args);
    
    return [self xyy_performConvertReturnTypes:returnTypes selectorsArray:aSelectors];
}

- (id)xyy_performConvertReturnTypes:(NSSet<NSString *> *)returnTypes selectorsArray:(NSPointerArray *)aSelectors
{
    for (NSUInteger i = 0; i < aSelectors.count; ++ i) {
        
        SEL aSelector = [aSelectors pointerAtIndex:i];
        if (aSelector != NULL && [self respondsToSelector:aSelector]) {
            
            //判断方法签名有效性
            NSMethodSignature * methodSignature = [self methodSignatureForSelector:aSelector];
            if (methodSignature && methodSignature.numberOfArguments == 2 &&
                (returnTypes.count == 0 || [returnTypes containsObject:[NSString stringWithUTF8String:methodSignature.methodReturnType]])) {
                
                //执行方法
                NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                invocation.selector = aSelector;
                [invocation invokeWithTarget:self];
                
                //获取装箱后的返回值
                id returnValue = [invocation xyy_getBoxReturnValue];
                if (returnValue != nil) {
                    return returnValue;
                }
            }
        }
    }
    
    return nil;
}


- (NSNumber *)xyy_performDefaultConvertToNumber
{
    return [self xyy_performConvertReturnTypes:[NSObject xyy_numberTypeEncodings]
                                     selectors:@selector(doubleValue),
            @selector(longLongValue),
            @selector(floatValue),
            @selector(integerValue),
            @selector(intValue),
            @selector(boolValue),NULL];
}

- (id)xyy_convertToJsonValue
{
    //不做任何转换
    if ([self isKindOfClass:[NSString class]] ||
        [self isKindOfClass:[NSNumber class]] ||
        [self isKindOfClass:[NSNull class]]) {
        return self;
    }
    
    //XYYModel
    if ([[self class] conformsToProtocol:@protocol(XYYJsonModel)]) {
        return [self xyy_convertToDictionary:YES];
    }
    
    //NSArray
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray * jsonArray = [NSMutableArray arrayWithCapacity:[(NSArray *)self count]];
        for (id object in (NSArray *)self) {
            [jsonArray addObject:[object xyy_convertToJsonValue] ?: [NSNull null]];
        }
        return jsonArray;
    }
    
    //NSSet
    if ([self isKindOfClass:[NSSet class]]) {
        NSMutableArray * jsonArray = [NSMutableArray arrayWithCapacity:[(NSSet *)self count]];
        for (id object in (NSSet *)self) {
            [jsonArray addObject:[object xyy_convertToJsonValue] ?: [NSNull null]];
        }
        return jsonArray;
    }
    
    //NSDictionary
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary * jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:[(NSDictionary *)self count]];
        for (id key in [(NSDictionary *)self allKeys]) {
            id jsonKey = [key xyy_convertToJsonValue];
            id jsonValue = [[(NSDictionary *)self objectForKey:key] xyy_convertToJsonValue];
            if (jsonKey && [jsonKey conformsToProtocol:@protocol(NSCopying)]) {
                [jsonDictionary setObject:jsonValue ?: [NSNull null] forKey:jsonKey];
            }
        }
        return jsonDictionary;
    }
    
    return [self description];
}

@end

//----------------------------------------------------------


@implementation NSInvocation(BoxReturnValue)

- (id)xyy_getBoxReturnValue
{
    id returnValue = nil;
    if (*self.methodSignature.methodReturnType == 'v') { //无返回值
        returnValue = [NSNull null];
    }else {
        
        switch (_getPropertyType(self.methodSignature.methodReturnType)) {
            case _MyPropertyTypeObject: //对象
            {
                void * buffer = NULL;
                [self getReturnValue:&buffer];
                returnValue = (__bridge id)buffer;
            }
                break;
                
            case _MyPropertyTypeNumber: //C语言数字类型
            {
                _MyPropertyNumberValue buffer;
                [self getReturnValue:&buffer];
                
                returnValue = [NSObject xyy_boxValue:&buffer typeEncoding:self.methodSignature.methodReturnType];
            }
                break;
                
            default: //其他
            {
                //生成缓存区取回返回值
                void * buffer = NULL;
                buffer = malloc(self.methodSignature.methodReturnLength);
                [self getReturnValue:buffer];
                
                //打包
                returnValue = [NSObject xyy_boxValue:buffer typeEncoding:self.methodSignature.methodReturnType];
                
                //释放内存
                if (buffer) {
                    free(buffer);
                }
            }
                break;
        }
    }
    
    return returnValue;
}

@end

//----------------------------------------------------------

@implementation NSString(setter)

- (NSString *)xyy_firstUppercaseString
{
    if (self.length == 0) {
        return self;
    }else if (self.length == 1) {
        return self.uppercaseString;
    }else {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[self substringWithRange:NSMakeRange(0, 1)].uppercaseString];
    }
}

- (NSString *)xyy_defaultSetterSelectorString {
    return [NSString stringWithFormat:@"set%@:",self.xyy_firstUppercaseString];
}

@end

//----------------------------------------------------------

@implementation NSString(NSStringSystemStructExtensions)

- (CGPoint)CGPointValue {
    return CGPointFromString(self);
}
- (CGRect)CGRectValue {
    return CGRectFromString(self);
}
- (CGSize)CGSizeValue {
    return CGSizeFromString(self);
}
- (CGVector)CGVectorValue {
    return CGVectorFromString(self);
}
- (CGAffineTransform)CGAffineTransformValue {
    return CGAffineTransformFromString(self);
}
- (UIEdgeInsets)UIEdgeInsetsValue {
    return UIEdgeInsetsFromString(self);
}
- (UIOffset)UIOffsetValue {
    return UIOffsetFromString(self);
}
- (NSRange)NSRangeValue {
    return NSRangeFromString(self);
}


+ (NSString *)stringWithCGPoint:(CGPoint)point {
    return NSStringFromCGPoint(point);
}
+ (NSString *)stringWithCGRect:(CGRect)rect {
    return NSStringFromCGRect(rect);
}
+ (NSString *)stringWithCGSize:(CGSize)size {
    return NSStringFromCGSize(size);
}
+ (NSString *)stringWithCGVector:(CGVector)vector {
    return NSStringFromCGVector(vector);
}
+ (NSString *)stringWithCGAffineTransform:(CGAffineTransform)affineTransform {
    return NSStringFromCGAffineTransform(affineTransform);
}
+ (NSString *)stringWithUIEdgeInsets:(UIEdgeInsets)edgeInsets {
    return NSStringFromUIEdgeInsets(edgeInsets);
}
+ (NSString *)stringWithUIOffset:(UIOffset)offset {
    return NSStringFromUIOffset(offset);
}
+ (NSString *)stringWithNSRange:(NSRange)range {
    return NSStringFromRange(range);
}

@end

