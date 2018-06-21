//
//  MacroDef.h
//
//  Created by hldw on 13-12-10.
//  Copyright (c) 2013年 hldw. All rights reserved.
//

/*
 *常用宏的定义
 */

//----------------------------------------------------------

#ifndef MacroDef_h
#define MacroDef_h

//----------------------------------------------------------

#ifndef __NSX_PASTE__
#define __NSX_PASTE__(A,B) A##B
#endif

//----------------------------------------------------------

//调试输出

#if DEBUG

#define DebugLog(_targetDomin,_format,...)                                                  \
do {                                                                                    \
fprintf(stderr, "\n--------------------------------\n\n");                          \
fprintf(stderr, "<%s : %d> %s\n\n",                                                 \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
NSLog(@"\n\n["#_targetDomin@"]\n\n"_format,##__VA_ARGS__);                          \
fprintf(stderr, "\n--------------------------------\n\n");                          \
} while (0)

#else

#define DebugLog(_targetDomin,_format,...)

#endif

//默认作用域的debug输出
#define DefaultDebugLog(_format,...)   DebugLog(DefaultDomin,_format, ##__VA_ARGS__)

//输出rect
#define DebugLogRect(rect) DefaultDebugLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

//输出size
#define DebugLogSize(size) DefaultDebugLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)

//输出point
#define DebugLogPoint(point) DefaultDebugLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)

//输出inset
#define DebugLogInstes(inset) DefaultDebugLog(@"%s top:%.4f, left:%.4f, bottom:%.4f, right:%.4f", #inset, inset.top, inset.left, inset.bottom, inset.right)

//----------------------------------------------------------

//断言
#if DEBUG
#define    MyAssert(e) assert(e)
#else
#define    MyAssert(e)
#endif

//错误
//----------------------------------------------------------

//错误创建
#define __ERROR_CREATE_IMP__(_domain, _code, _description, _userinfo, L)                                            \
({                                                                                                                  \
    NSMutableDictionary * __NSX_PASTE__(__userinfo,L) = (id)(_userinfo);                                            \
    if(__NSX_PASTE__(__userinfo,L)) {                                                                               \
        __NSX_PASTE__(__userinfo,L) = [NSMutableDictionary dictionaryWithDictionary:__NSX_PASTE__(__userinfo,L)];   \
    }else {                                                                                                         \
        __NSX_PASTE__(__userinfo,L) = [NSMutableDictionary dictionary];                                             \
    }                                                                                                               \
    NSString * __NSX_PASTE__(__description,L)  = (id)(_description);                                                \
    if([__NSX_PASTE__(__description,L) isKindOfClass:[NSString class]]) {                                           \
        [__NSX_PASTE__(__userinfo,L) setObject:__NSX_PASTE__(__description,L)                                       \
                                        forKey:NSLocalizedDescriptionKey];                                          \
    }                                                                                                               \
    [NSError errorWithDomain:_domain                                                                                \
                        code:_code                                                                                  \
                    userInfo:__NSX_PASTE__(__userinfo,L)];                                                          \
})
#define ERROR_CREATE(_domain,_code,_description,_userinfo)        \
    __ERROR_CREATE_IMP__(_domain, _code, _description, _userinfo, __COUNTER__)


//错误识别,判断错误是否为_domain错误域的错误
#define __IS_DOMAIN_ERROR_IMP__(_error,_domain,L)                 \
({                                                                \
    NSError * __NSX_PASTE__(__error,L)  = _error;                 \
    [__NSX_PASTE__(__error,L).domain isEqualToString:_domain];    \
})
#define IS_DOMAIN_ERROR(_error,_domain) __IS_DOMAIN_ERROR_IMP__(_error,_domain,__COUNTER__)


//错误识别,判断错误是否为_domain错误域的code错误码的错误
#define __IS_SPECIFIC_ERROR_IMP__(_error,_domain,_code,L)         \
({                                                                \
    NSError * __NSX_PASTE__(__error,L)  = _error;                 \
    ([__NSX_PASTE__(__error,L).domain isEqualToString:_domain] && \
     (__NSX_PASTE__(__error,L).code == (_code)));                 \
})
#define IS_SPECIFIC_ERROR(_error,_domain,_code)  __IS_SPECIFIC_ERROR_IMP__(_error,_domain,_code,__COUNTER__)


//错误的本地化描述
#define __LocalizedDescriptionForError_IMP__(_error,L)                          \
({                                                                              \
    NSError * __NSX_PASTE__(__error,L)  = _error;                               \
    [__NSX_PASTE__(__error,L).userInfo objectForKey:NSLocalizedDescriptionKey]; \
})
#define LocalizedDescriptionForError(_error) __LocalizedDescriptionForError_IMP__(_error,__COUNTER__)


//其他
//----------------------------------------------------------

//通过名字初始化图片
#define ImageWithName(_name)  [UIImage imageNamed:(_name)]

//创建引用
#define WEAK_REFRENCE(_obj,_name) typeof(_obj) __weak _name = _obj;
#define STRONG_REFRENCE(_obj,_name) typeof(_obj) __strong _name = _obj;

//获取完整的HTTP链接
#define __FULL_HTTP_URL__IMP__(_url,L)              \
({                                                  \
    NSString * __NSX_PASTE__(__url,L) = (id)(_url); \
    if([__NSX_PASTE__(__url,L) isKindOfClass:[NSString class]] && __NSX_PASTE__(__url,L).length) {              \
        if(![__NSX_PASTE__(__url,L) hasPrefix:@"http://"] && ![__NSX_PASTE__(__url,L) hasPrefix:@"https://"]) { \
            __NSX_PASTE__(__url,L) = [@"http://" stringByAppendingString:__NSX_PASTE__(__url,L)];               \
        }                                \
    }else {                              \
       __NSX_PASTE__(__url,L) = nil;     \
    }                                    \
    __NSX_PASTE__(__url,L);              \
})
#define FULL_HTTP_URL(_url) __FULL_HTTP_URL__IMP__(_url,__COUNTER__)


//判断是否为http请求的URL
#define __IS_HTTP_URL__IMP__(_url,L)                                                \
({                                                                                  \
    NSString * __NSX_PASTE__(__url,L) = (id)(_url);                                 \
    BOOL __NSX_PASTE__(__bRet,L) = NO;                                              \
    if([__NSX_PASTE__(__url,L) isKindOfClass:[NSString class]] && __NSX_PASTE__(__url,L).length) {  \
        __NSX_PASTE__(__url,L) = [__NSX_PASTE__(__url,L) lowercaseString];          \
        __NSX_PASTE__(__bRet,L) = [__NSX_PASTE__(__url,L) hasPrefix:@"http://"] ||  \
                                  [__NSX_PASTE__(__url,L) hasPrefix:@"https://"];   \
    }                                                                               \
    __NSX_PASTE__(__bRet,L);                                                        \
})
#define IS_HTTP_URL(_url) __IS_HTTP_URL__IMP__(_url,__COUNTER__)

//----------------------------------------------------------

//指针的安全转换
#define ConvertToClassPointer(className,instance) \
[(NSObject *)instance isKindOfClass:[className class]] ? (className *)instance : nil

#define NSNumberWithPointer(_pointer) [NSNumber numberWithUnsignedInteger:((NSUInteger)(_pointer))]

//----------------------------------------------------------

#define ifRespondsSelector(_obj,_sel)  if (_obj&&[(NSObject *)_obj respondsToSelector:_sel])

//安全调用Selector
#define SafePerformSelector(_per_obj,_sel,...)                   \
do{                                                              \
NSObject *_obj =(NSObject *) _per_obj;                       \
ifRespondsSelector(_obj,_sel)                                \
objc_msgSend(_obj,_sel,##__VA_ARGS__);                   \
}while(0)

#define __MyStringIsEqual_IMP__(_str1, _str2, L)   \
({ \
NSString *  __NSX_PASTE__(__str1,L) = _str1; \
NSString * __NSX_PASTE__(__str2,L) = _str2;  \
([__NSX_PASTE__(__str1,L) length] == 0 && [__NSX_PASTE__(__str2,L) length] == 0) || \
[__NSX_PASTE__(__str1,L) isEqualToString:__NSX_PASTE__(__str2,L)]; \
})
#define MyStringIsEqual(_str1, _str2) __MyStringIsEqual_IMP__(_str1, _str2, __COUNTER__)


//属性文本
//----------------------------------------------------------

//属性文本创建
#define __ATTR_STR_CREATE_IMP__(_str,_font,_color,_attr,L)                       \
({                                                                               \
    NSMutableDictionary * __NSX_PASTE__(__attr,L) = (id)(_attr);                 \
    if(__NSX_PASTE__(__attr,L)) {                                                \
        __NSX_PASTE__(__attr,L) = [NSMutableDictionary dictionaryWithDictionary:__NSX_PASTE__(__attr,L)];                                                         \
    }else {                                                                      \
        __NSX_PASTE__(__attr,L) = [NSMutableDictionary dictionary];              \
    }                                                                            \
    UIFont * __NSX_PASTE__(__font,L)  = (id)(_font);                             \
    if(__NSX_PASTE__(__font,L)) {                                                \
        [__NSX_PASTE__(__attr,L) setObject:__NSX_PASTE__(__font,L)               \
                                    forKey:NSFontAttributeName];                 \
    }                                                                            \
    UIColor * __NSX_PASTE__(__color,L)  = (id)(_color);                          \
    if(__NSX_PASTE__(__color,L)) {                                               \
        [__NSX_PASTE__(__attr,L) setObject:__NSX_PASTE__(__color,L)              \
                                    forKey:NSForegroundColorAttributeName];      \
    }                                                                            \
    [[NSAttributedString alloc] initWithString:(_str)                            \
                                    attributes:__NSX_PASTE__(__attr,L)];         \
})

#define ATTR_STR_CREATE(_str,_font,_color,_attr)     \
        __ATTR_STR_CREATE_IMP__(_str,_font,_color,_attr,__COUNTER__)

#endif

