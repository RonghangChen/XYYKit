//
//  NSObject+runtime.m
//  QingYang_iOS
//
//  Created by 陈荣航 on 2018/5/3.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "NSObject+runtime.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (runtime)

+ (BOOL)exchangeInstanceMethodIMPWithSel1:(SEL)sel1 sel2:(SEL)sel2
{
    if (sel1 == NULL || sel2 == NULL) {
        return NO;
    }
    
    Method method1 = class_getInstanceMethod(self, sel1);
    Method method2 = class_getInstanceMethod(self, sel2);
    
    if (method1 == NULL || method2 == nil) {
        return NO;
    }
    
    //添加方法，防止方法是父类实现的导致更改了父类,如果已经实现方法会被忽略
    class_addMethod(self, sel1, method_getImplementation(method1), method_getTypeEncoding(method1));
    class_addMethod(self, sel2, method_getImplementation(method2), method_getTypeEncoding(method2));
    
    //交换实现
    method_exchangeImplementations(class_getInstanceMethod(self, sel1),
                                   class_getInstanceMethod(self, sel2));
    
    return YES;
}

+ (BOOL)exchangeClassMethodIMPWithSel1:(SEL)sel1 sel2:(SEL)sel2
{
    //如果是元类
    if (class_isMetaClass(self)) {
        return [self exchangeInstanceMethodIMPWithSel1:sel1 sel2:sel2];
    }
    
    if (sel1 == NULL || sel2 == NULL) {
        return NO;
    }
    
    Method method1 = class_getClassMethod(self, sel1);
    Method method2 = class_getClassMethod(self, sel2);
    
    if (method1 == NULL || method2 == nil) {
        return NO;
    }
    
    //添加方法，防止方法是父类实现的导致更改了父类,如果已经实现方法会被忽略
    class_addMethod(object_getClass(self), sel1, method_getImplementation(method1), method_getTypeEncoding(method1));
    class_addMethod(object_getClass(self), sel2, method_getImplementation(method2), method_getTypeEncoding(method2));
    
    //交换实现
    method_exchangeImplementations(class_getClassMethod(self, sel1),
                                   class_getClassMethod(self, sel2));
    
    return YES;
}

+ (Method)getCatrgoryOverInstanceMethodWithSel:(SEL)sel
{
    if (sel == NULL) {
        return NULL;
    }
    
    Method method = class_getInstanceMethod(self, sel);
    if (method == nil) {
        return NULL;
    }
    
    //查找被覆盖的方法，第一个名称相同但方法不同的方法
    Method oldMethod = NULL;
    unsigned int methodCount;
    Method * methodList = class_copyMethodList(self, &methodCount);
    for (NSInteger i = 0; i < methodCount; i++) {
        
        Method method1 = methodList[i];
        if (strcmp(sel_getName(sel), sel_getName(method_getName(method1))) == 0) { //名称一样
            if(method != method1) { //但方法不同
                oldMethod = method1;
                break;
            }
        }
    }
    
    //释放内存
    if (methodList != NULL) {
        free(methodList);
    }
    
    return oldMethod;
}

+ (Method)getCatrgoryOverClassMethodWithSel:(SEL)sel
{
    //如果是元类
    if (class_isMetaClass(self)) {
        return [self getCatrgoryOverInstanceMethodWithSel:sel];
    }
    
    if (sel == NULL) {
        return NULL;
    }
    
    Method method = class_getClassMethod(self, sel);
    if (method == nil) {
        return NULL;
    }
    
    //查找被覆盖的方法，第一个名称相关但方法不同的方法
    Method oldMethod = NULL;
    unsigned int methodCount;
    Method * methodList = class_copyMethodList(object_getClass(self), &methodCount);
    for (NSInteger i = 0; i < methodCount; i++) {
        
        Method method1 = methodList[i];
        if (strcmp(sel_getName(sel), sel_getName(method_getName(method1))) == 0) { //名称一样
            if(method != method1) { //但方法不同
                oldMethod = method1;
                break;
            }
        }
    }
    
    //释放内存
    if (methodList != NULL) {
        free(methodList);
    }
    
    return oldMethod;
}

@end
