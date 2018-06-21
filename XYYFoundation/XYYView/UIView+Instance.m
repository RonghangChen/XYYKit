//
//  UIView+Instance.m
//
//
//  Created by LeslieChen on 14/10/28.
//  Copyright (c) 2014年 YB. All rights reserved.
//

#import "UIView+Instance.h"
#import "ScreenAdaptation.h"
#import "XYYBaseDef.h"
#import "NSObject+runtime.h"
#import <objc/message.h>

@implementation UIView (Instance)

+ (instancetype)xyy_createInstance {
    return [self xyy_createInstanceWithNibName:nil bundle:nil context:nil];
}

+ (instancetype)xyy_createInstanceWithContext:(id)context {
    return [self xyy_createInstanceWithNibName:nil bundle:nil context:context];
}

+ (instancetype)xyy_createInstanceWithNibName:(NSString *)nibNameOrNil
                                       bundle:(NSBundle *)bundleOrNil
                                      context:(id)context
{
    //首先使用nib初始化
    UIView * instance = [self _xyy_createInstanceWithNibName:nibNameOrNil bundle:bundleOrNil context:context];
    
    if (instance == nil) { //nib不存在使用普通初始化
        instance = [[self alloc] xyy_initWithContext:context];
    }
    
    return instance;
}

+ (instancetype)_xyy_createInstanceWithNibName:(NSString *)nibNameOrNil
                                        bundle:(NSBundle *)bundleOrNil
                                       context:(id)context
{
    nibNameOrNil = validAdaptationNibName(nibNameOrNil ?: NSStringFromClass([self class]),bundleOrNil);
    if (nibNameOrNil.length) {
        
        NSArray * objects = [[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil] instantiateWithOwner:nil options:nil];
        for (id object in objects) {
            if ([self isSubclassOfClass:[object class]]) {
                [object xyy_setupViewWithContext:context];
                return object;
            }
        }
    }
    
    return nil;
}

- (id)xyy_initWithContext:(id)context
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self xyy_setupViewWithContext:context];
    }
    
    return self;
}

- (void)xyy_setupViewWithContext:(id)context{
    //do nothing
}

#pragma mark -

static Method awakeAfterUsingCoderMethod = NULL;
+ (void)load
{
    //查找被覆盖的方法
    awakeAfterUsingCoderMethod = [UIView getCatrgoryOverInstanceMethodWithSel:@selector(awakeAfterUsingCoder:)];
}

+ (BOOL)xyy_shouldApplyNibBridging {
    return NO;
}

+ (BOOL)_xyy_isBrideLoad:(BOOL)get remove:(BOOL)remove
{
    static NSMutableDictionary * dics = nil;
    if (dics == nil) {
        dics = [NSMutableDictionary dictionary];
    }
    
    NSNumber * key = NSNumberWithPointer(self);
    if (get) {
        return [dics objectForKey:key] != nil;
    }else if(remove) {
        [dics removeObjectForKey:key];
    }else {
        [dics setObject:[NSNull null] forKey:key];
    }
    
    return NO;
}


- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    //如果存在被覆盖的初始化方法，则调用否则调用父类方法
    if (awakeAfterUsingCoderMethod != NULL) {
        self = ((id(*)(id,Method,id))method_invoke)(self,awakeAfterUsingCoderMethod,aDecoder);
    }else {
        self = [super awakeAfterUsingCoder:aDecoder];
    }
    
    BOOL isBrideLoad = [[self class] _xyy_isBrideLoad:YES remove:NO];
    if (!isBrideLoad && [[self class] xyy_shouldApplyNibBridging]) {
        
        //从nib创建,设置标志物
        [[self class] _xyy_isBrideLoad:NO remove:NO];
        UIView * realView = [[self class] _xyy_createInstanceWithNibName:nil bundle:nil context:nil];
        [[self class] _xyy_isBrideLoad:NO remove:YES];
        
        if (realView != nil) {
         
            //属性拷贝
            realView.tag = self.tag;
            realView.bounds = self.bounds;
            realView.center = self.center;
            realView.transform = self.transform;
            realView.hidden = self.hidden;
            realView.alpha = self.alpha;
            realView.autoresizingMask = self.autoresizingMask;
            realView.userInteractionEnabled = self.userInteractionEnabled;
            realView.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints;
            
            //布局拷贝
            if (self.constraints.count > 0) {
                
                // We only need to copy "self" constraints (like width/height constraints)
                // from placeholder to real view
                for (NSLayoutConstraint * constraint in self.constraints) {
                    
                    NSLayoutConstraint * newConstraint;
                    
                    // "Height" or "Width" constraint
                    // "self" as its first item, no second item
                    if (!constraint.secondItem) {
                        newConstraint =
                        [NSLayoutConstraint constraintWithItem:realView
                                                     attribute:constraint.firstAttribute
                                                     relatedBy:constraint.relation
                                                        toItem:nil
                                                     attribute:constraint.secondAttribute
                                                    multiplier:constraint.multiplier
                                                      constant:constraint.constant];
                    }
                    // "Aspect ratio" constraint
                    // "self" as its first AND second item
                    else if ([constraint.firstItem isEqual:constraint.secondItem]) {
                        newConstraint =
                        [NSLayoutConstraint constraintWithItem:realView
                                                     attribute:constraint.firstAttribute
                                                     relatedBy:constraint.relation
                                                        toItem:realView
                                                     attribute:constraint.secondAttribute
                                                    multiplier:constraint.multiplier
                                                      constant:constraint.constant];
                    }
                    
                    // Copy properties to new constraint
                    if (newConstraint) {
                        newConstraint.shouldBeArchived = constraint.shouldBeArchived;
                        newConstraint.priority = constraint.priority;
                        newConstraint.identifier = constraint.identifier;
                        [realView addConstraint:newConstraint];
                    }
                }
            }
            
            return realView;
        }
    }
    
    return self;
}

@end
