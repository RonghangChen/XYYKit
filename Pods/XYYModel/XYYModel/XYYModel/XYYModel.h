//
//  MyModel.h
//
//
//  Created by 陈荣航 on 2017/12/6.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

//用来指示是否是jsonModel,一般来说默认转换策略不会将对象与字典进行相互转换，除非他遵循XYYJsonModel协议（显示调用转换方法的除外）
@protocol XYYJsonModel
@end

//----------------------------------------------------------

@interface NSObject(XYYModel) <NSCoding>

#pragma mark - dic/json to model

//初始化
+ (NSMutableArray *)xyy_modelsWithDictionarys:(NSArray<NSDictionary *> *)dictionarys;
- (id)xyy_initWithDictionary:(NSDictionary *)dictionary NS_REPLACES_RECEIVER;

#pragma mark - 更新属性值

//更新属性值，更新属性值策略为:
//(1)通过propertyNameForKey:方法获取key对应的属性名称
//
//(2)判断属性是否有效（可赋值属性）
//属性是否有效需满足四个条件:
//1.属性没有被xyy_needIgnoreProperty:forDicToModel:方法忽视
//2.属性名对应属性存在
//3.属性类型是支持的数据类型,包括对象，C语言数字类型，结构体或联合体
//4.属性不是readonly（即有setter方法）或者属性有关联的成员变量
//
//(3)对属性值进行转换
//属性值转换顺序是：
//1.(如果存在)调用convert<PropertyName>Value:方法进行转换，调用方法前会进行方法参数和返回值判断
//2.进行默认转换
//属性值默认转换策略是：
//1.属性值为空（包括NSNull对象)返回空值
//2.属性类型为对象:首先判断值是否是同一种类对象，直接返回，否则执行默认转换策略进行转换（能进行默认转换的类NSString、NSMutableString、NSMutableArray、NSMutableDictionary、NSNumber、NSDecimalNumber、NSDate以遵循XYYJsonModel协议的类）,无法转换则返回nil
//3.属性类型为结构体或联合体:(如果存在)调用<structName/unionName>Value方法进行转换，无法转换则返回空值
//4.属性类型为C语言数字类型:使用数字类型相关方法进行转换,无法转换则返回空值
//属性空值为:
//1.调用（如果存在）nil<PropertyName>Value方法获取空值，调用方法前会进行方法参数和返回值判断
//2.没有自定义空值使用默认空值
//默认空值为:
//1.属性类型为对象:nil
//2.属性类型为结构体或联合体:填充为0的NSValue
//3.属性类型为C语言数字类型:值为0的NSNumber
//
//(4)对属性进行赋值
//属性赋值策略为:
//1.存在setter方法，使用setter方法进行赋值
//2.直接对成员变量进行赋值
- (void)xyy_updateWithDictionary:(NSDictionary *)dictionary;


#pragma mark - model to dic/json

//获取属性值策略为:
//(1)通过propertyNameForKey:方法获取key对应的属性名称
//
//(2)判断属性是否有效（可取值属性）
//属性是否有效需满足三个条件:
//1.属性没有被xyy_needIgnoreProperty:forDicToModel:方法忽视
//2.属性名对应属性存在
//3.属性类型是支持的数据类型,包括对象，C语言数字类型，结构体或联合体
//
//(3)对属性值进行装箱或者转换,分两种情况,具体策略为:
//1)如果目标值非json值（json的值类型只会包含NSNumber,NSString,NSNull,NSArray,NSDictionary）
//1.1.value为对象，如果为nil则返回NSNull对象,其他情况不做任何处理直接返回
//1.2.value为C语言数字类型（基本数据类型）使用NSNumber进行装箱
//1.3.value为其他情况（结构体、联合体）使用NSValue装箱
//2)如果目标值为json值,首先(如果存在)会调用convert<PropertyName>ToJsonValue方法获取自定义json值，否则使用默认转换策略进行转换，默认策略如下：
//2.1.value为对象,如果为nil则返回NSNull对象,其他情况调用xyy_convertToJsonValue方法进行转换,具体的默认转换策略参见xyy_convertToJsonValue方法定义
//2.2.value为C语言数字类型（基本数据类型）使用NSNumber进行装箱
//2.3.value为其他情况（结构体、联合体）(如果存在)调用NSString类的stringWith<structName/unionName>:方法生成对应的NSString对象，否则返回NSNull对象
/**
 * 获取key对应的属性值
 * @param key key为属性key值
 * @param forJson forJson指示是否目标值为Json的value
 * @return 返回key对应的属性值,如果key对应的属性无效，返回nil，如果属性为类型为对象且为nil，则返回NSNull对象
 */
- (id)xyy_valueForKey:(NSString *)key forJson:(BOOL)forJson;


/**
 * 将model转换成字典
 * @param keys keys为需要转换的属性key数组,不传keys版本是会将所有属性进行转换
 * @param forJson forJson指示是否目标为json字典
 * @return 返回转换后的字典
 * @note 如果key对应的属性无效，则会忽略，如果属性为类型为对象且为nil，则填充NSNull对象
 */
- (NSDictionary *)xyy_convertToDictionaryWithKeys:(NSArray<NSString *> *)keys forJson:(BOOL)forJson;
- (NSDictionary *)xyy_convertToDictionary:(BOOL)forJson;

#pragma mark - 定制转换过程

/**
 * key对应的属性名称（key到属性名的映射）
 * @param key key为key值
 * @return 默认返回key值
 * @note 覆盖该方法可定制key到属性名的映射
 */
- (NSString *)xyy_propertyNameForKey:(NSString *)key;

/**
 * 是否需要忽视属性
 * @param propertyName propertyName为属性名称
 * @param dicToModel dicToModel指示转换方向，YES为字典到模型，NO为模型到字典
 * @return 默认返回NO
 * @note 覆盖该方法可自定义忽视的属性，忽视的属性即为无效属性将不参与转换操作
 */
- (BOOL)xyy_needIgnoreProperty:(NSString *)propertyName forDicToModel:(BOOL)dicToModel;


/**
 * NSArray类型属性包含对象的类型信息，用于数组到模型数组的转换
 * @param propertyName propertyName为属性名称
 * @return 返回NSArray类型属性包含对象的类型信息，用于属性值的转换，默认返回nil，即不进行转换
 * @note 覆盖该方法可定制NSArray类型的属性值的转换，让数组内容转换成对应对象
 */
- (Class)xyy_arrayContentClassForProperty:(NSString *)propertyName;

/**
 * 指示是否尽可能直接访问成员变量进行取值赋值
 * @param dicToModel dicToModel指示转换方向，YES为字典到模型，NO为模型到字典
 * @return 返回是否尽可能直接访问成员变量进行取值赋值，默认为NO
 * @note 覆盖该方法可定制取值赋值策略，直接访问成员变量效率高，但是会导致自定义setter/getter方法不会被调用，如果没有自定义setter/getter方法，返回YES可以提升取值赋值效率
 */
- (BOOL)xyy_alwaysAccessIvarDirectlyIfCanForDicToModel:(BOOL)dicToModel;


/**
 * 开始更新某一个属性时会调用该方法
 * @param propertyName propertyName为属性名称
 * @param value value为属性值
 * @note 调用该方法时，属性没有进行有效判断，值也未进行转换，可覆盖定制化转换过程
 */
- (void)xyy_startUpdateProperty:(NSString *)propertyName withValue:(id)value;

#pragma mark - 帮助方法

/**
 * 属性是否为有效属性（可取值或者赋值的属性）
 * @param propertyName propertyName为属性名称
 * @param dicToModel dicToModel指示转换方向，YES为字典到模型，NO为模型到字典
 * @return 返回是否为有效属性
 * @note 该方法仅提供给调用，内部不会使用该方法返回值作为是否有效的依据即覆盖不会对转换过程造成任何影响
 */
- (BOOL)xyy_isValidateProperty:(NSString *)propertyName forDicToModel:(BOOL)dicToModel;

/**
 * 转换属性值
 * @param value value为属性值
 * @param propertyName propertyName为属性名称
 * @return 返回转换后的属性值
 * @note 该方法仅提供给调用，内部不会使用该方法进行值转换覆盖不会对赋值过程造成任何影响
 */
- (id)xyy_convertValue:(id)value forProperty:(NSString *)propertyName;

/**
 * 更新属性值
 * @param propertyName propertyName为属性名称
 * @param value value为属性值
 * @note 该方法仅提供给调用，内部不会使用该方法更新属性值覆盖不会对赋值过程造成任何影响
 */
- (void)xyy_updateProperty:(NSString *)propertyName withValue:(id)value;


@end

//----------------------------------------------------------

@interface NSObject(ValueConvert)

/**
 * 对值进行装箱
 * @param value value为值的地址
 * @param typeEncoding typeEncoding为值的类型编码
 * @return 返回装箱后的值
 * 装箱策略为：
 * 1.值类型为viod返回NSNull对象
 * 2.值类型为对象直接返回
 * 3.值类型为C语言数字类型（基本数据类型）使用NSNumber装箱
 * 4.其他情况（结构体、联合体、非对象指针等等）使用NSValue装箱
 */
+ (id)xyy_boxValue:(void *)value typeEncoding:(const char *)typeEncoding;

/**
 * 对值（调用者）进行拆箱
 * @param buffer buffer为存储拆箱值的缓存区，缓存区应该大于值的存储大小
 * @param typeEncoding typeEncoding为值的类型编码
 * 拆箱策略为：
 * 1.值类型为viod直接忽略
 * 2.值类型为对象直接写入缓存区，不会改变引用计数
 * 3.值类型为C语言数字类型（基本数据类型）会调用相应方法（例如int会调用intValue）获取值
 * 4.其他情况（结构体、联合体、非对象指针等等）调用者必须为NSValue，会进行类型判断并调用getValue:方法将值读入缓存区
 */
- (void)xyy_unboxValue:(void *)buffer typeEncoding:(const char *)typeEncoding;

/**
 * 转换对象成目标类型的对象或者装箱对象
 * @param returnTypes returnTypes为目标类型集合
 * @param aSelector aSelector为转换方法
 * @return 返回转换后的对象，无法转换则返回nil
 * @note 按照aSelector顺序执行转换方法，执行前会判断是否响应方法、方法参数是否合法以及返回值是否是目标类型集合中的一种，如果目标类型是C语言数字类型，会进行装箱操作，装箱策略见boxValue:typeEncoding:
 */
- (id)xyy_performConvertReturnTypes:(NSSet<NSString *> *)returnTypes selectors:(SEL)aSelector,...;
- (id)xyy_performConvertReturnTypes:(NSSet<NSString *> *)returnTypes selectorsArray:(NSPointerArray *)aSelectors;

/**
 * 获取C语言数字类型（基本数据类型）的类型编码集合
 * @return 返回C语言数字类型（基本数据类型）的类型编码集合
 */
+ (NSSet<NSString *> *)xyy_numberTypeEncodings;

/**
 * 转换对象成C语言数字类型装箱对象
 * @return 转换成功返回C语言数字类型装箱对象，否则返回nil
 */
- (NSNumber *)xyy_performDefaultConvertToNumber;


/**
 * 转换对象成Json值对象,可覆盖实现自定义转换过程,默认转换策略为:
 * 1.对象(调用者,下同)为NSNumber,NSString,NSNull类及其子类，不做任何转换
 * 2.对象为遵循XYYJSONModel的类,调用xyy_convertToDictionary:进行转换
 * 3.对象NSArray,遍历所有成员调用xyy_convertToJsonValue操作生成新的NSArray
 * 4.对象为NSSet,遍历所有成员调用xyy_convertToJsonValue操作生成NSArray
 * 5.对象为NSDictionary,遍历所有key-value分别对key和value调用xyy_convertToJsonValue操作生成新的NSDictionary
 * 6.对象为其他情况默认调用description返回对象描述
 */
- (id)xyy_convertToJsonValue;

@end

//----------------------------------------------------------

@interface NSInvocation(BoxReturnValue)

/**
 * 获取装箱后的返回值
 * @return 返回装箱后的返回值
 * 装箱策略为：
 * 1.无返回值返回NSNull对象
 * 2.返回值为对象直接返回
 * 3.返回值为C语言数字类型（基本数据类型）使用NSNumber装箱
 * 4.其他情况（结构体、联合体、非对象指针等等）使用NSValue装箱
 */
- (id)xyy_getBoxReturnValue;

@end

//----------------------------------------------------------

@interface NSString(setter)

//返回首字母（如果存在）大写字符串
- (NSString *)xyy_firstUppercaseString;

//返回默认setter方法的字符串
- (NSString *)xyy_defaultSetterSelectorString;

@end

//----------------------------------------------------------

@interface NSString(NSStringSystemStructExtensions)

- (CGPoint)CGPointValue;
- (CGRect)CGRectValue;
- (CGSize)CGSizeValue;
- (CGVector)CGVectorValue;
- (CGAffineTransform)CGAffineTransformValue;
- (UIEdgeInsets)UIEdgeInsetsValue;
- (UIOffset)UIOffsetValue;
- (NSRange)NSRangeValue;

+ (NSString *)stringWithCGPoint:(CGPoint)point;
+ (NSString *)stringWithCGRect:(CGRect)rect;
+ (NSString *)stringWithCGSize:(CGSize)size;
+ (NSString *)stringWithCGVector:(CGVector)vector;
+ (NSString *)stringWithCGAffineTransform:(CGAffineTransform)affineTransform;
+ (NSString *)stringWithUIEdgeInsets:(UIEdgeInsets)edgeInsets;
+ (NSString *)stringWithUIOffset:(UIOffset)offset;
+ (NSString *)stringWithNSRange:(NSRange)range;

@end






