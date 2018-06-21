//
//  MyWeakDelegate.h
//  
//
//  Created by LeslieChen on 15/11/7.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <Foundation/Foundation.h>

//delegate的弱引用的容器，
@interface MyWeakDelegate<__covariant ObjectType> : NSObject

- (id)initWithDelegateForSearch:(ObjectType)delegate;

- (id)initWithDelegate:(ObjectType)delegate;
@property(nonatomic,weak,readonly) ObjectType delegate;

//生成delegate的key
+ (id<NSCopying>)keyForDelegate:(ObjectType)delegate;
@property(nonatomic,strong,readonly) id<NSCopying> delegateKey;


@end
