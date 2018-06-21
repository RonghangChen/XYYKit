//
//  NSObject+runtime.h
//  QingYang_iOS
//
//  Created by 陈荣航 on 2018/5/3.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (runtime)

//交换实例方法实现
+ (BOOL)exchangeInstanceMethodIMPWithSel1:(SEL)sel1 sel2:(SEL)sel2;
//交换类方法实现
+ (BOOL)exchangeClassMethodIMPWithSel1:(SEL)sel1 sel2:(SEL)sel2;

//获取分类覆盖的实例方法
+ (Method)getCatrgoryOverInstanceMethodWithSel:(SEL)sel;
//获取分类覆盖的类方法
+ (Method)getCatrgoryOverClassMethodWithSel:(SEL)sel;
@end
