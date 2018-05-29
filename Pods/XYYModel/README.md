# XYYModel
objc轻量字典(JSON)转模型库，单文件，无任何依懒，高效，使用简单，高容错性，转换过程可自定义。相关介绍博文：https://www.jianshu.com/p/a614d2ef80e1

# 主要功能

1.字典（json）转模型

2.模型转字典（json）

3.模型自动归档


# 支持的功能

1.可定制key到属性的映射

2.可定制value值转换过程

3.强大的默认value转换机制，容错处理完美

4.可定制取值及赋值方式

5.支持自定义结构体/联合体转换

6.支持组合模型，即模型包含模型或模型数组

# 如何安装

下载源码直接引入工程 或者 
使用CocoPods 添加 pod 'XYYModel'

# 如何使用

## 1.字典转模型
调用xyy_modelsWithDictionarys:或者xyy_initWithDictionary:即可进行字典到模型的转换，也可以使用xyy_updateWithDictionary:进行更新模型


## 2.模型转字典
调用xyy_convertToDictionaryWithKeys:forJson:或者xyy_convertToDictionary:即可进行模型到字典的转换


## 3.定制转换过程

### 3.1.忽视属性
覆盖实现xyy_needIgnoreProperty:forDicToModel:方法，示例如下

```
- (BOOL)xyy_needIgnoreProperty:(NSString *)propertyName forDicToModel:(BOOL)dicToModel
{

    if ([propertyName isEqualToString:@"needIgnore"]) {
        return YES;
    }
    
    if (dicToModle && [propertyName isEqualToString:@"needIgnoreDicToModle"]) {
        return YES;
    }

    return [super xyy_needIgnoreProperty:propertyName forDicToModel:dicToModel];
}
    
```


### 3.2.定制key到属性的映射
覆盖实现xyy_propertyNameForKey:方法，示例如下

```
- (NSString *)xyy_propertyNameForKey:(NSString *)key
{
    if ([key isEqualToString:@"key1"]) {
        return @"propertyName1";
    }

    return [super xyy_propertyNameForKey:key];
}
```

### 3.3.定制value值转换
实现convert#PropertyName#Value:格式方法，返回转换后的值，示例如下

```
- (XYYDemoStruct)convertDemoStructValue:(id)value
{
    XYYDemoStruct result = {0};
    if ([value isKindOfClass:[NSString class]]) {
        NSArray<NSString *> * components = [value componentsSeparatedByString:@","];
        if (components.count == 2) {
            result.value1 = [components[0] intValue];
            result.value2 = [components[1] floatValue];
        }
    }
    return result;
}
```

### 3.4.定制赋值取值方式
实现xyy_alwaysAccessIvarDirectlyIfCanForDicToModel:方法，可定制取值赋值方法，示例如下

```
- (XYYDemoStruct)xyy_alwaysAccessIvarDirectlyIfCanForDicToModel:(id)dicToModel
{
    if(dicToModel) {
        return YES;
    }
    return NO;
}
```

### 3.5.定制value空值
实现nil#PropertyName#Value:格式方法，返回属性对应的空值，示例如下

```
- (CGSize)nilSize1Value:(id)value {
    return CGSizeMake(1.f,2.f);
}
```

### 3.5实现组合模型转换
覆盖实现xyy_arrayContentClassForProperty:方法，示例如下

```
- (Class)xyy_arrayContentClassForProperty:(NSString *)propertyName 
{
    if ([propertyName isEqualToString:@"subModels"]) {
        return [XYYSubDemoModel class];
    }
    return nil;
}
```


# 转换策略及流程简介

## 字典（json）转模型

### (1)通过xyy_propertyNameForKey:方法获取key对应的属性名称


### (2)判断属性是否有效（可赋值属性）
属性是否有效需满足四个条件:

1.属性没有被xyy_needIgnoreProperty:forDicToModel:方法忽视

2.属性名对应属性存在

3.属性类型是支持的数据类型,包括对象，C语言数字类型，结构体或联合体

4.属性不是readonly（即有setter方法）或者属性有关联的成员变量

### (3)对属性值进行转换

#### 属性值转换顺序是：

1.(如果存在)调用convert#PropertyName#Value:（#PropertyName#为首字母大写的属性名，下同）格式的方法进行转换，调用方法前会进行方法参数和返回值判断
    
2.进行默认转换


#### 属性值默认转换策略是：

1.属性值为空（包括NSNull对象)返回空值

2.属性类型为对象:首先判断值是否是同一种类对象，是直接返回，否则执行默认转换策略进行转换（能进行默认转换的类NSString、NSMutableString、NSMutableArray、NSMutableDictionary、NSNumber、NSDecimalNumber、NSDate以及遵循XYYJsonModel协议的类），无法转换则返回nil

3.属性类型为结构体或联合体:使用#structName/unionName#Value方法进行转换，无法转换则返回空值

4.属性类型为C语言数字类型:使用数字类型相关方法进行转换,无法转换则返回空值


#### 属性空值为:

1.调用（如果存在）nil#PropertyName#Value格式的方法获取空值，调用方法前会进行方法参数和返回值判断

2.没有自定义空值使用默认空值

#### 默认空值为:

1.属性类型为对象:nil

3.属性类型为结构体或联合体:填充为0的NSValue

4.属性类型为C语言数字类型:值为0的NSNumber


### (4)对属性进行赋值

属性赋值策略为:

1.存在setter方法，使用setter方法进行赋值

2.直接对成员变量进行赋值


## 模型转字典（json）

### (1)通过xyy_propertyNameForKey:方法获取key对应的属性名称


### (2)判断属性是否有效（可赋值属性）
属性是否有效需满足三个条件:

1.属性没有被xyy_needIgnoreProperty:forDicToModle:方法忽视

2.属性名对应属性存在

3.属性类型是支持的数据类型,包括对象，C语言数字类型，结构体或联合体


### (3)对属性值进行装箱或者转换,分两种情况,具体策略为:

#### 1)如果目标值非json值（json的值类型只会包含NSNumber,NSString,NSNull,NSArray,NSDictionary）

1.value为对象，如果为nil则返回NSNull对象,其他情况不做任何处理直接返回
    
2.value为C语言数字类型（基本数据类型）使用NSNumber进行装箱

3.value为其他情况（结构体、联合体）使用NSValue装箱

#### 2)如果目标值为json值,首先(如果存在)会调用convert#PropertyName#ToJsonValue格式方法获取自定义json值，否则使用默认转换策略进行转换，默认策略如下

1.value为对象,如果为nil则返回NSNull对象,其他情况调用xyy_convertToJsonValue方法进行转换,具体的默认转换策略参见xyy_convertToJsonValue方法定义
    
2.value为C语言数字类型（基本数据类型）使用NSNumber进行装箱

3.value为其他情况（结构体、联合体）(如果存在)调用NSString类的stringWith<structName/unionName>:格式方法生成对应的NSString对象，否则返回NSNull对象


## 对象转json对象默认策略为:

1.对象为NSNumber,NSString,NSNull类及其子类，不做任何转换

2.对象遵循XYYJsonModel协议,调用xyy_convertToDictionary:进行转换

3.对象NSArray,遍历所有成员调用xyy_convertToJsonValue操作生成新的NSArray

4.对象为NSSet,遍历所有成员调用xyy_convertToJsonValue操作生成NSArray

5.对象为NSDictionary,遍历所有key-value分别对key和value调用xyy_convertToJsonValue操作生成新的NSDictionary

6.对象为其他情况默认调用description返回对象描述


# 联系方式

QQ：102731887

微信：Hldw_H

