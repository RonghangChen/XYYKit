//
//  MyGradientView.m
//
//
//  Created by LeslieChen on 14/11/4.
//  Copyright (c) 2014年 YB. All rights reserved.
//

#import "MyGradientView.h"

@implementation MyGradientView

#pragma mark - life circle

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _init_GradientView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init_GradientView];
    }
    
    return self;
}

- (void)_init_GradientView {
    self.backgroundColor = [UIColor clearColor];
}


#define _gradientLayer ((CAGradientLayer *)self.layer)

#define LAYER_ACCESSOR(accessor, ctype) \
- (ctype)accessor {                     \
    return [_gradientLayer accessor];   \
}

#define LAYER_MUTATOR(mutator, ctype)   \
- (void)mutator (ctype)value {          \
    [_gradientLayer mutator value];     \
}

#define LAYER_RW_PROPERTY(accessor, mutator, ctype) \
    LAYER_ACCESSOR (accessor, ctype)                \
    LAYER_MUTATOR (mutator, ctype)

LAYER_RW_PROPERTY(startPoint, setStartPoint:, CGPoint)
LAYER_RW_PROPERTY(endPoint, setEndPoint:, CGPoint)
LAYER_RW_PROPERTY(locations, setLocations:, NSArray *)


- (void)setColors:(NSArray *)colors
{
    NSMutableArray * cgColors = [NSMutableArray arrayWithCapacity:colors.count];
    
    for (UIColor * color in colors) {
        if ([color respondsToSelector:@selector(CGColor)]) {
            [cgColors addObject:(__bridge id)[color CGColor]];
        }
    }
    
    _gradientLayer.colors = cgColors;
}

- (NSArray *)colors
{
    NSArray * cgColors = _gradientLayer.colors;
    
    NSMutableArray * colors = [NSMutableArray arrayWithCapacity:cgColors.count];
    for (id cgColor in cgColors) {
        [colors addObject:[UIColor colorWithCGColor:(__bridge CGColorRef)cgColor]];
    }
    
    return colors;
}


//#pragma mark - KVO
//
//- (NSArray *)_observableKeypaths
//{
//    return @[
//             @"colors",
//             @"locations",
//             @"startPoint",
//             @"endPoint"
//             ];
//}
//
//- (void)_registerKVO
//{
//    for (NSString * keyPath in [self _observableKeypaths]) {
//        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
//    }
//}
//
//- (void)_unregisterKVO
//{
//    for (NSString * keyPath in [self _observableKeypaths]) {
//        [self removeObserver:self forKeyPath:keyPath];
//    }
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([NSThread isMainThread]) {
//        [self _updateUIForKeypath:keyPath];
//    }else{
//        [self performSelectorOnMainThread:@selector(_updateUIForKeypath:)
//                               withObject:keyPath
//                            waitUntilDone:NO];
//    }
//}
//
//- (void)_updateUIForKeypath:(NSString *)keyPath
//{
//    [self setNeedsDisplay];
//}

//#pragma mark - UI
//
//- (void)drawRect:(CGRect)rect
//{
//    //填充背景
//    [self.backgroundColor setFill];
//    UIRectFill(rect);    
//    
//    NSUInteger colorsCount = self.colors.count;
//    
//    if (colorsCount == 0) {
//        return;
//    }
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    //裁剪
//    CGContextClipToRect(context, rect);
// 
//    NSMutableArray * cgColorArray = [NSMutableArray arrayWithCapacity:colorsCount];
//    CGFloat        * locations    = malloc(sizeof(CGFloat) * colorsCount);
//    memset(locations, 0, sizeof(CGFloat) * colorsCount);
//    
//    for (int index = 0; index < colorsCount; ++ index) {
//        
//        id color = self.colors[index];
//        if ([color respondsToSelector:@selector(CGColor)]) {
//            [cgColorArray addObject:(__bridge id)[color CGColor]];
//        }else{
//            NSLog(@"MyGradientView ,存在color不可获取");
//        }
//
//        if (index < self.locations.count) {
//            
//            id value = self.locations[index];
//            if([value respondsToSelector:@selector(floatValue)]){
//                
//                locations[index] = [value floatValue];
//                continue;
//            }
//        }
//        
////        NSLog(@"MyGradientView ,存在locations不可获取");
//        
//        if (index != 0) {
//            locations[index] = locations[index - 1];
//        }
//
//    }
//    
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    
//    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)cgColorArray,self.locations.count  ? locations : NULL);
//    CGContextDrawLinearGradient(context, gradient,
//                                CGPointMake(self.startPoint.x * CGRectGetWidth(rect) + CGRectGetMinX(rect), self.startPoint.y * CGRectGetHeight(rect) + CGRectGetMinY(rect)),
//                                CGPointMake(self.endPoint.x * CGRectGetWidth(rect) + CGRectGetMinX(rect), self.endPoint.y * CGRectGetHeight(rect) + CGRectGetMinY(rect)), 0);
//    CGContextFillPath(context);
//    
//    //释放变量
//    CGColorSpaceRelease(rgb);
//    CGGradientRelease(gradient);
//    free(locations);
//    
////    CGContextRestoreGState(context);
//}


@end
